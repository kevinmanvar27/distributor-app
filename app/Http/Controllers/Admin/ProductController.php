<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Product;
use App\Models\Media;
use App\Models\Category;
use App\Models\SubCategory;
use App\Models\ProductAttribute;
use App\Models\ProductVariation;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Log;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Str;
use League\Csv\Writer;
use League\Csv\Reader;

class ProductController extends Controller
{
    /**
     * Display a listing of the products.
     */
    public function index()
    {
        $this->authorize('viewAny', Product::class);
        
        $products = Product::with('mainPhoto')->latest()->paginate(10);
        
        // Get low stock products count for alert badge (includes both simple and variable products)
        $lowStockCount = $this->getLowStockCount();
        
        return view('admin.products.index', compact('products', 'lowStockCount'));
    }
    
    /**
     * Get the count of products with low stock (both simple and variable products).
     *
     * @return int
     */
    private function getLowStockCount(): int
    {
        $allProducts = Product::with('variations')->get();
        
        return $allProducts->filter(function ($product) {
            if ($product->isVariable()) {
                // For variable products, check if any variation has low stock
                foreach ($product->variations as $variation) {
                    $threshold = $variation->low_quantity_threshold ?? $product->low_quantity_threshold ?? 10;
                    // Include variations with 0 stock or stock <= threshold
                    if ($variation->stock_quantity <= $threshold) {
                        return true;
                    }
                }
                return false;
            } else {
                // For simple products, check if stock <= threshold
                $threshold = $product->low_quantity_threshold ?? 10;
                return $product->stock_quantity <= $threshold;
            }
        })->count();
    }

    /**
     * Show the form for creating a new product.
     */
    public function create()
    {
        $this->authorize('create', Product::class);
        
        // Get all active categories with their subcategories
        $categories = Category::with('subCategories')->where('is_active', true)->get();
        
        // Get all active attributes with their values
        $attributes = ProductAttribute::with('values')->active()->orderBy('sort_order')->get();
        
        return view('admin.products.create', compact('categories', 'attributes'));
    }

    /**
     * Store a newly created product in storage.
     */
    public function store(Request $request)
    {
        $this->authorize('create', Product::class);
        
        // Log the request data for debugging
        Log::info('Product store request data:', $request->all());
        
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'product_type' => 'required|in:simple,variable',
            'description' => 'nullable|string',
            'mrp' => 'required_if:product_type,simple|nullable|numeric|min:0.01',
            'selling_price' => 'nullable|numeric|lt:mrp',
            'in_stock' => 'required_if:product_type,simple|boolean',
            'stock_quantity' => 'nullable|integer|min:0',
            'low_quantity_threshold' => 'nullable|integer|min:0',
            'status' => 'required|in:draft,published',
            'main_photo_id' => 'nullable|integer|exists:media,id',
            'product_gallery' => 'nullable',
            'product_categories' => 'nullable|array',
            'product_categories.*.category_id' => 'required|exists:categories,id',
            'product_categories.*.subcategory_ids' => 'nullable|array',
            'product_categories.*.subcategory_ids.*' => 'nullable|exists:sub_categories,id',
            'product_attributes' => 'required_if:product_type,variable|nullable|array',
            'variations' => 'required_if:product_type,variable|nullable|array|min:1',
            'variations.*.id' => 'nullable|exists:product_variations,id',
            'variations.*.sku' => 'nullable|string',
            'variations.*.mrp' => 'nullable|numeric|min:0',
            'variations.*.selling_price' => 'nullable|numeric',
            'variations.*.stock_quantity' => 'required_with:variations|integer|min:0',
            'variations.*.low_quantity_threshold' => 'nullable|integer|min:0',
            'variations.*.attribute_values' => 'required_with:variations|array|min:1',
            'variations.*.image' => 'nullable|image|mimes:jpeg,png,jpg,gif,webp|max:2048',
            'variations.*.image_id' => 'nullable|integer|exists:media,id',
            'variations.*.remove_image' => 'nullable|boolean',
            'meta_title' => 'nullable|string|max:255',
            'meta_description' => 'nullable|string|max:500',
            'meta_keywords' => 'nullable|string|max:255',
        ]);

        if ($validator->fails()) {
            return redirect()->back()->withErrors($validator)->withInput();
        }
        
        // Custom validation for SKU uniqueness in update
        if ($request->has('variations')) {
            $variations = $request->variations;
            if (is_string($variations)) {
                $variations = json_decode($variations, true);
            }
            
            if (is_array($variations)) {
                foreach ($variations as $variationData) {
                    if (!empty($variationData['sku'])) {
                        $skuQuery = ProductVariation::where('sku', $variationData['sku']);
                        
                        // Exclude current variation if it has an ID
                        if (isset($variationData['id']) && !empty($variationData['id'])) {
                            $skuQuery->where('id', '!=', $variationData['id']);
                        }
                        
                        if ($skuQuery->exists()) {
                            return redirect()->back()
                                ->withErrors(['error' => "SKU '{$variationData['sku']}' already exists. Please use a unique SKU for each variation."])
                                ->withInput();
                        }
                    }
                }
            }
        }
        
        DB::beginTransaction();
        
        try {
            $data = $request->only([
                'name', 'product_type', 'description', 'mrp', 'selling_price', 'in_stock', 
                'status', 'main_photo_id', 'meta_title', 
                'meta_description', 'meta_keywords'
            ]);
            
            // Log the data that will be saved
            Log::info('Product data to be saved:', $data);
            
            // Handle product type - default to simple if not provided
            $data['product_type'] = $request->product_type ?? 'simple';
            
            // For simple products, handle stock quantity
            if ($data['product_type'] === 'simple') {
                $data['stock_quantity'] = $request->in_stock ? ($request->stock_quantity ?? 0) : 0;
                
                // Ensure stock_quantity is never null
                if (!isset($data['stock_quantity']) || is_null($data['stock_quantity'])) {
                    $data['stock_quantity'] = 0;
                }
            } else {
                // For variable products, set default values
                $data['stock_quantity'] = 0;
                $data['in_stock'] = true;
                $data['mrp'] = $data['mrp'] ?? 0;
            }
            
            // Handle low quantity threshold - default to 10 if not provided
            $data['low_quantity_threshold'] = $request->low_quantity_threshold ?? 10;
            
            // Handle product gallery - convert from JSON string to array if needed
            $productGallery = $request->product_gallery;
            if (is_string($productGallery)) {
                $productGallery = json_decode($productGallery, true);
            }
            $data['product_gallery'] = is_array($productGallery) ? $productGallery : [];
            
            // Handle product categories - convert from JSON string to array if needed
            $productCategories = $request->product_categories;
            if (is_string($productCategories)) {
                $productCategories = json_decode($productCategories, true);
            }
            $data['product_categories'] = is_array($productCategories) ? $productCategories : [];
            
            // Handle product attributes for variable products
            $productAttributes = $request->product_attributes;
            if (is_string($productAttributes)) {
                $productAttributes = json_decode($productAttributes, true);
            }
            $data['product_attributes'] = is_array($productAttributes) ? $productAttributes : [];
            
            // Log the final data before creating the product
            Log::info('Final product data before creation:', $data);
            
            $product = Product::create($data);
            
            // Handle variations for variable products
            if ($data['product_type'] === 'variable' && $request->has('variations')) {
                $variations = $request->variations;
                if (is_string($variations)) {
                    $variations = json_decode($variations, true);
                }
                
                if (is_array($variations) && !empty($variations)) {
                    $seenCombinations = [];
                    
                    foreach ($variations as $index => $variationData) {
                        // Convert attribute_values if it's a string
                        if (isset($variationData['attribute_values']) && is_string($variationData['attribute_values'])) {
                            $variationData['attribute_values'] = json_decode($variationData['attribute_values'], true);
                        }
                        
                        // Check if SKU already exists in database
                        if (!empty($variationData['sku'])) {
                            $existingSku = ProductVariation::where('sku', $variationData['sku'])->first();
                            if ($existingSku) {
                                DB::rollBack();
                                return redirect()->back()
                                    ->withErrors(['error' => "SKU '{$variationData['sku']}' already exists. Please use a unique SKU for each variation."])
                                    ->withInput();
                            }
                        }
                        
                        // Check for duplicate combinations
                        if (isset($variationData['attribute_values'])) {
                            ksort($variationData['attribute_values']);
                            $combinationKey = json_encode($variationData['attribute_values']);
                            
                            if (in_array($combinationKey, $seenCombinations)) {
                                Log::warning('Skipping duplicate variation combination', ['combination' => $variationData['attribute_values']]);
                                continue;
                            }
                            
                            $seenCombinations[] = $combinationKey;
                        }
                        
                        // Ensure stock_quantity is set and not null
                        if (!isset($variationData['stock_quantity']) || $variationData['stock_quantity'] === null || $variationData['stock_quantity'] === '') {
                            $variationData['stock_quantity'] = 0;
                        }
                        
                        // Set in_stock based on stock_quantity
                        $variationData['in_stock'] = isset($variationData['stock_quantity']) && $variationData['stock_quantity'] > 0;
                        
                        // Handle variation image upload
                        if ($request->hasFile("variations.{$index}.image")) {
                            $imageFile = $request->file("variations.{$index}.image");
                            
                            // Store the image
                            $imagePath = $imageFile->store('products/variations', 'public');
                            
                            // Create media record
                            $media = Media::create([
                                'name' => 'Variation Image - ' . ($variationData['sku'] ?? 'Variation ' . ($index + 1)),
                                'file_name' => $imageFile->getClientOriginalName(),
                                'mime_type' => $imageFile->getMimeType(),
                                'path' => $imagePath,
                                'size' => $imageFile->getSize(),
                            ]);
                            
                            // Set the image_id
                            $variationData['image_id'] = $media->id;
                        } elseif (isset($variationData['image_id']) && !empty($variationData['image_id'])) {
                            // If image_id is provided (from media library), keep it
                            // No action needed, just ensure it's set
                        }
                        
                        // Set first variation as default if not specified
                        if (!isset($variationData['is_default'])) {
                            $variationData['is_default'] = ($index === 0);
                        }
                        
                        $product->variations()->create($variationData);
                    }
                }
            }
            
            // Log the created product
            Log::info('Product created:', $product->toArray());
            
            DB::commit();
            
            return redirect()->route('admin.products.index')->with('success', 'Product created successfully.');
            
        } catch (\Exception $e) {
            DB::rollBack();
            Log::error('Product creation failed:', ['error' => $e->getMessage()]);
            return redirect()->back()->withErrors(['error' => 'Failed to create product: ' . $e->getMessage()])->withInput();
        }
    }

    /**
     * Display the specified product.
     */
    public function show(Product $product)
    {
        $this->authorize('view', $product);
        
        return view('admin.products.show', compact('product'));
    }

    /**
     * Display the specified product details for modal view.
     */
    public function showDetails(Product $product)
    {
        $this->authorize('view', $product);
        
        // Return only the content section for the modal without extending layout
        return view('admin.products._product_details', compact('product'));
    }

    /**
     * Show the form for editing the specified product.
     */
    public function edit(Product $product)
    {
        $this->authorize('update', $product);
        
        // Load the main photo relationship and variations
        $product->load('mainPhoto', 'variations.image');
        
        // Get all active categories with their subcategories
        $categories = Category::with('subCategories')->where('is_active', true)->get();
        
        // Get all active attributes with their values
        $attributes = ProductAttribute::with('values')->active()->orderBy('sort_order')->get();
        
        return view('admin.products.edit', compact('product', 'categories', 'attributes'));
    }

    /**
     * Update the specified product in storage.
     */
    public function update(Request $request, Product $product)
    {
        $this->authorize('update', $product);
        
        // Log the request data for debugging
        Log::info('Product update request data:', $request->all());
        
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'product_type' => 'required|in:simple,variable',
            'description' => 'nullable|string',
            'mrp' => 'required_if:product_type,simple|nullable|numeric|min:0.01',
            'selling_price' => 'nullable|numeric|lt:mrp',
            'in_stock' => 'required_if:product_type,simple|boolean',
            'stock_quantity' => 'nullable|integer|min:0',
            'low_quantity_threshold' => 'nullable|integer|min:0',
            'status' => 'required|in:draft,published',
            'main_photo_id' => 'nullable|integer|exists:media,id',
            'product_gallery' => 'nullable',
            'product_categories' => 'nullable|array',
            'product_categories.*.category_id' => 'required|exists:categories,id',
            'product_categories.*.subcategory_ids' => 'nullable|array',
            'product_categories.*.subcategory_ids.*' => 'nullable|exists:sub_categories,id',
            'product_attributes' => 'required_if:product_type,variable|nullable|array',
            'variations' => 'required_if:product_type,variable|nullable|array|min:1',
            'variations.*.id' => 'nullable|exists:product_variations,id',
            'variations.*.sku' => 'nullable|string',
            'variations.*.mrp' => 'nullable|numeric|min:0',
            'variations.*.selling_price' => 'nullable|numeric',
            'variations.*.stock_quantity' => 'required_with:variations|integer|min:0',
            'variations.*.low_quantity_threshold' => 'nullable|integer|min:0',
            'variations.*.attribute_values' => 'required_with:variations|array|min:1',
            'variations.*.image' => 'nullable|image|mimes:jpeg,png,jpg,gif,webp|max:2048',
            'variations.*.image_id' => 'nullable|integer|exists:media,id',
            'variations.*.remove_image' => 'nullable|boolean',
            'meta_title' => 'nullable|string|max:255',
            'meta_description' => 'nullable|string|max:500',
            'meta_keywords' => 'nullable|string|max:255',
        ]);

        if ($validator->fails()) {
            return redirect()->back()->withErrors($validator)->withInput();
        }
        
        // Custom validation for SKU uniqueness in update
        if ($request->has('variations')) {
            $variations = $request->variations;
            if (is_string($variations)) {
                $variations = json_decode($variations, true);
            }
            
            if (is_array($variations)) {
                foreach ($variations as $variationData) {
                    if (!empty($variationData['sku'])) {
                        $skuQuery = ProductVariation::where('sku', $variationData['sku']);
                        
                        // Exclude current variation if it has an ID
                        if (isset($variationData['id']) && !empty($variationData['id'])) {
                            $skuQuery->where('id', '!=', $variationData['id']);
                        }
                        
                        if ($skuQuery->exists()) {
                            return redirect()->back()
                                ->withErrors(['error' => "SKU '{$variationData['sku']}' already exists. Please use a unique SKU for each variation."])
                                ->withInput();
                        }
                    }
                }
            }
        }
        
        DB::beginTransaction();
        
        try {
            $data = $request->only([
                'name', 'product_type', 'description', 'mrp', 'selling_price', 'in_stock', 
                'status', 'main_photo_id', 'meta_title', 
                'meta_description', 'meta_keywords'
            ]);
            
            // Log the data that will be saved
            Log::info('Product data to be updated:', $data);
            
            // Handle product type
            $data['product_type'] = $request->product_type ?? $product->product_type ?? 'simple';
            
            // For simple products, handle stock quantity
            if ($data['product_type'] === 'simple') {
                $data['stock_quantity'] = $request->in_stock ? ($request->stock_quantity ?? 0) : 0;
                
                // Ensure stock_quantity is never null
                if (!isset($data['stock_quantity']) || is_null($data['stock_quantity'])) {
                    $data['stock_quantity'] = 0;
                }
            } else {
                // For variable products, set default values
                $data['stock_quantity'] = 0;
                $data['in_stock'] = true;
                if (!isset($data['mrp']) || is_null($data['mrp'])) {
                    $data['mrp'] = $product->mrp ?? 0;
                }
            }
            
            // Handle low quantity threshold - keep existing value if not provided
            $data['low_quantity_threshold'] = $request->low_quantity_threshold ?? $product->low_quantity_threshold ?? 10;
            
            // Handle product gallery - convert from JSON string to array if needed
            $productGallery = $request->product_gallery;
            if (is_string($productGallery)) {
                $productGallery = json_decode($productGallery, true);
            }
            $data['product_gallery'] = is_array($productGallery) ? $productGallery : [];
            
            // Handle product categories - convert from JSON string to array if needed
            $productCategories = $request->product_categories;
            if (is_string($productCategories)) {
                $productCategories = json_decode($productCategories, true);
            }
            $data['product_categories'] = is_array($productCategories) ? $productCategories : [];
            
            // Handle product attributes for variable products
            $productAttributes = $request->product_attributes;
            if (is_string($productAttributes)) {
                $productAttributes = json_decode($productAttributes, true);
            }
            $data['product_attributes'] = is_array($productAttributes) ? $productAttributes : [];
            
            // Log the final data before updating the product
            Log::info('Final product data before update:', $data);
            
            $product->update($data);
            
            // Handle variations for variable products
            if ($data['product_type'] === 'variable' && $request->has('variations')) {
                $variations = $request->variations;
                if (is_string($variations)) {
                    $variations = json_decode($variations, true);
                }
                
                if (is_array($variations)) {
                    // Get existing variation IDs
                    $existingVariationIds = $product->variations()->pluck('id')->toArray();
                    $updatedVariationIds = [];
                    $seenCombinations = [];
                    
                    foreach ($variations as $index => $variationData) {
                        // Skip variations marked for deletion
                        if (isset($variationData['_delete']) && $variationData['_delete'] == '1') {
                            if (isset($variationData['id']) && !empty($variationData['id'])) {
                                // Add to deletion list
                                $updatedVariationIds[] = $variationData['id']; // Don't add to updated list
                                
                                // Delete the variation and its image
                                $variation = ProductVariation::find($variationData['id']);
                                if ($variation && $variation->product_id == $product->id) {
                                    if ($variation->image_id) {
                                        $media = Media::find($variation->image_id);
                                        if ($media) {
                                            Storage::disk('public')->delete($media->path);
                                            $media->delete();
                                        }
                                    }
                                    $variation->delete();
                                }
                            }
                            continue;
                        }
                        
                        // Convert attribute_values if it's a string
                        if (isset($variationData['attribute_values']) && is_string($variationData['attribute_values'])) {
                            $variationData['attribute_values'] = json_decode($variationData['attribute_values'], true);
                        }
                        
                        // Check if SKU already exists in database (excluding current variation if updating)
                        if (!empty($variationData['sku'])) {
                            $skuQuery = ProductVariation::where('sku', $variationData['sku']);
                            
                            // If updating existing variation, exclude it from the check
                            if (isset($variationData['id']) && !empty($variationData['id'])) {
                                $skuQuery->where('id', '!=', $variationData['id']);
                            }
                            
                            $existingSku = $skuQuery->first();
                            if ($existingSku) {
                                DB::rollBack();
                                return redirect()->back()
                                    ->withErrors(['error' => "SKU '{$variationData['sku']}' already exists. Please use a unique SKU for each variation."])
                                    ->withInput();
                            }
                        }
                        
                        // Check for duplicate combinations (skip for existing variations being updated)
                        if (isset($variationData['attribute_values'])) {
                            ksort($variationData['attribute_values']);
                            $combinationKey = json_encode($variationData['attribute_values']);
                            
                            // Only check duplicates for new variations
                            if (!isset($variationData['id']) || empty($variationData['id'])) {
                                if (in_array($combinationKey, $seenCombinations)) {
                                    Log::warning('Skipping duplicate variation combination', ['combination' => $variationData['attribute_values']]);
                                    continue;
                                }
                            }
                            
                            $seenCombinations[] = $combinationKey;
                        }
                        
                        // Ensure stock_quantity is set and not null
                        if (!isset($variationData['stock_quantity']) || $variationData['stock_quantity'] === null || $variationData['stock_quantity'] === '') {
                            $variationData['stock_quantity'] = 0;
                        }
                        
                        // Set in_stock based on stock_quantity
                        $variationData['in_stock'] = isset($variationData['stock_quantity']) && $variationData['stock_quantity'] > 0;
                        
                        // Handle variation image upload
                        if ($request->hasFile("variations.{$index}.image")) {
                            $imageFile = $request->file("variations.{$index}.image");
                            
                            // Store the image
                            $imagePath = $imageFile->store('products/variations', 'public');
                            
                            // Create media record
                            $media = Media::create([
                                'name' => 'Variation Image - ' . ($variationData['sku'] ?? 'Variation ' . ($index + 1)),
                                'file_name' => $imageFile->getClientOriginalName(),
                                'mime_type' => $imageFile->getMimeType(),
                                'path' => $imagePath,
                                'size' => $imageFile->getSize(),
                            ]);
                            
                            // If there was an old image, delete it
                            if (isset($variationData['image_id']) && !empty($variationData['image_id'])) {
                                $oldMedia = Media::find($variationData['image_id']);
                                if ($oldMedia) {
                                    Storage::disk('public')->delete($oldMedia->path);
                                    $oldMedia->delete();
                                }
                            }
                            
                            // Set the new image_id
                            $variationData['image_id'] = $media->id;
                        }
                        
                        // Handle image removal
                        if (isset($variationData['remove_image']) && $variationData['remove_image'] == '1') {
                            if (isset($variationData['image_id']) && !empty($variationData['image_id'])) {
                                $oldMedia = Media::find($variationData['image_id']);
                                if ($oldMedia) {
                                    Storage::disk('public')->delete($oldMedia->path);
                                    $oldMedia->delete();
                                }
                            }
                            $variationData['image_id'] = null;
                        }
                        
                        // Remove temporary fields that shouldn't be saved to database
                        unset($variationData['image'], $variationData['remove_image']);
                        
                        if (isset($variationData['id']) && !empty($variationData['id'])) {
                            // Update existing variation
                            $variation = ProductVariation::find($variationData['id']);
                            if ($variation && $variation->product_id == $product->id) {
                                $variation->update($variationData);
                                $updatedVariationIds[] = $variation->id;
                            }
                        } else {
                            // Create new variation
                            // Set first variation as default if no default exists
                            if (!isset($variationData['is_default'])) {
                                $variationData['is_default'] = ($index === 0 && empty($existingVariationIds));
                            }
                            
                            $newVariation = $product->variations()->create($variationData);
                            $updatedVariationIds[] = $newVariation->id;
                        }
                    }
                    
                    // Delete variations that were removed
                    $variationsToDelete = array_diff($existingVariationIds, $updatedVariationIds);
                    if (!empty($variationsToDelete)) {
                        // Delete associated images first
                        $variationsToDeleteModels = ProductVariation::whereIn('id', $variationsToDelete)->get();
                        foreach ($variationsToDeleteModels as $variationToDelete) {
                            if ($variationToDelete->image_id) {
                                $media = Media::find($variationToDelete->image_id);
                                if ($media) {
                                    Storage::disk('public')->delete($media->path);
                                    $media->delete();
                                }
                            }
                        }
                        
                        // Now delete the variations
                        ProductVariation::whereIn('id', $variationsToDelete)->delete();
                    }
                }
            }
            
            // Log the updated product
            Log::info('Product updated:', $product->toArray());
            
            DB::commit();
            
            return redirect()->route('admin.products.index')->with('success', 'Product updated successfully.');
            
        } catch (\Exception $e) {
            DB::rollBack();
            Log::error('Product update failed:', ['error' => $e->getMessage()]);
            return redirect()->back()->withErrors(['error' => 'Failed to update product: ' . $e->getMessage()])->withInput();
        }
    }

    /**
     * Remove the specified product from storage.
     */
    public function destroy(Product $product)
    {
        $this->authorize('delete', $product);
        
        $product->delete();
        
        return redirect()->route('admin.products.index')->with('success', 'Product deleted successfully.');
    }

    /**
     * Display products with low stock.
     */
    public function lowStock()
    {
        $this->authorize('viewAny', Product::class);
        
        // Get all products with their variations
        $allProducts = Product::with(['mainPhoto', 'variations'])->get();
        
        // Filter products that have low stock
        $lowStockProducts = $allProducts->filter(function ($product) {
            if ($product->isVariable()) {
                // For variable products, check if any variation has low stock
                foreach ($product->variations as $variation) {
                    $threshold = $variation->low_quantity_threshold ?? $product->low_quantity_threshold ?? 10;
                    // Include variations with 0 stock or stock <= threshold
                    if ($variation->stock_quantity <= $threshold) {
                        return true;
                    }
                }
                return false;
            } else {
                // For simple products, check if stock <= threshold
                $threshold = $product->low_quantity_threshold ?? 10;
                return $product->stock_quantity <= $threshold;
            }
        });
        
        // Paginate the filtered results
        $perPage = 10;
        $currentPage = request()->get('page', 1);
        $offset = ($currentPage - 1) * $perPage;
        
        $paginatedProducts = new \Illuminate\Pagination\LengthAwarePaginator(
            $lowStockProducts->slice($offset, $perPage)->values(),
            $lowStockProducts->count(),
            $perPage,
            $currentPage,
            ['path' => request()->url(), 'query' => request()->query()]
        );
        
        return view('admin.products.low-stock', compact('paginatedProducts'));
    }

    /**
     * Remove the specified media from storage.
     */
    public function destroyMedia(Media $media)
    {
        try {
            // Delete the file from storage
            Storage::disk('public')->delete($media->path);
            
            // Delete the media record
            $media->delete();
            
            return response()->json(['success' => true]);
        } catch (\Exception $e) {
            return response()->json(['success' => false, 'error' => $e->getMessage()], 500);
        }
    }

    /**
     * Store a newly uploaded media file.
     */
    public function storeMedia(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'file' => 'required|file|mimes:jpeg,png,jpg,gif,webp,mp4,mov,avi,wmv,mpg,ogg,webm,pdf,doc,docx,xls,xlsx,ppt,pptx,txt,csv|max:20480', // 20MB max
            'name' => 'nullable|string|max:255',
        ]);
        
        if ($validator->fails()) {
            return response()->json(['success' => false, 'errors' => $validator->errors()], 422);
        }
        
        $file = $request->file('file');
        $name = $request->name ?: $file->getClientOriginalName();
        
        // Store the file
        $path = $file->store('media', 'public');
        
        // Create media record
        $media = Media::create([
            'name' => $name,
            'file_name' => $file->getClientOriginalName(),
            'mime_type' => $file->getMimeType(),
            'path' => $path,
            'size' => $file->getSize(),
        ]);
        
        // Append URL to the media item
        $media->append('url');
        
        return response()->json(['success' => true, 'media' => $media]);
    }
    
    /**
     * Get media for the media library.
     */
    public function getMedia(Request $request)
    {
        $query = Media::query();
        
        // Apply search filter
        if ($request->has('search') && $request->search) {
            $query->where('name', 'like', '%' . $request->search . '%')
                  ->orWhere('file_name', 'like', '%' . $request->search . '%');
        }
        
        // Apply type filter
        if ($request->has('type') && $request->type && $request->type !== 'all') {
            if ($request->type === 'images') {
                $query->where('mime_type', 'like', 'image/%');
            } elseif ($request->type === 'videos') {
                $query->where('mime_type', 'like', 'video/%');
            }
        }
        
        $media = $query->latest()->paginate(20);
        
        // Append URL to each media item
        $media->getCollection()->each->append('url');
        
        return response()->json($media);
    }
    
    /**
     * Export products to CSV
     */
    public function export()
    {
        $this->authorize('viewAny', Product::class);
        
        try {
            // Get all products with their relationships
            $products = Product::with(['mainPhoto', 'variations'])->get();
            
            // Create CSV writer
            $csv = Writer::createFromString('');
            
            // Add UTF-8 BOM for Excel compatibility
            $csv->setOutputBOM(Writer::BOM_UTF8);
            
            // Add headers
            $headers = [
                'ID',
                'Name',
                'Slug',
                'Product Type',
                'Description',
                'MRP',
                'Selling Price',
                'In Stock',
                'Stock Quantity',
                'Low Quantity Threshold',
                'Status',
                'Main Photo URL',
                'Product Gallery IDs',
                'Product Categories',
                'Product Attributes',
                'Meta Title',
                'Meta Description',
                'Meta Keywords',
                'Created At',
                'Updated At'
            ];
            $csv->insertOne($headers);
            
            // Add product data
            foreach ($products as $product) {
                $row = [
                    $product->id,
                    $product->name,
                    $product->slug,
                    $product->product_type ?? 'simple',
                    $product->description ?? '',
                    $product->mrp,
                    $product->selling_price ?? '',
                    $product->in_stock ? 'Yes' : 'No',
                    $product->stock_quantity ?? 0,
                    $product->low_quantity_threshold ?? 10,
                    $product->status,
                    $product->mainPhoto ? $product->mainPhoto->url : '',
                    is_array($product->product_gallery) ? implode('|', $product->product_gallery) : '',
                    is_array($product->product_categories) ? json_encode($product->product_categories) : '',
                    is_array($product->product_attributes) ? json_encode($product->product_attributes) : '',
                    $product->meta_title ?? '',
                    $product->meta_description ?? '',
                    $product->meta_keywords ?? '',
                    $product->created_at->format('Y-m-d H:i:s'),
                    $product->updated_at->format('Y-m-d H:i:s')
                ];
                $csv->insertOne($row);
            }
            
            // Generate filename with timestamp
            $filename = 'products_export_' . date('Y-m-d_His') . '.csv';
            
            // Return CSV as download
            return response($csv->toString(), 200, [
                'Content-Type' => 'text/csv; charset=UTF-8',
                'Content-Disposition' => 'attachment; filename="' . $filename . '"',
                'Pragma' => 'no-cache',
                'Cache-Control' => 'must-revalidate, post-check=0, pre-check=0',
                'Expires' => '0'
            ]);
            
        } catch (\Exception $e) {
            Log::error('Product export failed:', ['error' => $e->getMessage()]);
            return redirect()->back()->with('error', 'Failed to export products: ' . $e->getMessage());
        }
    }
    
    /**
     * Show import form
     */
    public function importForm()
    {
        $this->authorize('create', Product::class);
        
        return view('admin.products.import');
    }
    
    /**
     * Import products from CSV
     */
    public function import(Request $request)
    {
        $this->authorize('create', Product::class);
        
        $validator = Validator::make($request->all(), [
            'file' => 'required|file|mimes:csv,txt|max:10240', // 10MB max
            'update_existing' => 'nullable|boolean'
        ]);
        
        if ($validator->fails()) {
            return redirect()->back()->withErrors($validator)->withInput();
        }
        
        // Custom validation for SKU uniqueness in update
        if ($request->has('variations')) {
            $variations = $request->variations;
            if (is_string($variations)) {
                $variations = json_decode($variations, true);
            }
            
            if (is_array($variations)) {
                foreach ($variations as $variationData) {
                    if (!empty($variationData['sku'])) {
                        $skuQuery = ProductVariation::where('sku', $variationData['sku']);
                        
                        // Exclude current variation if it has an ID
                        if (isset($variationData['id']) && !empty($variationData['id'])) {
                            $skuQuery->where('id', '!=', $variationData['id']);
                        }
                        
                        if ($skuQuery->exists()) {
                            return redirect()->back()
                                ->withErrors(['error' => "SKU '{$variationData['sku']}' already exists. Please use a unique SKU for each variation."])
                                ->withInput();
                        }
                    }
                }
            }
        }
        
        DB::beginTransaction();
        
        try {
            $file = $request->file('file');
            $updateExisting = $request->has('update_existing') && $request->update_existing;
            
            // Read CSV file
            $csv = Reader::createFromPath($file->getPathname(), 'r');
            $csv->setHeaderOffset(0);
            
            // Strip BOM if present
            $csv->skipInputBOM();
            
            $records = $csv->getRecords();
            
            $imported = 0;
            $updated = 0;
            $skipped = 0;
            $errors = [];
            
            foreach ($records as $index => $record) {
                try {
                    // Skip empty rows
                    if (empty($record['Name'])) {
                        $skipped++;
                        continue;
                    }
                    
                    // Prepare product data
                    $productData = [
                        'name' => $record['Name'],
                        'slug' => !empty($record['Slug']) ? $record['Slug'] : Str::slug($record['Name']),
                        'product_type' => $record['Product Type'] ?? 'simple',
                        'description' => $record['Description'] ?? null,
                        'mrp' => !empty($record['MRP']) ? floatval($record['MRP']) : 0,
                        'selling_price' => !empty($record['Selling Price']) ? floatval($record['Selling Price']) : null,
                        'in_stock' => isset($record['In Stock']) ? (strtolower($record['In Stock']) === 'yes' || $record['In Stock'] === '1') : true,
                        'stock_quantity' => !empty($record['Stock Quantity']) ? intval($record['Stock Quantity']) : 0,
                        'low_quantity_threshold' => !empty($record['Low Quantity Threshold']) ? intval($record['Low Quantity Threshold']) : 10,
                        'status' => $record['Status'] ?? 'draft',
                        'meta_title' => $record['Meta Title'] ?? null,
                        'meta_description' => $record['Meta Description'] ?? null,
                        'meta_keywords' => $record['Meta Keywords'] ?? null,
                    ];
                    
                    // Handle product gallery
                    if (!empty($record['Product Gallery IDs'])) {
                        $galleryIds = explode('|', $record['Product Gallery IDs']);
                        $productData['product_gallery'] = array_map('intval', array_filter($galleryIds));
                    } else {
                        $productData['product_gallery'] = [];
                    }
                    
                    // Handle product categories
                    if (!empty($record['Product Categories'])) {
                        $productData['product_categories'] = json_decode($record['Product Categories'], true) ?? [];
                    } else {
                        $productData['product_categories'] = [];
                    }
                    
                    // Handle product attributes
                    if (!empty($record['Product Attributes'])) {
                        $productData['product_attributes'] = json_decode($record['Product Attributes'], true) ?? [];
                    } else {
                        $productData['product_attributes'] = [];
                    }
                    
                    // Check if product exists (by ID or slug)
                    $existingProduct = null;
                    if (!empty($record['ID'])) {
                        $existingProduct = Product::find($record['ID']);
                    }
                    if (!$existingProduct && !empty($record['Slug'])) {
                        $existingProduct = Product::where('slug', $record['Slug'])->first();
                    }
                    
                    if ($existingProduct && $updateExisting) {
                        // Update existing product
                        $existingProduct->update($productData);
                        $updated++;
                    } elseif (!$existingProduct) {
                        // Create new product
                        Product::create($productData);
                        $imported++;
                    } else {
                        // Skip if exists and update not enabled
                        $skipped++;
                    }
                    
                } catch (\Exception $e) {
                    $errors[] = "Row " . ($index + 2) . ": " . $e->getMessage();
                    $skipped++;
                }
            }
            
            DB::commit();
            
            $message = "Import completed! Imported: {$imported}, Updated: {$updated}, Skipped: {$skipped}";
            
            if (!empty($errors)) {
                $message .= " | Errors: " . implode('; ', array_slice($errors, 0, 5));
                if (count($errors) > 5) {
                    $message .= " (and " . (count($errors) - 5) . " more)";
                }
            }
            
            return redirect()->route('admin.products.index')->with('success', $message);
            
        } catch (\Exception $e) {
            DB::rollBack();
            Log::error('Product import failed:', ['error' => $e->getMessage()]);
            return redirect()->back()->with('error', 'Failed to import products: ' . $e->getMessage());
        }
    }
    
    /**
     * Download sample CSV template
     */
    public function downloadTemplate()
    {
        $this->authorize('create', Product::class);
        
        try {
            // Create CSV writer
            $csv = Writer::createFromString('');
            
            // Add UTF-8 BOM for Excel compatibility
            $csv->setOutputBOM(Writer::BOM_UTF8);
            
            // Add headers
            $headers = [
                'ID',
                'Name',
                'Slug',
                'Product Type',
                'Description',
                'MRP',
                'Selling Price',
                'In Stock',
                'Stock Quantity',
                'Low Quantity Threshold',
                'Status',
                'Main Photo URL',
                'Product Gallery IDs',
                'Product Categories',
                'Product Attributes',
                'Meta Title',
                'Meta Description',
                'Meta Keywords',
                'Created At',
                'Updated At'
            ];
            $csv->insertOne($headers);
            
            // Add sample data
            $sampleRow = [
                '', // ID - leave empty for new products
                'Sample Product',
                'sample-product',
                'simple',
                'This is a sample product description',
                '1000.00',
                '850.00',
                'Yes',
                '100',
                '10',
                'published',
                '',
                '',
                '[]',
                '[]',
                'Sample Product - Meta Title',
                'Sample product meta description',
                'sample, product, keywords',
                '',
                ''
            ];
            $csv->insertOne($sampleRow);
            
            // Generate filename
            $filename = 'products_import_template.csv';
            
            // Return CSV as download
            return response($csv->toString(), 200, [
                'Content-Type' => 'text/csv; charset=UTF-8',
                'Content-Disposition' => 'attachment; filename="' . $filename . '"',
                'Pragma' => 'no-cache',
                'Cache-Control' => 'must-revalidate, post-check=0, pre-check=0',
                'Expires' => '0'
            ]);
            
        } catch (\Exception $e) {
            Log::error('Template download failed:', ['error' => $e->getMessage()]);
            return redirect()->back()->with('error', 'Failed to download template: ' . $e->getMessage());
        }
    }
}
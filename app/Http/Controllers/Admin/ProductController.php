<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Product;
use App\Models\Media;
use App\Models\Category;
use App\Models\SubCategory;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Log;

class ProductController extends Controller
{
    /**
     * Display a listing of the products.
     */
    public function index()
    {
        $this->authorize('viewAny', Product::class);
        
        $products = Product::with('mainPhoto')->latest()->paginate(10);
        
        // Get low stock products count for alert badge
        $lowStockCount = Product::where('in_stock', true)
            ->whereColumn('stock_quantity', '<=', 'low_quantity_threshold')
            ->count();
        
        return view('admin.products.index', compact('products', 'lowStockCount'));
    }

    /**
     * Show the form for creating a new product.
     */
    public function create()
    {
        $this->authorize('create', Product::class);
        
        // Get all active categories with their subcategories
        $categories = Category::with('subCategories')->where('is_active', true)->get();
        
        return view('admin.products.create', compact('categories'));
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
            'description' => 'nullable|string',
            'mrp' => 'required|numeric|min:0.01',
            'selling_price' => 'nullable|numeric|lt:mrp',
            'in_stock' => 'required|boolean',
            'stock_quantity' => 'nullable|integer|min:0',
            'low_quantity_threshold' => 'nullable|integer|min:0',
            'status' => 'required|in:draft,published',
            'main_photo_id' => 'nullable|integer|exists:media,id',
            'product_gallery' => 'nullable',
            'product_categories' => 'nullable|array',
            'product_categories.*.category_id' => 'required|exists:categories,id',
            'product_categories.*.subcategory_ids' => 'nullable|array',
            'product_categories.*.subcategory_ids.*' => 'nullable|exists:sub_categories,id',
            'meta_title' => 'nullable|string|max:255',
            'meta_description' => 'nullable|string|max:500',
            'meta_keywords' => 'nullable|string|max:255',
        ]);

        if ($validator->fails()) {
            return redirect()->back()->withErrors($validator)->withInput();
        }
        
        $data = $request->only([
            'name', 'description', 'mrp', 'selling_price', 'in_stock', 
            'status', 'main_photo_id', 'meta_title', 
            'meta_description', 'meta_keywords'
        ]);
        
        // Log the data that will be saved
        Log::info('Product data to be saved:', $data);
        
        // Handle stock quantity - set to 0 if not in stock or not provided
        $data['stock_quantity'] = $request->in_stock ? ($request->stock_quantity ?? 0) : 0;
        
        // Ensure stock_quantity is never null
        if (!isset($data['stock_quantity']) || is_null($data['stock_quantity'])) {
            $data['stock_quantity'] = 0;
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
        
        // Log the final data before creating the product
        Log::info('Final product data before creation:', $data);
        
        $product = Product::create($data);
        
        // Log the created product
        Log::info('Product created:', $product->toArray());
        
        return redirect()->route('admin.products.index')->with('success', 'Product created successfully.');
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
        
        // Load the main photo relationship
        $product->load('mainPhoto');
        
        // Get all active categories with their subcategories
        $categories = Category::with('subCategories')->where('is_active', true)->get();
        
        return view('admin.products.edit', compact('product', 'categories'));
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
            'description' => 'nullable|string',
            'mrp' => 'required|numeric|min:0.01',
            'selling_price' => 'nullable|numeric|lt:mrp',
            'in_stock' => 'required|boolean',
            'stock_quantity' => 'nullable|integer|min:0',
            'low_quantity_threshold' => 'nullable|integer|min:0',
            'status' => 'required|in:draft,published',
            'main_photo_id' => 'nullable|integer|exists:media,id',
            'product_gallery' => 'nullable',
            'product_categories' => 'nullable|array',
            'product_categories.*.category_id' => 'required|exists:categories,id',
            'product_categories.*.subcategory_ids' => 'nullable|array',
            'product_categories.*.subcategory_ids.*' => 'nullable|exists:sub_categories,id',
            'meta_title' => 'nullable|string|max:255',
            'meta_description' => 'nullable|string|max:500',
            'meta_keywords' => 'nullable|string|max:255',
        ]);

        if ($validator->fails()) {
            return redirect()->back()->withErrors($validator)->withInput();
        }
        
        $data = $request->only([
            'name', 'description', 'mrp', 'selling_price', 'in_stock', 
            'status', 'main_photo_id', 'meta_title', 
            'meta_description', 'meta_keywords'
        ]);
        
        // Log the data that will be saved
        Log::info('Product data to be updated:', $data);
        
        // Handle stock quantity - set to 0 if not in stock or not provided
        $data['stock_quantity'] = $request->in_stock ? ($request->stock_quantity ?? 0) : 0;
        
        // Ensure stock_quantity is never null
        if (!isset($data['stock_quantity']) || is_null($data['stock_quantity'])) {
            $data['stock_quantity'] = 0;
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
        
        // Log the final data before updating the product
        Log::info('Final product data before update:', $data);
        
        $product->update($data);
        
        // Log the updated product
        Log::info('Product updated:', $product->toArray());
        
        return redirect()->route('admin.products.index')->with('success', 'Product updated successfully.');
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
        
        $products = Product::with('mainPhoto')
            ->where('in_stock', true)
            ->whereColumn('stock_quantity', '<=', 'low_quantity_threshold')
            ->latest()
            ->paginate(10);
        
        return view('admin.products.low-stock', compact('products'));
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
}
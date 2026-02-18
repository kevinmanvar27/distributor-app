<?php

namespace App\Http\Controllers\API;

use App\Models\Product;
use App\Models\ProductVariation;
use App\Models\ProductView;
use App\Models\Wishlist;
use App\Services\GeoLocationService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;

/**
 * @OA\Tag(
 *     name="Products",
 *     description="API Endpoints for Product Management"
 * )
 */
class ProductController extends ApiController
{
    /**
     * Display a listing of the resource.
     *
     * @OA\Get(
     *      path="/api/v1/products",
     *      operationId="getProductsList",
     *      tags={"Products"},
     *      summary="Get list of products",
     *      description="Returns list of products with pagination",
     *      @OA\Parameter(
     *          name="page",
     *          description="Page number",
     *          required=false,
     *          in="query",
     *          @OA\Schema(
     *              type="integer"
     *          )
     *      ),
     *      @OA\Response(
     *          response=200,
     *          description="Successful operation",
     *       ),
     *      @OA\Response(
     *          response=401,
     *          description="Unauthenticated"
     *      ),
     *      @OA\Response(
     *          response=403,
     *          description="Forbidden"
     *      )
     *     )
     */
    public function index(Request $request)
    {
        // Filter by published status only (same as web flow)
        $products = Product::where('status', 'published')
            ->with(['mainPhoto', 'variations.image'])
            ->paginate(15);

        // Add discounted price for each product
        $user = $request->user();
        $products->getCollection()->transform(function ($product) use ($user) {
            // For simple products, calculate discounted price
            if ($product->isSimple()) {
                $priceToUse = (!is_null($product->selling_price) && $product->selling_price !== '' && $product->selling_price >= 0) 
                    ? $product->selling_price 
                    : $product->mrp;
                
                $product->discounted_price = function_exists('calculateDiscountedPrice') 
                    ? calculateDiscountedPrice($priceToUse, $user) 
                    : $priceToUse;
            } else {
                // For variable products, add price range
                $product->price_range = $product->price_range;
                
                // Add discounted prices to variations
                if ($product->variations) {
                    $product->variations->transform(function ($variation) use ($user) {
                        $priceToUse = (!is_null($variation->selling_price) && $variation->selling_price !== '' && $variation->selling_price >= 0) 
                            ? $variation->selling_price 
                            : $variation->mrp;
                        
                        $variation->discounted_price = function_exists('calculateDiscountedPrice') 
                            ? calculateDiscountedPrice($priceToUse, $user) 
                            : $priceToUse;
                        
                        // Add formatted attributes
                        $variation->formatted_attributes = $variation->formatted_attributes;
                        
                        // Ensure image URL is included
                        if ($variation->image) {
                            $variation->image_url = $variation->image->url;
                        }
                        
                        return $variation;
                    });
                }
            }
            
            return $product;
        });

        return $this->sendResponse($products, 'Products retrieved successfully.');
    }

    /**
     * Store a newly created resource in storage.
     *
     * @OA\Post(
     *      path="/api/v1/products",
     *      operationId="storeProduct",
     *      tags={"Products"},
     *      summary="Store new product",
     *      description="Returns product data",
     *      security={{"sanctum": {}}},
     *      @OA\RequestBody(
     *          required=true,
     *          @OA\JsonContent(
     *              required={"name","mrp","in_stock","status"},
     *              @OA\Property(property="name", type="string", example="Smartphone"),
     *              @OA\Property(property="description", type="string", example="Latest smartphone model"),
     *              @OA\Property(property="mrp", type="number", format="float", example=599.99),
     *              @OA\Property(property="selling_price", type="number", format="float", example=499.99),
     *              @OA\Property(property="in_stock", type="boolean", example=true),
     *              @OA\Property(property="stock_quantity", type="integer", example=100),
     *              @OA\Property(property="status", type="string", example="published"),
     *              @OA\Property(property="main_photo_id", type="integer", example=1),
     *              @OA\Property(property="product_gallery", type="array", @OA\Items(type="integer")),
     *              @OA\Property(property="product_categories", type="array", @OA\Items(type="object")),
     *              @OA\Property(property="meta_title", type="string", example="Smartphone"),
     *              @OA\Property(property="meta_description", type="string", example="Latest smartphone model"),
     *              @OA\Property(property="meta_keywords", type="string", example="smartphone, electronics"),
     *          ),
     *      ),
     *      @OA\Response(
     *          response=201,
     *          description="Successful operation",
     *       ),
     *      @OA\Response(
     *          response=400,
     *          description="Bad Request"
     *      ),
     *      @OA\Response(
     *          response=401,
     *          description="Unauthenticated"
     *      ),
     *      @OA\Response(
     *          response=403,
     *          description="Forbidden"
     *      )
     * )
     */
    public function store(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'mrp' => 'required|numeric|min:0.01',
            'selling_price' => 'nullable|numeric|lt:mrp',
            'in_stock' => 'required|boolean',
            'stock_quantity' => 'nullable|integer|min:0',
            'status' => 'required|in:draft,published',
            'main_photo_id' => 'nullable|integer|exists:media,id',
            'product_gallery' => 'nullable|array',
            'product_categories' => 'nullable|array',
            'meta_title' => 'nullable|string|max:255',
            'meta_description' => 'nullable|string|max:500',
            'meta_keywords' => 'nullable|string|max:255',
        ]);

        $product = Product::create($request->all());

        return $this->sendResponse($product, 'Product created successfully.', 201);
    }

    /**
     * Display the specified resource.
     *
     * @OA\Get(
     *      path="/api/v1/products/{id}",
     *      operationId="getProductById",
     *      tags={"Products"},
     *      summary="Get product information",
     *      description="Returns detailed product data including main photo, gallery, related products, wishlist status, and user-specific pricing",
     *      security={{"bearerAuth": {}}},
     *      @OA\Parameter(
     *          name="id",
     *          description="Product id",
     *          required=true,
     *          in="path",
     *          @OA\Schema(
     *              type="integer"
     *          )
     *      ),
     *      @OA\Response(
     *          response=200,
     *          description="Successful operation",
     *          @OA\JsonContent(
     *              @OA\Property(property="success", type="boolean", example=true),
     *              @OA\Property(property="message", type="string", example="Product retrieved successfully."),
     *              @OA\Property(
     *                  property="data",
     *                  type="object",
     *                  @OA\Property(property="id", type="integer", example=1),
     *                  @OA\Property(property="name", type="string", example="Sample Product"),
     *                  @OA\Property(property="slug", type="string", example="sample-product"),
     *                  @OA\Property(property="description", type="string", example="Product description"),
     *                  @OA\Property(property="mrp", type="number", format="float", example=100.00),
     *                  @OA\Property(property="selling_price", type="number", format="float", example=90.00),
     *                  @OA\Property(property="discounted_price", type="number", format="float", example=85.00, description="User-specific discounted price"),
     *                  @OA\Property(property="in_stock", type="boolean", example=true),
     *                  @OA\Property(property="stock_quantity", type="integer", example=50),
     *                  @OA\Property(property="status", type="string", example="published"),
     *                  @OA\Property(property="product_categories", type="array", @OA\Items(type="integer"), example={1, 2}),
     *                  @OA\Property(
     *                      property="main_photo",
     *                      type="object",
     *                      nullable=true,
     *                      @OA\Property(property="id", type="integer", example=1),
     *                      @OA\Property(property="url", type="string", example="https://example.com/photo.jpg")
     *                  ),
     *                  @OA\Property(
     *                      property="gallery_photos",
     *                      type="array",
     *                      @OA\Items(
     *                          type="object",
     *                          @OA\Property(property="id", type="integer", example=2),
     *                          @OA\Property(property="url", type="string", example="https://example.com/gallery1.jpg")
     *                      )
     *                  ),
     *                  @OA\Property(property="is_in_wishlist", type="boolean", example=false),
     *                  @OA\Property(
     *                      property="stock_status",
     *                      type="object",
     *                      @OA\Property(property="available", type="boolean", example=true),
     *                      @OA\Property(property="quantity", type="integer", example=50),
     *                      @OA\Property(property="label", type="string", example="In Stock")
     *                  ),
     *                  @OA\Property(
     *                      property="related_products",
     *                      type="array",
     *                      @OA\Items(
     *                          type="object",
     *                          @OA\Property(property="id", type="integer", example=2),
     *                          @OA\Property(property="name", type="string", example="Related Product"),
     *                          @OA\Property(property="slug", type="string", example="related-product"),
     *                          @OA\Property(property="mrp", type="number", format="float", example=80.00),
     *                          @OA\Property(property="selling_price", type="number", format="float", example=75.00),
     *                          @OA\Property(property="discounted_price", type="number", format="float", example=70.00),
     *                          @OA\Property(property="in_stock", type="boolean", example=true),
     *                          @OA\Property(
     *                              property="main_photo",
     *                              type="object",
     *                              nullable=true,
     *                              @OA\Property(property="id", type="integer", example=3),
     *                              @OA\Property(property="url", type="string", example="https://example.com/related.jpg")
     *                          )
     *                      )
     *                  )
     *              )
     *          )
     *      ),
     *      @OA\Response(
     *          response=400,
     *          description="Bad Request"
     *      ),
     *      @OA\Response(
     *          response=404,
     *          description="Product not found",
     *          @OA\JsonContent(
     *              @OA\Property(property="success", type="boolean", example=false),
     *              @OA\Property(property="message", type="string", example="Product not found.")
     *          )
     *      )
     * )
     */
    public function show($id)
    {
        $product = Product::with(['mainPhoto', 'variations.image'])->find($id);

        if (is_null($product)) {
            return $this->sendError('Product not found.');
        }

        // Track product view from mobile application
        $this->trackProductView($product, request());

        // Get authenticated user (may be null for public access)
        $user = auth('sanctum')->user();

        // Convert product to array for modification
        $productData = $product->toArray();

        // Add gallery photos
        $productData['gallery_photos'] = $product->gallery_photos ?? [];

        // Handle pricing based on product type
        if ($product->isSimple()) {
            // Simple product - add single discounted price
            $basePrice = $product->selling_price ?? $product->mrp;
            $productData['discounted_price'] = $user 
                ? calculateDiscountedPrice($basePrice, $user) 
                : $basePrice;
        } else {
            // Variable product - add price range and variations with discounted prices
            $productData['price_range'] = $product->price_range;
            
            // Add discounted prices to variations
            if ($product->variations && $product->variations->count() > 0) {
                $productData['variations'] = $product->variations->map(function ($variation) use ($user) {
                    $variationData = $variation->toArray();
                    
                    $basePrice = $variation->selling_price ?? $variation->mrp;
                    $variationData['discounted_price'] = $user 
                        ? calculateDiscountedPrice($basePrice, $user) 
                        : $basePrice;
                    
                    // Add formatted attributes
                    $variationData['formatted_attributes'] = $variation->formatted_attributes;
                    $variationData['display_name'] = $variation->display_name;
                    
                    // Ensure image URL is included
                    if ($variation->image) {
                        $variationData['image_url'] = $variation->image->url;
                    }
                    
                    return $variationData;
                })->toArray();
            }
        }

        // Add wishlist status (only if authenticated)
        $productData['is_in_wishlist'] = $user 
            ? Wishlist::where('user_id', $user->id)->where('product_id', $product->id)->exists() 
            : false;

        // Add stock status
        if ($product->isVariable()) {
            // For variable products, check if any variation is in stock
            $totalStock = $product->variations->sum('stock_quantity');
            $hasStock = $product->variations->where('in_stock', true)->where('stock_quantity', '>', 0)->count() > 0;
            
            $productData['stock_status'] = [
                'available' => $hasStock,
                'quantity' => $totalStock,
                'label' => $hasStock ? 'In Stock' : 'Out of Stock',
            ];
        } else {
            // Simple product stock status
            $productData['stock_status'] = [
                'available' => $product->in_stock && ($product->stock_quantity === null || $product->stock_quantity > 0),
                'quantity' => $product->stock_quantity,
                'label' => $this->getStockLabel($product),
            ];
        }

        // Get related products from same category
        $productData['related_products'] = $this->getRelatedProducts($product, $user);

        return $this->sendResponse($productData, 'Product retrieved successfully.');
    }

    /**
     * Get stock status label for a product.
     *
     * @param Product $product
     * @return string
     */
    private function getStockLabel(Product $product): string
    {
        if (!$product->in_stock) {
            return 'Out of Stock';
        }

        if ($product->stock_quantity === null) {
            return 'In Stock';
        }

        if ($product->stock_quantity <= 0) {
            return 'Out of Stock';
        }

        if ($product->stock_quantity <= 5) {
            return 'Low Stock - Only ' . $product->stock_quantity . ' left';
        }

        return 'In Stock';
    }

    /**
     * Get related products from the same category.
     *
     * @param Product $product
     * @param User|null $user
     * @return array
     */
    private function getRelatedProducts(Product $product, $user = null): array
    {
        // Get product categories
        $categories = $product->product_categories ?? [];

        if (empty($categories)) {
            return [];
        }

        // Find products in the same categories, excluding current product
        $relatedProducts = Product::with(['mainPhoto', 'variations.image'])
            ->where('id', '!=', $product->id)
            ->where('status', 'published')
            ->where('in_stock', true)
            ->where(function ($query) use ($categories) {
                foreach ($categories as $categoryId) {
                    $query->orWhereJsonContains('product_categories', $categoryId);
                }
            })
            ->orderBy('updated_at', 'desc')
            ->limit(6)
            ->get();

        // Add discounted prices to related products
        return $relatedProducts->map(function ($relatedProduct) use ($user) {
            $data = [
                'id' => $relatedProduct->id,
                'name' => $relatedProduct->name,
                'slug' => $relatedProduct->slug,
                'product_type' => $relatedProduct->product_type,
                'mrp' => $relatedProduct->mrp,
                'selling_price' => $relatedProduct->selling_price,
                'in_stock' => $relatedProduct->in_stock,
                'main_photo' => $relatedProduct->mainPhoto,
            ];

            // Handle pricing based on product type
            if ($relatedProduct->isSimple()) {
                // Simple product - add single discounted price
                $basePrice = $relatedProduct->selling_price ?? $relatedProduct->mrp;
                $data['discounted_price'] = $user 
                    ? calculateDiscountedPrice($basePrice, $user) 
                    : $basePrice;
            } else {
                // Variable product - add price range
                $data['price_range'] = $relatedProduct->price_range;
                
                // Optionally include variations for related products (limited info)
                if ($relatedProduct->variations && $relatedProduct->variations->count() > 0) {
                    $data['has_variations'] = true;
                    $data['variations_count'] = $relatedProduct->variations->count();
                }
            }

            return $data;
        })->toArray();
    }

    /**
     * Update the specified resource in storage.
     *
     * @OA\Put(
     *      path="/api/v1/products/{id}",
     *      operationId="updateProduct",
     *      tags={"Products"},
     *      summary="Update existing product",
     *      description="Returns updated product data",
     *      security={{"sanctum": {}}},
     *      @OA\Parameter(
     *          name="id",
     *          description="Product id",
     *          required=true,
     *          in="path",
     *          @OA\Schema(
     *              type="integer"
     *          )
     *      ),
     *      @OA\RequestBody(
     *          required=true,
     *          @OA\JsonContent(
     *              required={"name","mrp","in_stock","status"},
     *              @OA\Property(property="name", type="string", example="Smartphone"),
     *              @OA\Property(property="description", type="string", example="Latest smartphone model"),
     *              @OA\Property(property="mrp", type="number", format="float", example=599.99),
     *              @OA\Property(property="selling_price", type="number", format="float", example=499.99),
     *              @OA\Property(property="in_stock", type="boolean", example=true),
     *              @OA\Property(property="stock_quantity", type="integer", example=100),
     *              @OA\Property(property="status", type="string", example="published"),
     *              @OA\Property(property="main_photo_id", type="integer", example=1),
     *              @OA\Property(property="product_gallery", type="array", @OA\Items(type="integer")),
     *              @OA\Property(property="product_categories", type="array", @OA\Items(type="object")),
     *              @OA\Property(property="meta_title", type="string", example="Smartphone"),
     *              @OA\Property(property="meta_description", type="string", example="Latest smartphone model"),
     *              @OA\Property(property="meta_keywords", type="string", example="smartphone, electronics"),
     *          ),
     *      ),
     *      @OA\Response(
     *          response=200,
     *          description="Successful operation",
     *       ),
     *      @OA\Response(
     *          response=400,
     *          description="Bad Request"
     *      ),
     *      @OA\Response(
     *          response=401,
     *          description="Unauthenticated"
     *      ),
     *      @OA\Response(
     *          response=403,
     *          description="Forbidden"
     *      ),
     *      @OA\Response(
     *          response=404,
     *          description="Not Found"
     *      )
     * )
     */
    public function update(Request $request, $id)
    {
        $product = Product::find($id);

        if (is_null($product)) {
            return $this->sendError('Product not found.');
        }

        $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'mrp' => 'required|numeric|min:0.01',
            'selling_price' => 'nullable|numeric|lt:mrp',
            'in_stock' => 'required|boolean',
            'stock_quantity' => 'nullable|integer|min:0',
            'status' => 'required|in:draft,published',
            'main_photo_id' => 'nullable|integer|exists:media,id',
            'product_gallery' => 'nullable|array',
            'product_categories' => 'nullable|array',
            'meta_title' => 'nullable|string|max:255',
            'meta_description' => 'nullable|string|max:500',
            'meta_keywords' => 'nullable|string|max:255',
        ]);

        $product->update($request->all());

        return $this->sendResponse($product, 'Product updated successfully.');
    }

    /**
     * Remove the specified resource from storage.
     *
     * @OA\Delete(
     *      path="/api/v1/products/{id}",
     *      operationId="deleteProduct",
     *      tags={"Products"},
     *      summary="Delete product",
     *      description="Deletes a product",
     *      security={{"sanctum": {}}},
     *      @OA\Parameter(
     *          name="id",
     *          description="Product id",
     *          required=true,
     *          in="path",
     *          @OA\Schema(
     *              type="integer"
     *          )
     *      ),
     *      @OA\Response(
     *          response=200,
     *          description="Successful operation",
     *       ),
     *      @OA\Response(
     *          response=401,
     *          description="Unauthenticated"
     *      ),
     *      @OA\Response(
     *          response=403,
     *          description="Forbidden"
     *      ),
     *      @OA\Response(
     *          response=404,
     *          description="Not Found"
     *      )
     * )
     */
    public function destroy($id)
    {
        $product = Product::find($id);

        if (is_null($product)) {
            return $this->sendError('Product not found.');
        }

        $product->delete();

        return $this->sendResponse(null, 'Product deleted successfully.');
    }

    /**
     * Track product view from mobile application
     *
     * @param Product $product
     * @param Request $request
     * @return void
     */
    private function trackProductView(Product $product, Request $request)
    {
        try {
            // Get or create session ID
            $sessionId = $request->header('X-Session-ID') ?? session()->getId();
            $userAgent = $request->userAgent();
            $ipAddress = $request->ip();
            
            // Prevent duplicate views from same session within 30 minutes
            $recentView = ProductView::where('product_id', $product->id)
                ->where('session_id', $sessionId)
                ->where('created_at', '>=', now()->subMinutes(30))
                ->exists();
            
            if (!$recentView) {
                // Get location data from IP
                $location = GeoLocationService::getLocation($ipAddress);
                
                ProductView::create([
                    'product_id' => $product->id,
                    'user_id' => auth('sanctum')->id(),
                    'session_id' => $sessionId,
                    'ip_address' => $ipAddress,
                    'user_agent' => $userAgent,
                    'referrer' => $request->header('referer'),
                    'device_type' => ProductView::detectDeviceType($userAgent),
                    'browser' => ProductView::detectBrowser($userAgent),
                    'source' => 'application', // Track that this view came from mobile app
                    'country' => $location['country'],
                    'country_code' => $location['country_code'],
                    'region' => $location['region'],
                    'city' => $location['city'],
                    'latitude' => $location['latitude'],
                    'longitude' => $location['longitude'],
                ]);
            }
        } catch (\Exception $e) {
            // Silently fail - don't break API response if tracking fails
            Log::error('Product view tracking failed (API): ' . $e->getMessage());
        }
    }
}
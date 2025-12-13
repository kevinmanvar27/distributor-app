<?php

namespace App\Http\Controllers\API;

use App\Models\Product;
use App\Models\Category;
use App\Models\SubCategory;
use Illuminate\Http\Request;

/**
 * @OA\Tag(
 *     name="Product Search",
 *     description="API Endpoints for Product Search and Filtering"
 * )
 */
class ProductSearchController extends ApiController
{
    /**
     * Search products by name or description
     * 
     * @OA\Get(
     *      path="/api/v1/products/search",
     *      operationId="searchProducts",
     *      tags={"Product Search"},
     *      summary="Search products",
     *      description="Search products by name or description",
     *      security={{"sanctum": {}}},
     *      @OA\Parameter(
     *          name="q",
     *          description="Search query",
     *          required=true,
     *          in="query",
     *          @OA\Schema(type="string")
     *      ),
     *      @OA\Parameter(
     *          name="page",
     *          description="Page number",
     *          required=false,
     *          in="query",
     *          @OA\Schema(type="integer")
     *      ),
     *      @OA\Parameter(
     *          name="per_page",
     *          description="Items per page (default: 15, max: 50)",
     *          required=false,
     *          in="query",
     *          @OA\Schema(type="integer")
     *      ),
     *      @OA\Parameter(
     *          name="sort_by",
     *          description="Sort field (name, mrp, created_at)",
     *          required=false,
     *          in="query",
     *          @OA\Schema(type="string")
     *      ),
     *      @OA\Parameter(
     *          name="sort_order",
     *          description="Sort order (asc, desc)",
     *          required=false,
     *          in="query",
     *          @OA\Schema(type="string")
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
     *          response=422,
     *          description="Validation error"
     *      )
     * )
     * 
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function search(Request $request)
    {
        $request->validate([
            'q' => 'required|string|min:1|max:255',
            'per_page' => 'nullable|integer|min:1|max:50',
            'sort_by' => 'nullable|string|in:name,mrp,created_at',
            'sort_order' => 'nullable|string|in:asc,desc',
        ]);

        $query = $request->q;
        $perPage = $request->per_page ?? 15;
        $sortBy = $request->sort_by ?? 'name';
        $sortOrder = $request->sort_order ?? 'asc';

        $products = Product::where(function ($q) use ($query) {
                $q->where('name', 'like', "%{$query}%")
                  ->orWhere('description', 'like', "%{$query}%")
                  ->orWhere('sku', 'like', "%{$query}%");
            })
            ->whereIn('status', ['active', 'published'])
            ->with(['mainPhoto', 'category', 'subCategory'])
            ->orderBy($sortBy, $sortOrder)
            ->paginate($perPage);

        // Add discounted price for each product
        $user = $request->user();
        $products->getCollection()->transform(function ($product) use ($user) {
            $priceToUse = (!is_null($product->selling_price) && $product->selling_price !== '' && $product->selling_price >= 0) 
                ? $product->selling_price 
                : $product->mrp;
            
            $product->discounted_price = function_exists('calculateDiscountedPrice') 
                ? calculateDiscountedPrice($priceToUse, $user) 
                : $priceToUse;
            
            return $product;
        });

        return $this->sendResponse($products, 'Products retrieved successfully.');
    }

    /**
     * Get products by category
     * 
     * @OA\Get(
     *      path="/api/v1/products/by-category/{categoryId}",
     *      operationId="getProductsByCategory",
     *      tags={"Product Search"},
     *      summary="Get products by category",
     *      description="Get all products in a specific category",
     *      security={{"sanctum": {}}},
     *      @OA\Parameter(
     *          name="categoryId",
     *          description="Category id",
     *          required=true,
     *          in="path",
     *          @OA\Schema(type="integer")
     *      ),
     *      @OA\Parameter(
     *          name="page",
     *          description="Page number",
     *          required=false,
     *          in="query",
     *          @OA\Schema(type="integer")
     *      ),
     *      @OA\Parameter(
     *          name="per_page",
     *          description="Items per page (default: 15, max: 50)",
     *          required=false,
     *          in="query",
     *          @OA\Schema(type="integer")
     *      ),
     *      @OA\Parameter(
     *          name="sort_by",
     *          description="Sort field (name, mrp, created_at)",
     *          required=false,
     *          in="query",
     *          @OA\Schema(type="string")
     *      ),
     *      @OA\Parameter(
     *          name="sort_order",
     *          description="Sort order (asc, desc)",
     *          required=false,
     *          in="query",
     *          @OA\Schema(type="string")
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
     *          response=404,
     *          description="Category not found"
     *      )
     * )
     * 
     * @param Request $request
     * @param int $categoryId
     * @return \Illuminate\Http\JsonResponse
     */
    public function byCategory(Request $request, $categoryId)
    {
        $category = Category::find($categoryId);

        if (!$category) {
            return $this->sendError('Category not found.', [], 404);
        }

        $perPage = $request->per_page ?? 15;
        $perPage = min($perPage, 50);
        $sortBy = $request->sort_by ?? 'name';
        $sortOrder = $request->sort_order ?? 'asc';

        $products = Product::where('category_id', $categoryId)
            ->whereIn('status', ['active', 'published'])
            ->with(['mainPhoto', 'category', 'subCategory'])
            ->orderBy($sortBy, $sortOrder)
            ->paginate($perPage);

        // Add discounted price for each product
        $user = $request->user();
        $products->getCollection()->transform(function ($product) use ($user) {
            $priceToUse = (!is_null($product->selling_price) && $product->selling_price !== '' && $product->selling_price >= 0) 
                ? $product->selling_price 
                : $product->mrp;
            
            $product->discounted_price = function_exists('calculateDiscountedPrice') 
                ? calculateDiscountedPrice($priceToUse, $user) 
                : $priceToUse;
            
            return $product;
        });

        return $this->sendResponse([
            'category' => $category,
            'products' => $products,
        ], 'Products retrieved successfully.');
    }

    /**
     * Get products by subcategory
     * 
     * @OA\Get(
     *      path="/api/v1/products/by-subcategory/{subcategoryId}",
     *      operationId="getProductsBySubcategory",
     *      tags={"Product Search"},
     *      summary="Get products by subcategory",
     *      description="Get all products in a specific subcategory",
     *      security={{"sanctum": {}}},
     *      @OA\Parameter(
     *          name="subcategoryId",
     *          description="Subcategory id",
     *          required=true,
     *          in="path",
     *          @OA\Schema(type="integer")
     *      ),
     *      @OA\Parameter(
     *          name="page",
     *          description="Page number",
     *          required=false,
     *          in="query",
     *          @OA\Schema(type="integer")
     *      ),
     *      @OA\Parameter(
     *          name="per_page",
     *          description="Items per page (default: 15, max: 50)",
     *          required=false,
     *          in="query",
     *          @OA\Schema(type="integer")
     *      ),
     *      @OA\Parameter(
     *          name="sort_by",
     *          description="Sort field (name, mrp, created_at)",
     *          required=false,
     *          in="query",
     *          @OA\Schema(type="string")
     *      ),
     *      @OA\Parameter(
     *          name="sort_order",
     *          description="Sort order (asc, desc)",
     *          required=false,
     *          in="query",
     *          @OA\Schema(type="string")
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
     *          response=404,
     *          description="Subcategory not found"
     *      )
     * )
     * 
     * @param Request $request
     * @param int $subcategoryId
     * @return \Illuminate\Http\JsonResponse
     */
    public function bySubcategory(Request $request, $subcategoryId)
    {
        $subcategory = SubCategory::with('category')->find($subcategoryId);

        if (!$subcategory) {
            return $this->sendError('Subcategory not found.', [], 404);
        }

        $perPage = $request->per_page ?? 15;
        $perPage = min($perPage, 50);
        $sortBy = $request->sort_by ?? 'name';
        $sortOrder = $request->sort_order ?? 'asc';

        $products = Product::where('sub_category_id', $subcategoryId)
            ->whereIn('status', ['active', 'published'])
            ->with(['mainPhoto', 'category', 'subCategory'])
            ->orderBy($sortBy, $sortOrder)
            ->paginate($perPage);

        // Add discounted price for each product
        $user = $request->user();
        $products->getCollection()->transform(function ($product) use ($user) {
            $priceToUse = (!is_null($product->selling_price) && $product->selling_price !== '' && $product->selling_price >= 0) 
                ? $product->selling_price 
                : $product->mrp;
            
            $product->discounted_price = function_exists('calculateDiscountedPrice') 
                ? calculateDiscountedPrice($priceToUse, $user) 
                : $priceToUse;
            
            return $product;
        });

        return $this->sendResponse([
            'subcategory' => $subcategory,
            'products' => $products,
        ], 'Products retrieved successfully.');
    }

    /**
     * Get subcategories by category
     * 
     * @OA\Get(
     *      path="/api/v1/categories/{id}/subcategories",
     *      operationId="getSubcategoriesByCategory",
     *      tags={"Product Search"},
     *      summary="Get subcategories by category",
     *      description="Get all subcategories in a specific category",
     *      security={{"sanctum": {}}},
     *      @OA\Parameter(
     *          name="id",
     *          description="Category id",
     *          required=true,
     *          in="path",
     *          @OA\Schema(type="integer")
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
     *          response=404,
     *          description="Category not found"
     *      )
     * )
     * 
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function subcategoriesByCategory($id)
    {
        $category = Category::find($id);

        if (!$category) {
            return $this->sendError('Category not found.', [], 404);
        }

        $subcategories = SubCategory::where('category_id', $id)
            ->where('is_active', true)
            ->withCount(['products' => function ($query) {
                $query->whereIn('status', ['active', 'published']);
            }])
            ->orderBy('name')
            ->get();

        return $this->sendResponse([
            'category' => $category,
            'subcategories' => $subcategories,
        ], 'Subcategories retrieved successfully.');
    }
}

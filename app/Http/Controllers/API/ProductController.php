<?php

namespace App\Http\Controllers\API;

use App\Models\Product;
use Illuminate\Http\Request;

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
    public function index()
    {
        $products = Product::with('mainPhoto')->paginate(15);
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
     *      description="Returns product data",
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
     *          response=400,
     *          description="Bad Request"
     *      ),
     *      @OA\Response(
     *          response=404,
     *          description="Not Found"
     *      )
     * )
     */
    public function show($id)
    {
        $product = Product::with('mainPhoto')->find($id);

        if (is_null($product)) {
            return $this->sendError('Product not found.');
        }

        return $this->sendResponse($product, 'Product retrieved successfully.');
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
}
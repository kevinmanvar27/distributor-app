<?php

namespace App\Http\Controllers\API;

use App\Models\Category;
use Illuminate\Http\Request;

/**
 * @OA\Tag(
 *     name="Categories",
 *     description="API Endpoints for Category Management"
 * )
 */
class CategoryController extends ApiController
{
    /**
     * Display a listing of the resource.
     *
     * @OA\Get(
     *      path="/api/v1/categories",
     *      operationId="getCategoriesList",
     *      tags={"Categories"},
     *      summary="Get list of categories",
     *      description="Returns list of categories with pagination",
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
        $categories = Category::with('subCategories')->paginate(15);
        return $this->sendResponse($categories, 'Categories retrieved successfully.');
    }

    /**
     * Store a newly created resource in storage.
     *
     * @OA\Post(
     *      path="/api/v1/categories",
     *      operationId="storeCategory",
     *      tags={"Categories"},
     *      summary="Store new category",
     *      description="Returns category data",
     *      security={{"sanctum": {}}},
     *      @OA\RequestBody(
     *          required=true,
     *          @OA\JsonContent(
     *              required={"name","is_active"},
     *              @OA\Property(property="name", type="string", example="Electronics"),
     *              @OA\Property(property="description", type="string", example="Electronic products"),
     *              @OA\Property(property="image_id", type="integer", example=1),
     *              @OA\Property(property="is_active", type="boolean", example=true),
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
            'image_id' => 'nullable|integer|exists:media,id',
            'is_active' => 'required|boolean',
        ]);

        $category = Category::create($request->all());

        return $this->sendResponse($category, 'Category created successfully.', 201);
    }

    /**
     * Display the specified resource.
     *
     * @OA\Get(
     *      path="/api/v1/categories/{id}",
     *      operationId="getCategoryById",
     *      tags={"Categories"},
     *      summary="Get category information",
     *      description="Returns category data",
     *      @OA\Parameter(
     *          name="id",
     *          description="Category id",
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
        $category = Category::with('subCategories')->find($id);

        if (is_null($category)) {
            return $this->sendError('Category not found.');
        }

        return $this->sendResponse($category, 'Category retrieved successfully.');
    }

    /**
     * Update the specified resource in storage.
     *
     * @OA\Put(
     *      path="/api/v1/categories/{id}",
     *      operationId="updateCategory",
     *      tags={"Categories"},
     *      summary="Update existing category",
     *      description="Returns updated category data",
     *      security={{"sanctum": {}}},
     *      @OA\Parameter(
     *          name="id",
     *          description="Category id",
     *          required=true,
     *          in="path",
     *          @OA\Schema(
     *              type="integer"
     *          )
     *      ),
     *      @OA\RequestBody(
     *          required=true,
     *          @OA\JsonContent(
     *              required={"name","is_active"},
     *              @OA\Property(property="name", type="string", example="Electronics"),
     *              @OA\Property(property="description", type="string", example="Electronic products"),
     *              @OA\Property(property="image_id", type="integer", example=1),
     *              @OA\Property(property="is_active", type="boolean", example=true),
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
        $category = Category::find($id);

        if (is_null($category)) {
            return $this->sendError('Category not found.');
        }

        $request->validate([
            'name' => 'required|string|max:255',
            'description' => 'nullable|string',
            'image_id' => 'nullable|integer|exists:media,id',
            'is_active' => 'required|boolean',
        ]);

        $category->update($request->all());

        return $this->sendResponse($category, 'Category updated successfully.');
    }

    /**
     * Remove the specified resource from storage.
     *
     * @OA\Delete(
     *      path="/api/v1/categories/{id}",
     *      operationId="deleteCategory",
     *      tags={"Categories"},
     *      summary="Delete category",
     *      description="Deletes a category",
     *      security={{"sanctum": {}}},
     *      @OA\Parameter(
     *          name="id",
     *          description="Category id",
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
        $category = Category::find($id);

        if (is_null($category)) {
            return $this->sendError('Category not found.');
        }

        $category->delete();

        return $this->sendResponse(null, 'Category deleted successfully.');
    }
}
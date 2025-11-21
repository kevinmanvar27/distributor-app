<?php

namespace App\Http\Controllers\API;

use App\Models\ShoppingCartItem;
use Illuminate\Http\Request;

/**
 * @OA\Tag(
 *     name="Shopping Cart",
 *     description="API Endpoints for Shopping Cart Management"
 * )
 */
class ShoppingCartController extends ApiController
{
    /**
     * Display a listing of the resource.
     *
     * @OA\Get(
     *      path="/api/v1/shopping-cart",
     *      operationId="getShoppingCartItemsList",
     *      tags={"Shopping Cart"},
     *      summary="Get list of shopping cart items",
     *      description="Returns list of shopping cart items with pagination",
     *      security={{"sanctum": {}}},
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
        $cartItems = ShoppingCartItem::with(['user', 'product'])->paginate(15);
        return $this->sendResponse($cartItems, 'Shopping cart items retrieved successfully.');
    }

    /**
     * Store a newly created resource in storage.
     *
     * @OA\Post(
     *      path="/api/v1/shopping-cart",
     *      operationId="storeShoppingCartItem",
     *      tags={"Shopping Cart"},
     *      summary="Store new shopping cart item",
     *      description="Returns shopping cart item data",
     *      security={{"sanctum": {}}},
     *      @OA\RequestBody(
     *          required=true,
     *          @OA\JsonContent(
     *              required={"user_id","product_id","quantity","price"},
     *              @OA\Property(property="user_id", type="integer", example=1),
     *              @OA\Property(property="product_id", type="integer", example=1),
     *              @OA\Property(property="quantity", type="integer", example=2),
     *              @OA\Property(property="price", type="number", format="float", example=29.99),
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
            'user_id' => 'required|integer|exists:users,id',
            'product_id' => 'required|integer|exists:products,id',
            'quantity' => 'required|integer|min:1',
            'price' => 'required|numeric|min:0',
        ]);

        $cartItem = ShoppingCartItem::create($request->all());

        return $this->sendResponse($cartItem, 'Shopping cart item created successfully.', 201);
    }

    /**
     * Display the specified resource.
     *
     * @OA\Get(
     *      path="/api/v1/shopping-cart/{id}",
     *      operationId="getShoppingCartItemById",
     *      tags={"Shopping Cart"},
     *      summary="Get shopping cart item information",
     *      description="Returns shopping cart item data",
     *      security={{"sanctum": {}}},
     *      @OA\Parameter(
     *          name="id",
     *          description="Shopping cart item id",
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
        $cartItem = ShoppingCartItem::with(['user', 'product'])->find($id);

        if (is_null($cartItem)) {
            return $this->sendError('Shopping cart item not found.');
        }

        return $this->sendResponse($cartItem, 'Shopping cart item retrieved successfully.');
    }

    /**
     * Update the specified resource in storage.
     *
     * @OA\Put(
     *      path="/api/v1/shopping-cart/{id}",
     *      operationId="updateShoppingCartItem",
     *      tags={"Shopping Cart"},
     *      summary="Update existing shopping cart item",
     *      description="Returns updated shopping cart item data",
     *      security={{"sanctum": {}}},
     *      @OA\Parameter(
     *          name="id",
     *          description="Shopping cart item id",
     *          required=true,
     *          in="path",
     *          @OA\Schema(
     *              type="integer"
     *          )
     *      ),
     *      @OA\RequestBody(
     *          required=true,
     *          @OA\JsonContent(
     *              required={"user_id","product_id","quantity","price"},
     *              @OA\Property(property="user_id", type="integer", example=1),
     *              @OA\Property(property="product_id", type="integer", example=1),
     *              @OA\Property(property="quantity", type="integer", example=2),
     *              @OA\Property(property="price", type="number", format="float", example=29.99),
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
        $cartItem = ShoppingCartItem::find($id);

        if (is_null($cartItem)) {
            return $this->sendError('Shopping cart item not found.');
        }

        $request->validate([
            'user_id' => 'required|integer|exists:users,id',
            'product_id' => 'required|integer|exists:products,id',
            'quantity' => 'required|integer|min:1',
            'price' => 'required|numeric|min:0',
        ]);

        $cartItem->update($request->all());

        return $this->sendResponse($cartItem, 'Shopping cart item updated successfully.');
    }

    /**
     * Remove the specified resource from storage.
     *
     * @OA\Delete(
     *      path="/api/v1/shopping-cart/{id}",
     *      operationId="deleteShoppingCartItem",
     *      tags={"Shopping Cart"},
     *      summary="Delete shopping cart item",
     *      description="Deletes a shopping cart item",
     *      security={{"sanctum": {}}},
     *      @OA\Parameter(
     *          name="id",
     *          description="Shopping cart item id",
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
        $cartItem = ShoppingCartItem::find($id);

        if (is_null($cartItem)) {
            return $this->sendError('Shopping cart item not found.');
        }

        $cartItem->delete();

        return $this->sendResponse(null, 'Shopping cart item deleted successfully.');
    }
}
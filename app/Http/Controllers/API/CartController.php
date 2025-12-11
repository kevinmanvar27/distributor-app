<?php

namespace App\Http\Controllers\API;

use App\Models\Product;
use App\Models\ShoppingCartItem;
use App\Models\ProformaInvoice;
use App\Models\User;
use App\Models\Notification;
use App\Services\NotificationService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

/**
 * @OA\Tag(
 *     name="Cart",
 *     description="API Endpoints for User Shopping Cart"
 * )
 */
class CartController extends ApiController
{
    protected $notificationService;

    public function __construct(NotificationService $notificationService)
    {
        $this->notificationService = $notificationService;
    }

    /**
     * Add product to cart (alias for addToCart)
     * 
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function add(Request $request)
    {
        return $this->addToCart($request);
    }

    /**
     * Remove item from cart (alias for destroy)
     * 
     * @param Request $request
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function remove(Request $request, $id)
    {
        return $this->destroy($request, $id);
    }

    /**
     * Get authenticated user's cart items
     * 
     * @OA\Get(
     *      path="/api/v1/cart",
     *      operationId="getCart",
     *      tags={"Cart"},
     *      summary="Get user's cart",
     *      description="Returns the authenticated user's shopping cart items",
     *      security={{"sanctum": {}}},
     *      @OA\Response(
     *          response=200,
     *          description="Successful operation",
     *       ),
     *      @OA\Response(
     *          response=401,
     *          description="Unauthenticated"
     *      )
     * )
     * 
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function index(Request $request)
    {
        $user = $request->user();
        
        $cartItems = ShoppingCartItem::where('user_id', $user->id)
            ->with(['product.mainPhoto'])
            ->get();
        
        $total = $cartItems->sum(function ($item) {
            return $item->price * $item->quantity;
        });
        
        return $this->sendResponse([
            'items' => $cartItems,
            'total' => number_format($total, 2, '.', ''),
            'count' => $cartItems->count(),
        ], 'Cart items retrieved successfully.');
    }

    /**
     * Add product to cart
     * 
     * @OA\Post(
     *      path="/api/v1/cart/add",
     *      operationId="addToCart",
     *      tags={"Cart"},
     *      summary="Add product to cart",
     *      description="Add a product to the authenticated user's cart",
     *      security={{"sanctum": {}}},
     *      @OA\RequestBody(
     *          required=true,
     *          @OA\JsonContent(
     *              required={"product_id"},
     *              @OA\Property(property="product_id", type="integer", example=1),
     *              @OA\Property(property="quantity", type="integer", example=1),
     *          ),
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
    public function addToCart(Request $request)
    {
        $request->validate([
            'product_id' => 'required|exists:products,id',
            'quantity' => 'nullable|integer|min:1',
        ]);

        $user = $request->user();
        $product = Product::findOrFail($request->product_id);
        $quantity = $request->quantity ?? 1;

        // Check if product is in stock
        if (!$product->in_stock || $product->stock_quantity < $quantity) {
            return $this->sendError('Product is out of stock or insufficient quantity available.', [], 400);
        }

        // Calculate discounted price
        $priceToUse = (!is_null($product->selling_price) && $product->selling_price !== '' && $product->selling_price >= 0) 
            ? $product->selling_price 
            : $product->mrp;
        
        // Apply user discount if available
        $discountedPrice = function_exists('calculateDiscountedPrice') 
            ? calculateDiscountedPrice($priceToUse, $user) 
            : $priceToUse;

        // Add or update cart item
        $cartItem = ShoppingCartItem::updateOrCreate(
            [
                'user_id' => $user->id,
                'product_id' => $product->id,
            ],
            [
                'quantity' => $quantity,
                'price' => $discountedPrice,
            ]
        );

        // Get updated cart count
        $cartCount = ShoppingCartItem::where('user_id', $user->id)->count();

        return $this->sendResponse([
            'cart_item' => $cartItem->load('product.mainPhoto'),
            'cart_count' => $cartCount,
        ], 'Product added to cart successfully.');
    }

    /**
     * Update cart item quantity
     * 
     * @OA\Put(
     *      path="/api/v1/cart/{id}",
     *      operationId="updateCartItem",
     *      tags={"Cart"},
     *      summary="Update cart item",
     *      description="Update the quantity of a cart item",
     *      security={{"sanctum": {}}},
     *      @OA\Parameter(
     *          name="id",
     *          description="Cart item id",
     *          required=true,
     *          in="path",
     *          @OA\Schema(type="integer")
     *      ),
     *      @OA\RequestBody(
     *          required=true,
     *          @OA\JsonContent(
     *              required={"quantity"},
     *              @OA\Property(property="quantity", type="integer", example=2),
     *          ),
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
     *          description="Not Found"
     *      )
     * )
     * 
     * @param Request $request
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function update(Request $request, $id)
    {
        $request->validate([
            'quantity' => 'required|integer|min:1',
        ]);

        $user = $request->user();
        
        $cartItem = ShoppingCartItem::where('user_id', $user->id)
            ->where('id', $id)
            ->first();

        if (!$cartItem) {
            return $this->sendError('Cart item not found.', [], 404);
        }

        $product = $cartItem->product;

        // Check if product is in stock
        if (!$product->in_stock || $product->stock_quantity < $request->quantity) {
            return $this->sendError('Product is out of stock or insufficient quantity available.', [], 400);
        }

        $cartItem->update(['quantity' => $request->quantity]);

        // Calculate totals
        $itemTotal = $cartItem->price * $cartItem->quantity;
        $cartItems = ShoppingCartItem::where('user_id', $user->id)->get();
        $cartTotal = $cartItems->sum(function ($item) {
            return $item->price * $item->quantity;
        });

        return $this->sendResponse([
            'cart_item' => $cartItem->fresh()->load('product.mainPhoto'),
            'item_total' => number_format($itemTotal, 2, '.', ''),
            'cart_total' => number_format($cartTotal, 2, '.', ''),
        ], 'Cart item updated successfully.');
    }

    /**
     * Remove item from cart
     * 
     * @OA\Delete(
     *      path="/api/v1/cart/{id}",
     *      operationId="removeFromCart",
     *      tags={"Cart"},
     *      summary="Remove from cart",
     *      description="Remove an item from the cart",
     *      security={{"sanctum": {}}},
     *      @OA\Parameter(
     *          name="id",
     *          description="Cart item id",
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
     *          description="Not Found"
     *      )
     * )
     * 
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function destroy(Request $request, $id)
    {
        $user = $request->user();
        
        $cartItem = ShoppingCartItem::where('user_id', $user->id)
            ->where('id', $id)
            ->first();

        if (!$cartItem) {
            return $this->sendError('Cart item not found.', [], 404);
        }

        $cartItem->delete();

        // Get updated cart info
        $cartItems = ShoppingCartItem::where('user_id', $user->id)->get();
        $cartTotal = $cartItems->sum(function ($item) {
            return $item->price * $item->quantity;
        });

        return $this->sendResponse([
            'cart_count' => $cartItems->count(),
            'cart_total' => number_format($cartTotal, 2, '.', ''),
        ], 'Item removed from cart successfully.');
    }

    /**
     * Get cart items count
     * 
     * @OA\Get(
     *      path="/api/v1/cart/count",
     *      operationId="getCartCount",
     *      tags={"Cart"},
     *      summary="Get cart count",
     *      description="Get the number of items in the cart",
     *      security={{"sanctum": {}}},
     *      @OA\Response(
     *          response=200,
     *          description="Successful operation",
     *       ),
     *      @OA\Response(
     *          response=401,
     *          description="Unauthenticated"
     *      )
     * )
     * 
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function count(Request $request)
    {
        $user = $request->user();
        $cartCount = ShoppingCartItem::where('user_id', $user->id)->count();
        
        return $this->sendResponse(['cart_count' => $cartCount], 'Cart count retrieved successfully.');
    }

    /**
     * Generate proforma invoice from cart
     * 
     * @OA\Post(
     *      path="/api/v1/cart/generate-invoice",
     *      operationId="generateInvoice",
     *      tags={"Cart"},
     *      summary="Generate proforma invoice",
     *      description="Generate a proforma invoice from the cart items",
     *      security={{"sanctum": {}}},
     *      @OA\Response(
     *          response=201,
     *          description="Successful operation",
     *       ),
     *      @OA\Response(
     *          response=400,
     *          description="Cart is empty"
     *      ),
     *      @OA\Response(
     *          response=401,
     *          description="Unauthenticated"
     *      )
     * )
     * 
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function generateInvoice(Request $request)
    {
        $user = $request->user();
        
        $cartItems = ShoppingCartItem::where('user_id', $user->id)
            ->with('product.mainPhoto')
            ->get();

        if ($cartItems->isEmpty()) {
            return $this->sendError('Cart is empty.', [], 400);
        }

        $total = $cartItems->sum(function ($item) {
            return $item->price * $item->quantity;
        });

        // Generate invoice number
        $invoiceNumber = $this->generateInvoiceNumber();
        $invoiceDate = now()->format('Y-m-d');

        // Prepare invoice data
        $invoiceData = [
            'cart_items' => $cartItems->map(function ($item) {
                return [
                    'id' => $item->id,
                    'product_id' => $item->product_id,
                    'product_name' => $item->product->name,
                    'product_description' => $item->product->description,
                    'quantity' => $item->quantity,
                    'price' => $item->price,
                    'total' => $item->price * $item->quantity,
                ];
            })->toArray(),
            'total' => $total,
            'invoice_date' => $invoiceDate,
            'customer' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'address' => $user->address,
                'mobile_number' => $user->mobile_number,
            ],
        ];

        // Create proforma invoice
        $proformaInvoice = ProformaInvoice::create([
            'invoice_number' => $invoiceNumber,
            'user_id' => $user->id,
            'total_amount' => $total,
            'invoice_data' => json_encode($invoiceData),
            'status' => ProformaInvoice::STATUS_DRAFT ?? 'draft',
        ]);

        // Create notifications for admin users
        $adminUsers = User::whereIn('user_role', ['admin', 'super_admin'])->get();
        foreach ($adminUsers as $adminUser) {
            Notification::create([
                'user_id' => $adminUser->id,
                'title' => 'New Proforma Invoice Created',
                'message' => 'A new proforma invoice #' . $invoiceNumber . ' has been created by ' . $user->name,
                'type' => 'proforma_invoice',
                'data' => json_encode([
                    'invoice_id' => $proformaInvoice->id,
                    'invoice_number' => $invoiceNumber,
                    'customer_name' => $user->name,
                    'customer_avatar' => $user->avatar ? asset('storage/avatars/' . $user->avatar) : null,
                ]),
                'read' => false,
            ]);

            // Send push notification if device token exists
            if (!empty($adminUser->device_token)) {
                $payload = [
                    'notification' => [
                        'title' => 'New Proforma Invoice Created',
                        'body' => 'A new proforma invoice #' . $invoiceNumber . ' has been created by ' . $user->name,
                    ],
                    'data' => [
                        'invoice_id' => $proformaInvoice->id,
                        'invoice_number' => $invoiceNumber,
                        'type' => 'proforma_invoice_created',
                    ],
                ];
                $this->notificationService->sendPushNotification($adminUser->device_token, $payload);
            }
        }

        // Clear the cart
        ShoppingCartItem::where('user_id', $user->id)->delete();

        return $this->sendResponse([
            'invoice' => $proformaInvoice,
            'invoice_data' => $invoiceData,
        ], 'Proforma invoice generated successfully.', 201);
    }

    /**
     * Generate a serialized invoice number
     *
     * @return string
     */
    private function generateInvoiceNumber()
    {
        $year = date('Y');
        $latestInvoice = ProformaInvoice::orderBy('id', 'desc')->first();

        if ($latestInvoice) {
            $parts = explode('-', $latestInvoice->invoice_number);
            if (count($parts) >= 3 && $parts[1] == $year) {
                $sequence = (int)$parts[2] + 1;
            } else {
                $sequence = 1;
            }
        } else {
            $sequence = 1;
        }

        return "INV-{$year}-" . str_pad($sequence, 4, '0', STR_PAD_LEFT);
    }

    /**
     * Clear all items from cart
     * 
     * @OA\Delete(
     *      path="/api/v1/cart/clear",
     *      operationId="clearCart",
     *      tags={"Cart"},
     *      summary="Clear cart",
     *      description="Remove all items from the cart",
     *      security={{"sanctum": {}}},
     *      @OA\Response(
     *          response=200,
     *          description="Successful operation",
     *       ),
     *      @OA\Response(
     *          response=401,
     *          description="Unauthenticated"
     *      )
     * )
     * 
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function clear(Request $request)
    {
        $user = $request->user();
        ShoppingCartItem::where('user_id', $user->id)->delete();
        
        return $this->sendResponse(null, 'Cart cleared successfully.');
    }
}

<?php

namespace App\Http\Controllers\Frontend;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Product;
use App\Models\ShoppingCartItem;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Str;

class ShoppingCartController extends Controller
{
    /**
     * Display the shopping cart.
     *
     * @return \Illuminate\View\View
     */
    public function index()
    {
        $cartItems = Auth::user()->cartItems()->with('product.mainPhoto')->get();
        $total = $cartItems->sum(function ($item) {
            return $item->price * $item->quantity;
        });
        
        return view('frontend.cart', compact('cartItems', 'total'));
    }

    /**
     * Add a product to the shopping cart.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function addToCart(Request $request)
    {
        $request->validate([
            'product_id' => 'required|exists:products,id',
            'quantity' => 'nullable|integer|min:1',
        ]);

        $product = Product::findOrFail($request->product_id);
        $quantity = $request->quantity ?? 1;

        // Check if product is in stock
        if (!$product->in_stock || $product->stock_quantity < $quantity) {
            return response()->json([
                'success' => false,
                'message' => 'Product is out of stock or insufficient quantity available.'
            ]);
        }

        // Add or update cart item
        $cartItem = ShoppingCartItem::updateOrCreate(
            [
                'user_id' => Auth::id(),
                'product_id' => $product->id,
            ],
            [
                'quantity' => $quantity,
                'price' => $product->selling_price,
            ]
        );

        // Get updated cart count
        $cartCount = Auth::user()->cartItems->count();

        return response()->json([
            'success' => true,
            'message' => 'Product added to cart successfully!',
            'cart_count' => $cartCount,
        ]);
    }

    /**
     * Update the quantity of a cart item.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  int  $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function updateCart(Request $request, $id)
    {
        $request->validate([
            'quantity' => 'required|integer|min:1',
        ]);

        $cartItem = ShoppingCartItem::where('user_id', Auth::id())->where('id', $id)->firstOrFail();
        $product = $cartItem->product;

        // Check if product is in stock
        if (!$product->in_stock || $product->stock_quantity < $request->quantity) {
            return response()->json([
                'success' => false,
                'message' => 'Product is out of stock or insufficient quantity available.'
            ]);
        }

        $cartItem->update([
            'quantity' => $request->quantity,
        ]);

        // Calculate item total and cart total
        $itemTotal = $cartItem->price * $cartItem->quantity;
        $cartItems = Auth::user()->cartItems()->get();
        $cartTotal = $cartItems->sum(function ($item) {
            return $item->price * $item->quantity;
        });

        return response()->json([
            'success' => true,
            'message' => 'Cart updated successfully!',
            'item_total' => number_format($itemTotal, 2, '.', ''),
            'cart_total' => number_format($cartTotal, 2, '.', ''),
        ]);
    }

    /**
     * Remove an item from the cart.
     *
     * @param  int  $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function removeFromCart($id)
    {
        $cartItem = ShoppingCartItem::where('user_id', Auth::id())->where('id', $id)->firstOrFail();
        $cartItem->delete();

        // Get updated cart count and total
        $cartCount = Auth::user()->cartItems()->count();
        $cartItems = Auth::user()->cartItems()->get();
        $cartTotal = $cartItems->sum(function ($item) {
            return $item->price * $item->quantity;
        });

        return response()->json([
            'success' => true,
            'message' => 'Item removed from cart!',
            'cart_count' => $cartCount,
            'cart_total' => number_format($cartTotal, 2, '.', ''),
        ]);
    }

    /**
     * Get the cart count for the authenticated user.
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function getCartCount()
    {
        $cartCount = Auth::user()->cartItems()->count();
        return response()->json(['cart_count' => $cartCount]);
    }
}
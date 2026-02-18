<?php

namespace App\Http\Controllers\Frontend;

use App\Http\Controllers\Controller;
use App\Models\Wishlist;
use App\Models\Product;
use App\Models\ShoppingCartItem;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class WishlistController extends Controller
{
    /**
     * Display the user's wishlist
     *
     * @return \Illuminate\View\View
     */
    public function index()
    {
        $user = Auth::user();
        
        $wishlistItems = Wishlist::where('user_id', $user->id)
            ->with(['product' => function ($query) {
                $query->with('mainPhoto', 'variations');
            }])
            ->orderBy('created_at', 'desc')
            ->get();
        
        // Filter out items where product no longer exists or is not published
        $wishlistItems = $wishlistItems->filter(function ($item) {
            return $item->product && $item->product->status === 'published';
        });
        
        // Add discounted price and stock info to each product
        foreach ($wishlistItems as $item) {
            if ($item->product) {
                $priceToUse = (!is_null($item->product->selling_price) && $item->product->selling_price !== '' && $item->product->selling_price >= 0) 
                    ? $item->product->selling_price 
                    : $item->product->mrp;
                
                $item->product->discounted_price = function_exists('calculateDiscountedPrice') 
                    ? calculateDiscountedPrice($priceToUse, $user) 
                    : $priceToUse;
                
                $item->product->is_available = $item->product->in_stock && 
                    in_array($item->product->status, ['active', 'published']);
            }
        }
        
        return view('frontend.wishlist', compact('wishlistItems'));
    }
    
    /**
     * Add product to wishlist (AJAX)
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function add(Request $request)
    {
        $user = Auth::user();
        $productId = $request->input('product_id');
        
        // Check if product exists and is published
        $product = Product::where('id', $productId)
            ->where('status', 'published')
            ->first();
        
        if (!$product) {
            return response()->json([
                'success' => false,
                'message' => 'Product not found or not available.'
            ], 404);
        }
        
        // Check if already in wishlist
        $existing = Wishlist::where('user_id', $user->id)
            ->where('product_id', $productId)
            ->first();
        
        if ($existing) {
            return response()->json([
                'success' => false,
                'message' => 'Product is already in your wishlist.'
            ], 400);
        }
        
        // Add to wishlist
        $wishlistItem = Wishlist::create([
            'user_id' => $user->id,
            'product_id' => $productId,
        ]);
        
        // Get total wishlist count
        $wishlistCount = Wishlist::where('user_id', $user->id)->count();
        
        return response()->json([
            'success' => true,
            'message' => 'Product added to wishlist.',
            'wishlist_count' => $wishlistCount
        ]);
    }
    
    /**
     * Remove product from wishlist (AJAX)
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function remove(Request $request)
    {
        $user = Auth::user();
        $productId = $request->input('product_id');
        
        $wishlistItem = Wishlist::where('user_id', $user->id)
            ->where('product_id', $productId)
            ->first();
        
        if (!$wishlistItem) {
            return response()->json([
                'success' => false,
                'message' => 'Product not found in your wishlist.'
            ], 404);
        }
        
        $wishlistItem->delete();
        
        // Get total wishlist count
        $wishlistCount = Wishlist::where('user_id', $user->id)->count();
        
        return response()->json([
            'success' => true,
            'message' => 'Product removed from wishlist.',
            'wishlist_count' => $wishlistCount
        ]);
    }
    
    /**
     * Toggle product in wishlist (AJAX)
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function toggle(Request $request)
    {
        $user = Auth::user();
        $productId = $request->input('product_id');
        
        // Check if product exists and is published
        $product = Product::where('id', $productId)
            ->where('status', 'published')
            ->first();
        
        if (!$product) {
            return response()->json([
                'success' => false,
                'message' => 'Product not found or not available.'
            ], 404);
        }
        
        // Check if already in wishlist
        $wishlistItem = Wishlist::where('user_id', $user->id)
            ->where('product_id', $productId)
            ->first();
        
        if ($wishlistItem) {
            // Remove from wishlist
            $wishlistItem->delete();
            $inWishlist = false;
            $message = 'Product removed from wishlist.';
        } else {
            // Add to wishlist
            Wishlist::create([
                'user_id' => $user->id,
                'product_id' => $productId,
            ]);
            $inWishlist = true;
            $message = 'Product added to wishlist.';
        }
        
        // Get total wishlist count
        $wishlistCount = Wishlist::where('user_id', $user->id)->count();
        
        return response()->json([
            'success' => true,
            'message' => $message,
            'in_wishlist' => $inWishlist,
            'wishlist_count' => $wishlistCount
        ]);
    }
    
    /**
     * Check if product is in wishlist (AJAX)
     *
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function check(Request $request)
    {
        $user = Auth::user();
        $productId = $request->input('product_id');
        
        $wishlistItem = Wishlist::where('user_id', $user->id)
            ->where('product_id', $productId)
            ->first();
        
        return response()->json([
            'success' => true,
            'in_wishlist' => $wishlistItem !== null
        ]);
    }
    
    /**
     * Get wishlist count (AJAX)
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function count()
    {
        $user = Auth::user();
        $wishlistCount = Wishlist::where('user_id', $user->id)->count();
        
        return response()->json([
            'success' => true,
            'count' => $wishlistCount
        ]);
    }
    
    /**
     * Move wishlist item to cart
     *
     * @param Request $request
     * @param int $id
     * @return \Illuminate\Http\RedirectResponse
     */
    public function moveToCart(Request $request, $id)
    {
        $user = Auth::user();
        
        $wishlistItem = Wishlist::where('user_id', $user->id)
            ->where('id', $id)
            ->first();
        
        if (!$wishlistItem) {
            return redirect()->back()->with('error', 'Product not found in your wishlist.');
        }
        
        $product = Product::where('id', $wishlistItem->product_id)
            ->where('status', 'published')
            ->first();
        
        if (!$product) {
            $wishlistItem->delete();
            return redirect()->back()->with('error', 'Product is no longer available.');
        }
        
        // Check stock
        if (!$product->in_stock || $product->stock_quantity < 1) {
            return redirect()->back()->with('error', 'Product is out of stock.');
        }
        
        // Calculate price
        $priceToUse = (!is_null($product->selling_price) && $product->selling_price !== '' && $product->selling_price >= 0) 
            ? $product->selling_price 
            : $product->mrp;
        
        $discountedPrice = function_exists('calculateDiscountedPrice') 
            ? calculateDiscountedPrice($priceToUse, $user) 
            : $priceToUse;
        
        // Check if product already in cart
        $cartItem = ShoppingCartItem::where('user_id', $user->id)
            ->where('product_id', $product->id)
            ->first();
        
        if ($cartItem) {
            // Update quantity
            $newQuantity = $cartItem->quantity + 1;
            
            // Check if new quantity exceeds stock
            if ($product->stock_quantity < $newQuantity) {
                return redirect()->back()->with('error', 'Cannot add more. Insufficient stock available.');
            }
            
            $cartItem->quantity = $newQuantity;
            $cartItem->price = $discountedPrice;
            $cartItem->save();
            
            // REDUCE STOCK QUANTITY
            $product->decrement('stock_quantity', 1);
        } else {
            // Create new cart item
            ShoppingCartItem::create([
                'user_id' => $user->id,
                'product_id' => $product->id,
                'quantity' => 1,
                'price' => $discountedPrice,
            ]);
            
            // REDUCE STOCK QUANTITY
            $product->decrement('stock_quantity', 1);
        }
        
        // Update in_stock status if stock is depleted
        if ($product->fresh()->stock_quantity <= 0) {
            $product->update(['in_stock' => false]);
        }
        
        // Remove from wishlist
        $wishlistItem->delete();
        
        return redirect()->back()->with('success', 'Product added to cart.');
    }
    
    /**
     * Clear entire wishlist
     *
     * @return \Illuminate\Http\RedirectResponse
     */
    public function clear()
    {
        $user = Auth::user();
        $itemsRemoved = Wishlist::where('user_id', $user->id)->delete();
        
        return redirect()->back()->with('success', "Wishlist cleared. {$itemsRemoved} items removed.");
    }
}

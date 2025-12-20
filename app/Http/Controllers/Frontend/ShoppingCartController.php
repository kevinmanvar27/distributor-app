<?php

namespace App\Http\Controllers\Frontend;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Product;
use App\Models\ShoppingCartItem;
use App\Models\ProformaInvoice;
use App\Models\User;
use App\Models\Notification;
use App\Services\NotificationService;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Str;
use Barryvdh\DomPDF\Facade\Pdf;

class ShoppingCartController extends Controller
{
    protected $notificationService;

    public function __construct(NotificationService $notificationService)
    {
        $this->notificationService = $notificationService;
    }

    /**
     * Display the shopping cart.
     *
     * @return \Illuminate\View\View
     */
    public function index()
    {
        // Check if frontend requires authentication and user is not logged in
        $setting = \App\Models\Setting::first();
        $accessPermission = $setting->frontend_access_permission ?? 'open_for_all';
        
        // For registered_users_only and admin_approval_required modes, 
        // redirect guests from cart pages to login, unless it's open_for_all
        if ($accessPermission !== 'open_for_all' && !Auth::check()) {
            // Check if there are any items in the guest cart
            $sessionId = session()->getId();
            $guestCartCount = ShoppingCartItem::forSession($sessionId)->count();
            
            // If guest has items in cart, allow access to cart page
            // Otherwise, redirect to login
            if ($guestCartCount == 0) {
                return redirect()->route('frontend.login');
            }
        }
        
        if (Auth::check()) {
            $cartItems = Auth::user()->cartItems()->with('product.mainPhoto')->get();
        } else {
            // For guests, get cart items by session ID
            $sessionId = session()->getId();
            $cartItems = ShoppingCartItem::forSession($sessionId)->with('product.mainPhoto')->get();
        }
        
        $total = $cartItems->sum(function ($item) {
            // Use the price stored in the cart item, which was calculated at time of adding
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

        // Calculate discounted price using our helper function
        // If selling price is null, blank, or not set, use MRP instead
        $priceToUse = (!is_null($product->selling_price) && $product->selling_price !== '' && $product->selling_price >= 0) ? 
                      $product->selling_price : $product->mrp;
        
        // For guests, use null user and calculate price without discount
        // For authenticated users, calculate with their discount
        $discountedPrice = $priceToUse;
        if (Auth::check()) {
            $discountedPrice = calculateDiscountedPrice($priceToUse, Auth::user());
        }

        // Prepare data for cart item
        $cartData = [
            'product_id' => $product->id,
            'quantity' => $quantity,
            'price' => $discountedPrice,
        ];

        // Add user_id or session_id based on authentication status
        if (Auth::check()) {
            $cartData['user_id'] = Auth::id();
        } else {
            $cartData['session_id'] = session()->getId();
        }

        // Add or update cart item with the discounted price
        $cartItem = ShoppingCartItem::updateOrCreate(
            Auth::check() ? 
                ['user_id' => Auth::id(), 'product_id' => $product->id] :
                ['session_id' => session()->getId(), 'product_id' => $product->id],
            $cartData
        );

        // Get updated cart count
        if (Auth::check()) {
            $cartCount = Auth::user()->cartItems()->count();
        } else {
            $cartCount = ShoppingCartItem::forSession(session()->getId())->count();
        }

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

        // Find cart item based on authentication status
        if (Auth::check()) {
            $cartItem = ShoppingCartItem::where('user_id', Auth::id())->where('id', $id)->firstOrFail();
        } else {
            $cartItem = ShoppingCartItem::where('session_id', session()->getId())->where('id', $id)->firstOrFail();
        }
        
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
        
        if (Auth::check()) {
            $cartItems = Auth::user()->cartItems()->get();
        } else {
            $cartItems = ShoppingCartItem::forSession(session()->getId())->get();
        }
        
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
        // Find cart item based on authentication status
        if (Auth::check()) {
            $cartItem = ShoppingCartItem::where('user_id', Auth::id())->where('id', $id)->firstOrFail();
        } else {
            $cartItem = ShoppingCartItem::where('session_id', session()->getId())->where('id', $id)->firstOrFail();
        }
        
        $cartItem->delete();

        // Get updated cart count and total
        if (Auth::check()) {
            $cartCount = Auth::user()->cartItems()->count();
            $cartItems = Auth::user()->cartItems()->get();
        } else {
            $cartCount = ShoppingCartItem::forSession(session()->getId())->count();
            $cartItems = ShoppingCartItem::forSession(session()->getId())->get();
        }
        
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
     * Get the cart count for the current user or session.
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function getCartCount()
    {
        if (Auth::check()) {
            $cartCount = Auth::user()->cartItems()->count();
        } else {
            $cartCount = ShoppingCartItem::forSession(session()->getId())->count();
        }
        
        return response()->json(['cart_count' => $cartCount]);
    }
    
    /**
     * Migrate guest cart items to authenticated user's cart.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function migrateGuestCart(Request $request)
    {
        if (!Auth::check()) {
            return response()->json(['success' => false, 'message' => 'User not authenticated.']);
        }
        
        $userId = Auth::id();
        
        // First, migrate database guest cart items (items added when session was active)
        $this->migrateDatabaseGuestCart($userId);
        
        // Then, migrate localStorage guest cart items (items added before session)
        $this->migrateLocalStorageGuestCart($request, $userId);
        
        return response()->json(['success' => true, 'message' => 'Cart items migrated successfully.']);
    }
    
    /**
     * Migrate database guest cart items to authenticated user's cart.
     *
     * @param  int  $userId
     * @return void
     */
    private function migrateDatabaseGuestCart($userId)
    {
        $sessionId = session()->getId();
        
        // Get guest cart items from database
        $guestCartItems = ShoppingCartItem::forSession($sessionId)->get();
        
        // Migrate each guest cart item to user's cart
        foreach ($guestCartItems as $guestCartItem) {
            // Check if user already has this product in their cart
            $existingCartItem = ShoppingCartItem::where('user_id', $userId)
                ->where('product_id', $guestCartItem->product_id)
                ->first();
                
            if ($existingCartItem) {
                // If user already has this product, update quantity (combine quantities)
                // Make sure we don't exceed stock quantity
                $product = $guestCartItem->product;
                $newQuantity = min($existingCartItem->quantity + $guestCartItem->quantity, $product->stock_quantity);
                $existingCartItem->update([
                    'quantity' => $newQuantity
                ]);
                
                // Delete the guest cart item
                $guestCartItem->delete();
            } else {
                // If user doesn't have this product, transfer the guest cart item to user
                // Make sure we don't exceed stock quantity
                $product = $guestCartItem->product;
                $newQuantity = min($guestCartItem->quantity, $product->stock_quantity);
                $guestCartItem->update([
                    'user_id' => $userId,
                    'session_id' => null,
                    'quantity' => $newQuantity
                ]);
            }
        }
    }
    
    /**
     * Migrate localStorage guest cart items to authenticated user's cart.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  int  $userId
     * @return void
     */
    private function migrateLocalStorageGuestCart(Request $request, $userId)
    {
        // Get guest cart data from request
        $localStorageCart = $request->get('guest_cart', '[]');
        
        // Decode the cart data
        $guestCartItems = json_decode($localStorageCart, true);
        
        // If we don't have valid cart data, return
        if (!is_array($guestCartItems)) {
            return;
        }
        
        // Process each item in the localStorage cart
        foreach ($guestCartItems as $guestCartItem) {
            // Validate the cart item data
            if (!isset($guestCartItem['product_id']) || !isset($guestCartItem['quantity'])) {
                continue;
            }
            
            $productId = $guestCartItem['product_id'];
            $quantity = (int) $guestCartItem['quantity'];
            
            // Validate product exists and is available
            $product = Product::find($productId);
            if (!$product || !$product->in_stock || $product->stock_quantity < $quantity) {
                continue;
            }
            
            // Calculate the price for this product
            $priceToUse = (!is_null($product->selling_price) && $product->selling_price !== '' && $product->selling_price >= 0) ? 
                          $product->selling_price : $product->mrp;
            
            // For guests (when userId is passed but user might not be authenticated),
            // calculate price without discount
            $user = \Illuminate\Support\Facades\Auth::find($userId);
            $discountedPrice = $user ? calculateDiscountedPrice($priceToUse, $user) : $priceToUse;
            
            // Check if user already has this product in their cart
            $existingCartItem = ShoppingCartItem::where('user_id', $userId)
                ->where('product_id', $productId)
                ->first();
                
            if ($existingCartItem) {
                // If user already has this product, update quantity (combine quantities)
                $newQuantity = min($existingCartItem->quantity + $quantity, $product->stock_quantity);
                $existingCartItem->update([
                    'quantity' => $newQuantity
                ]);
            } else {
                // If user doesn't have this product, create a new cart item
                $newQuantity = min($quantity, $product->stock_quantity);
                ShoppingCartItem::create([
                    'user_id' => $userId,
                    'product_id' => $productId,
                    'quantity' => $newQuantity,
                    'price' => $discountedPrice
                ]);
            }
        }
    }
    
    /**
     * Generate and display the proforma invoice.
     *
     * @return \Illuminate\View\View
     */
    public function generateProformaInvoice()
    {
        // Check if frontend requires authentication and user is not logged in
        $setting = \App\Models\Setting::first();
        $accessPermission = $setting->frontend_access_permission ?? 'open_for_all';
        
        // For registered_users_only and admin_approval_required modes, 
        // redirect guests from cart pages to login, unless it's open_for_all
        if ($accessPermission !== 'open_for_all' && !Auth::check()) {
            return redirect()->route('frontend.login');
        }
        
        if (Auth::check()) {
            $cartItems = Auth::user()->cartItems()->with('product.mainPhoto')->get();
        } else {
            // For guests, get cart items by session ID
            $sessionId = session()->getId();
            $cartItems = ShoppingCartItem::forSession($sessionId)->with('product.mainPhoto')->get();
        }
        
        $total = $cartItems->sum(function ($item) {
            // Use the price stored in the cart item, which was calculated at time of adding
            return $item->price * $item->quantity;
        });
        
        // Generate invoice date
        $invoiceDate = now()->format('Y-m-d');
        
        // Prepare invoice data for storage
        $invoiceData = [
            'cart_items' => $cartItems->map(function ($item) {
                return [
                    'id' => $item->id,
                    'product_id' => $item->product_id,
                    'product_name' => $item->product->name,
                    'product_slug' => $item->product->slug,
                    'product_description' => $item->product->description,
                    'quantity' => $item->quantity,
                    'price' => $item->price,
                    'total' => $item->price * $item->quantity
                ];
            })->toArray(),
            'total' => $total,
            'invoice_date' => $invoiceDate,
            'customer' => Auth::check() ? [
                'id' => Auth::id(),
                'name' => Auth::user()->name,
                'email' => Auth::user()->email,
                'address' => Auth::user()->address,
                'mobile_number' => Auth::user()->mobile_number
            ] : null,
            'session_id' => Auth::check() ? null : session()->getId()
        ];
        
        // Save the proforma invoice to the database with retry logic for duplicate invoice numbers
        $proformaInvoice = $this->createProformaInvoiceWithRetry($total, $invoiceData);
        $invoiceNumber = $proformaInvoice->invoice_number;
        
        // Create database notifications for admin users
        $adminUsers = User::where('user_role', 'admin')->orWhere('user_role', 'super_admin')->get();
        foreach ($adminUsers as $adminUser) {
            // Get user avatar URL
            $avatarUrl = $adminUser->avatar ? asset('storage/avatars/' . $adminUser->avatar) : null;
            
            Notification::create([
                'user_id' => $adminUser->id,
                'title' => 'New Proforma Invoice Created',
                'message' => 'A new proforma invoice #' . $invoiceNumber . ' has been created by ' . (Auth::check() ? Auth::user()->name : 'Guest'),
                'type' => 'proforma_invoice',
                'data' => json_encode([
                    'invoice_id' => $proformaInvoice->id,
                    'invoice_number' => $invoiceNumber,
                    'customer_name' => Auth::check() ? Auth::user()->name : 'Guest',
                    'customer_avatar' => Auth::check() ? (Auth::user()->avatar ? asset('storage/avatars/' . Auth::user()->avatar) : null) : null
                ]),
                'read' => false,
            ]);
        }
        
        // Send push notifications to admin users who have device tokens
        if (Auth::check()) {
            foreach ($adminUsers as $adminUser) {
                if (!empty($adminUser->device_token)) {
                    $payload = [
                        'notification' => [
                            'title' => 'New Proforma Invoice Created',
                            'body' => 'A new proforma invoice #' . $invoiceNumber . ' has been created by ' . Auth::user()->name
                        ],
                        'data' => [
                            'invoice_id' => $proformaInvoice->id,
                            'invoice_number' => $invoiceNumber,
                            'type' => 'proforma_invoice_created'
                        ]
                    ];
                    
                    $this->notificationService->sendPushNotification($adminUser->device_token, $payload);
                }
            }
        }
        
        // Clear the cart after generating the proforma invoice
        if (Auth::check()) {
            // For authenticated users, delete all cart items for the user
            ShoppingCartItem::where('user_id', Auth::id())->delete();
        } else {
            // For guests, delete all cart items for the session
            ShoppingCartItem::where('session_id', session()->getId())->delete();
        }
        
        // Redirect to the invoices list instead of showing the proforma invoice page
        return redirect()->route('frontend.cart.proforma.invoices')->with('success', 'Proforma invoice generated successfully! Cart has been emptied.');
    }
    
    /**
     * Display a listing of the user's proforma invoices.
     *
     * @return \Illuminate\View\View
     */
    public function listProformaInvoices()
    {
        // Check if frontend requires authentication and user is not logged in
        $setting = \App\Models\Setting::first();
        $accessPermission = $setting->frontend_access_permission ?? 'open_for_all';
        
        // For registered_users_only and admin_approval_required modes, 
        // redirect guests from cart pages to login, unless it's open_for_all
        if ($accessPermission !== 'open_for_all' && !Auth::check()) {
            return redirect()->route('frontend.login');
        }
        
        // Get all proforma invoices for the authenticated user
        if (Auth::check()) {
            $proformaInvoices = ProformaInvoice::where('user_id', Auth::id())
                ->orderBy('created_at', 'desc')
                ->get();
        } else {
            // For guests, get invoices by session ID
            $sessionId = session()->getId();
            $proformaInvoices = ProformaInvoice::where('session_id', $sessionId)
                ->orderBy('created_at', 'desc')
                ->get();
        }
        
        return view('frontend.proforma-invoice-list', compact('proformaInvoices'));
    }
    
    /**
     * Get the details of a specific proforma invoice.
     *
     * @param  int  $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function getProformaInvoiceDetails($id)
    {
        // Check if frontend requires authentication and user is not logged in
        $setting = \App\Models\Setting::first();
        $accessPermission = $setting->frontend_access_permission ?? 'open_for_all';
        
        // For registered_users_only and admin_approval_required modes, 
        // redirect guests from cart pages to login, unless it's open_for_all
        if ($accessPermission !== 'open_for_all' && !Auth::check()) {
            return response()->json(['error' => 'Unauthorized'], 401);
        }
        
        // Find the proforma invoice
        if (Auth::check()) {
            $proformaInvoice = ProformaInvoice::where('id', $id)
                ->where('user_id', Auth::id())
                ->first();
        } else {
            // For guests, get invoice by session ID
            $sessionId = session()->getId();
            $proformaInvoice = ProformaInvoice::where('id', $id)
                ->where('session_id', $sessionId)
                ->first();
        }
        
        if (!$proformaInvoice) {
            return response()->json(['error' => 'Invoice not found'], 404);
        }
        
        // Get the invoice data (already decoded by model casting)
        $invoiceData = $proformaInvoice->invoice_data;
        
        // Automatically remove all notifications for this invoice when viewing directly
        $unreadCount = 0;
        if (Auth::check()) {
            // Get all unread notifications for the current user that are related to this invoice
            $notifications = \App\Models\Notification::where('user_id', Auth::id())
                ->where('read', false)
                ->where('type', 'proforma_invoice')
                ->where('data', 'like', '%"invoice_id":' . $id . '%')
                ->get();
            
            // Delete all matching notifications
            foreach ($notifications as $notification) {
                $notification->delete();
            }
            
            // Get updated unread count
            $unreadCount = \App\Models\Notification::where('user_id', Auth::id())
                ->where('read', false)
                ->count();
        }
        
        return response()->json([
            'invoice' => $proformaInvoice,
            'data' => $invoiceData,
            'unread_count' => $unreadCount
        ]);
    }

    /**
     * Add products from a proforma invoice back to the cart.
     *
     * @param  int  $id
     * @return \Illuminate\Http\RedirectResponse
     */
    public function addInvoiceToCart($id)
    {
        // Check if frontend requires authentication and user is not logged in
        $setting = \App\Models\Setting::first();
        $accessPermission = $setting->frontend_access_permission ?? 'open_for_all';
        
        // For registered_users_only and admin_approval_required modes, 
        // redirect guests from cart pages to login, unless it's open_for_all
        if ($accessPermission !== 'open_for_all' && !Auth::check()) {
            return redirect()->route('frontend.login');
        }
        
        // Find the proforma invoice
        if (Auth::check()) {
            $proformaInvoice = ProformaInvoice::where('id', $id)
                ->where('user_id', Auth::id())
                ->first();
        } else {
            // For guests, get invoice by session ID
            $sessionId = session()->getId();
            $proformaInvoice = ProformaInvoice::where('id', $id)
                ->where('session_id', $sessionId)
                ->first();
        }
        
        if (!$proformaInvoice) {
            return redirect()->route('frontend.cart.proforma.invoices')->with('error', 'Invoice not found.');
        }
        
        // Check if the invoice is in draft status
        if ($proformaInvoice->status !== ProformaInvoice::STATUS_DRAFT) {
            return redirect()->route('frontend.cart.proforma.invoices')->with('error', 'Only draft invoices can be added to cart.');
        }
        
        // Get the invoice data (already decoded by model casting)
        $invoiceData = $proformaInvoice->invoice_data;
        
        // Add each item from the invoice to the cart
        if (isset($invoiceData['cart_items']) && is_array($invoiceData['cart_items'])) {
            foreach ($invoiceData['cart_items'] as $item) {
                // Prepare data for cart item
                $cartData = [
                    'product_id' => $item['product_id'],
                    'quantity' => $item['quantity'],
                    'price' => $item['price'],
                ];
                
                // Add user_id or session_id based on authentication status
                if (Auth::check()) {
                    $cartData['user_id'] = Auth::id();
                } else {
                    $cartData['session_id'] = session()->getId();
                }
                
                // Add or update cart item
                $cartItem = ShoppingCartItem::updateOrCreate(
                    Auth::check() ? 
                        ['user_id' => Auth::id(), 'product_id' => $item['product_id']] :
                        ['session_id' => session()->getId(), 'product_id' => $item['product_id']],
                    $cartData
                );
            }
        }
        
        // Delete the proforma invoice after adding items to cart
        $proformaInvoice->delete();
        
        return redirect()->route('frontend.cart.index')->with('success', 'Products from proforma invoice added to cart successfully! The proforma invoice has been removed.');
    }
    
    /**
     * Delete a proforma invoice.
     *
     * @param  int  $id
     * @return \Illuminate\Http\RedirectResponse
     */
    public function deleteProformaInvoice($id)
    {
        // Check if frontend requires authentication and user is not logged in
        $setting = \App\Models\Setting::first();
        $accessPermission = $setting->frontend_access_permission ?? 'open_for_all';
        
        // For registered_users_only and admin_approval_required modes, 
        // redirect guests from cart pages to login, unless it's open_for_all
        if ($accessPermission !== 'open_for_all' && !Auth::check()) {
            return redirect()->route('frontend.login');
        }
        
        // Find the proforma invoice
        if (Auth::check()) {
            $proformaInvoice = ProformaInvoice::where('id', $id)
                ->where('user_id', Auth::id())
                ->first();
        } else {
            // For guests, get invoice by session ID
            $sessionId = session()->getId();
            $proformaInvoice = ProformaInvoice::where('id', $id)
                ->where('session_id', $sessionId)
                ->first();
        }
        
        if (!$proformaInvoice) {
            return redirect()->route('frontend.cart.proforma.invoices')->with('error', 'Invoice not found.');
        }
        
        // Delete the proforma invoice
        $proformaInvoice->delete();
        
        return redirect()->route('frontend.cart.proforma.invoices')->with('success', 'Proforma invoice deleted successfully!');
    }
    
    /**
     * Generate a serialized invoice number with database locking to prevent duplicates.
     *
     * @return string
     */
    private function generateInvoiceNumber()
    {
        // Get the current year
        $year = date('Y');
        $prefix = "INV-{$year}-";
        
        // Use database locking to prevent race conditions
        return \Illuminate\Support\Facades\DB::transaction(function () use ($year, $prefix) {
            // Lock the table for reading to prevent concurrent reads
            $latestInvoice = ProformaInvoice::where('invoice_number', 'like', $prefix . '%')
                ->orderBy('invoice_number', 'desc')
                ->lockForUpdate()
                ->first();
            
            if ($latestInvoice) {
                // Extract the sequence number from the latest invoice
                $latestNumber = $latestInvoice->invoice_number;
                $parts = explode('-', $latestNumber);
                
                // If the latest invoice is from the current year, increment the sequence
                if (count($parts) >= 3 && $parts[1] == $year) {
                    $sequence = (int)$parts[2] + 1;
                } else {
                    // If it's a new year or no previous invoices, start from 1
                    $sequence = 1;
                }
            } else {
                // If no previous invoices, start from 1
                $sequence = 1;
            }
            
            // Format the sequence number with leading zeros (e.g., 0001)
            $sequenceFormatted = str_pad($sequence, 4, '0', STR_PAD_LEFT);
            
            // Return the formatted invoice number (e.g., INV-2025-0001)
            return "INV-{$year}-{$sequenceFormatted}";
        });
    }
    
    /**
     * Create a proforma invoice with retry logic to handle duplicate invoice numbers.
     *
     * @param  float  $total
     * @param  array  $invoiceData
     * @param  int  $maxRetries
     * @return \App\Models\ProformaInvoice
     * @throws \Exception
     */
    private function createProformaInvoiceWithRetry($total, $invoiceData, $maxRetries = 5)
    {
        $attempts = 0;
        $lastException = null;
        
        while ($attempts < $maxRetries) {
            try {
                return \Illuminate\Support\Facades\DB::transaction(function () use ($total, $invoiceData) {
                    // Generate invoice number inside the transaction
                    $invoiceNumber = $this->generateInvoiceNumber();
                    
                    // Create the proforma invoice
                    return ProformaInvoice::create([
                        'invoice_number' => $invoiceNumber,
                        'user_id' => Auth::check() ? Auth::id() : null,
                        'session_id' => Auth::check() ? null : session()->getId(),
                        'total_amount' => $total,
                        'invoice_data' => json_encode($invoiceData),
                        'status' => ProformaInvoice::STATUS_DRAFT,
                    ]);
                });
            } catch (\Illuminate\Database\QueryException $e) {
                $lastException = $e;
                
                // Check if it's a duplicate entry error (MySQL error code 1062)
                if ($e->errorInfo[1] == 1062) {
                    $attempts++;
                    // Small delay before retry to reduce collision chance
                    usleep(100000 * $attempts); // 100ms * attempt number
                    continue;
                }
                
                // If it's not a duplicate entry error, rethrow
                throw $e;
            }
        }
        
        // If we've exhausted all retries, throw the last exception
        throw $lastException ?? new \Exception('Failed to create proforma invoice after ' . $maxRetries . ' attempts');
    }
    
    /**
     * Generate and download PDF for a proforma invoice.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function downloadProformaInvoicePDF($id)
    {
        // Check if frontend requires authentication and user is not logged in
        $setting = \App\Models\Setting::first();
        $accessPermission = $setting->frontend_access_permission ?? 'open_for_all';
        
        // For registered_users_only and admin_approval_required modes, 
        // redirect guests from cart pages to login, unless it's open_for_all
        if ($accessPermission !== 'open_for_all' && !Auth::check()) {
            return redirect()->route('frontend.login');
        }
        
        // Find the proforma invoice
        if (Auth::check()) {
            $proformaInvoice = ProformaInvoice::where('id', $id)
                ->where('user_id', Auth::id())
                ->first();
        } else {
            // For guests, get invoice by session ID
            $sessionId = session()->getId();
            $proformaInvoice = ProformaInvoice::where('id', $id)
                ->where('session_id', $sessionId)
                ->first();
        }
        
        if (!$proformaInvoice) {
            return redirect()->route('frontend.cart.proforma.invoices')->with('error', 'Invoice not found.');
        }
        
        // Get the invoice data (already decoded by model casting)
        $invoiceData = $proformaInvoice->invoice_data;
        
        // Prepare data for the PDF view
        $data = [
            'invoice' => $proformaInvoice,
            'invoiceData' => $invoiceData,
            'siteTitle' => setting('site_title', 'Frontend App'),
            'companyAddress' => setting('address', 'Company Address'),
            'companyEmail' => setting('email', 'company@example.com'),
            'companyPhone' => setting('phone', '+1 (555) 123-4567')
        ];
        
        // Load the PDF view
        $pdf = Pdf::loadView('frontend.proforma-invoice-pdf', $data);
        
        // Set paper size and orientation
        $pdf->setPaper('A4', 'portrait');
        
        // Download the PDF with a meaningful filename
        return $pdf->download('proforma-invoice-' . $proformaInvoice->invoice_number . '.pdf');
    }

}

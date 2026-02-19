<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\API\AuthController;
use App\Http\Controllers\API\UserController;
use App\Http\Controllers\API\RoleController;
use App\Http\Controllers\API\PermissionController;
use App\Http\Controllers\API\CategoryController;
use App\Http\Controllers\API\SubCategoryController;
use App\Http\Controllers\API\ProductController;
// use App\Http\Controllers\API\MediaController; // Removed - Media Library feature disabled
use App\Http\Controllers\API\SettingController;
use App\Http\Controllers\API\ShoppingCartController;
use App\Http\Controllers\API\ProformaInvoiceController;
use App\Http\Controllers\API\PageController;
use App\Http\Controllers\API\UserGroupController;
use App\Http\Controllers\API\UserGroupMemberController;
use App\Http\Controllers\API\NotificationController;
use App\Http\Controllers\API\ProfileController;
use App\Http\Controllers\API\CartController;
use App\Http\Controllers\API\MyInvoiceController;
use App\Http\Controllers\API\ProductSearchController;
use App\Http\Controllers\API\AppConfigController;
use App\Http\Controllers\API\PasswordResetController;
use App\Http\Controllers\API\HomeController;
use App\Http\Controllers\API\WishlistController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/

// Public API routes
Route::prefix('v1')->group(function () {
    // Authentication routes
    Route::post('/login', [AuthController::class, 'login']);
    Route::post('/register', [AuthController::class, 'register']);
    
    // Password Reset routes with OTP (public)
    Route::post('/forgot-password', [PasswordResetController::class, 'forgotPassword']);
    Route::post('/verify-otp', [PasswordResetController::class, 'verifyOtp']);
    Route::post('/resend-otp', [PasswordResetController::class, 'resendOtp']);
    Route::post('/reset-password', [PasswordResetController::class, 'resetPassword']);
    Route::post('/verify-reset-token', [PasswordResetController::class, 'verifyResetToken']);
    
    // App Version Check (public - no auth required)
    Route::get('/app-version', [AppConfigController::class, 'appVersion']);
    
    // App Settings (public - no auth required)
    Route::get('/app-settings', [AppConfigController::class, 'appSettings']);
    Route::get('/app-config', [AppConfigController::class, 'appConfigPublic']);
    Route::get('/company-info', [AppConfigController::class, 'companyInfo']);
    
    // Product Search routes (public - no auth required) - MUST be before apiResource routes
    Route::get('/products/search', [ProductSearchController::class, 'search']);
    Route::get('/products/by-category/{categoryId}', [ProductSearchController::class, 'byCategory']);
    Route::get('/products/by-subcategory/{subcategoryId}', [ProductSearchController::class, 'bySubcategory']);
    Route::get('/categories/{id}/subcategories', [ProductSearchController::class, 'subcategoriesByCategory']);
    
    // Public resources
    Route::apiResource('categories', CategoryController::class)->only(['index', 'show']);
    Route::apiResource('subcategories', SubCategoryController::class)->only(['index', 'show']);
    Route::apiResource('products', ProductController::class)->only(['index', 'show']);
    Route::apiResource('pages', PageController::class)->only(['index', 'show']);
    
    // Home/Dashboard route (public - works with or without auth)
    Route::get('/home', [HomeController::class, 'index']);
});

// Protected API routes
Route::prefix('v1')->middleware('auth:sanctum')->group(function () {
    // Auth routes
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user', [AuthController::class, 'user']);
    
    // =============================================
    // MOBILE APP API ROUTES (New Flutter App APIs)
    // =============================================
    
    // Profile routes
    Route::get('/profile', [ProfileController::class, 'show']);
    Route::put('/profile', [ProfileController::class, 'update']);
    Route::post('/profile/avatar', [ProfileController::class, 'updateAvatar']);
    Route::delete('/profile/avatar', [ProfileController::class, 'removeAvatar']);
    Route::put('/profile/password', [ProfileController::class, 'changePassword']);
    Route::delete('/profile/delete-account', [ProfileController::class, 'deleteAccount']);
    
    // Wishlist routes
    Route::get('/wishlist', [WishlistController::class, 'index']);
    Route::post('/wishlist/{productId}', [WishlistController::class, 'add']);
    Route::delete('/wishlist/{productId}', [WishlistController::class, 'remove']);
    Route::get('/wishlist/check/{productId}', [WishlistController::class, 'check']);
    Route::post('/wishlist/{productId}/add-to-cart', [WishlistController::class, 'addToCart']);
    Route::delete('/wishlist/clear', [WishlistController::class, 'clear']);
    
    // Cart routes (user-specific cart)
    Route::get('/cart', [CartController::class, 'index']);
    Route::post('/cart/add', [CartController::class, 'add']);
    Route::put('/cart/{id}', [CartController::class, 'update']);
    Route::delete('/cart/{id}', [CartController::class, 'remove']);
    Route::get('/cart/count', [CartController::class, 'count']);
    Route::post('/cart/generate-invoice', [CartController::class, 'generateInvoice']);
    Route::delete('/cart/clear', [CartController::class, 'clear']);
    
    // My Invoices routes (user-specific invoices)
    Route::get('/my-invoices', [MyInvoiceController::class, 'index']);
    Route::get('/my-invoices/{id}', [MyInvoiceController::class, 'show']);
    Route::get('/my-invoices/{id}/download-pdf', [MyInvoiceController::class, 'downloadPdf']);
    Route::post('/my-invoices/{id}/add-to-cart', [MyInvoiceController::class, 'addToCart']);
    Route::delete('/my-invoices/{id}/items/{productId}', [MyInvoiceController::class, 'removeItem']);
    Route::delete('/my-invoices/{id}', [MyInvoiceController::class, 'destroy']);
    
    // User Notification routes
    Route::get('/notifications', [NotificationController::class, 'index']);
    Route::post('/notifications/{id}/mark-read', [NotificationController::class, 'markAsRead']);
    Route::post('/notifications/mark-all-read', [NotificationController::class, 'markAllAsRead']);
    Route::post('/notifications/bulk-mark-read', [NotificationController::class, 'bulkMarkAsRead']);
    Route::get('/notifications/unread-count', [NotificationController::class, 'unreadCount']);
    Route::delete('/notifications/{id}', [NotificationController::class, 'destroy']);
    Route::delete('/notifications/clear-all', [NotificationController::class, 'clearAll']);
    Route::post('/notifications/bulk-delete', [NotificationController::class, 'bulkDelete']);
    Route::post('/notifications/register-device', [NotificationController::class, 'registerDeviceToken']);
    
    // =============================================
    // ADMIN API ROUTES (Existing Admin Panel APIs)
    // =============================================
    
    // Admin Notification routes
    Route::post('/notifications/send-to-user', [NotificationController::class, 'sendToUser']);
    Route::post('/notifications/send-to-group', [NotificationController::class, 'sendToUserGroup']);
    Route::get('/notifications/statistics', [NotificationController::class, 'getStatistics']);
    
    // Legacy notification routes (kept for backward compatibility)
    Route::post('/notifications/device-token', [NotificationController::class, 'registerDeviceToken']);
    Route::get('/notifications/stats', [NotificationController::class, 'getStatistics']);
    
    // Task Management API (Admin)
    Route::prefix('tasks')->group(function () {
        // List and statistics - require view_tasks permission
        Route::get('/', [\App\Http\Controllers\Admin\TaskController::class, 'index'])->middleware('permission:view_tasks');
        Route::get('/statistics', [\App\Http\Controllers\Admin\TaskController::class, 'statistics'])->middleware('permission:view_tasks');
        
        // Create routes (must be before {id} routes) - require manage_tasks permission
        Route::get('/create', [\App\Http\Controllers\Admin\TaskController::class, 'create'])->middleware('permission:manage_tasks');
        Route::post('/', [\App\Http\Controllers\Admin\TaskController::class, 'store'])->middleware('permission:manage_tasks');
        
        // Show specific task - require view_tasks permission
        Route::get('/{id}', [\App\Http\Controllers\Admin\TaskController::class, 'show'])->middleware('permission:view_tasks');
        
        // Edit routes - require manage_tasks permission
        Route::get('/{id}/edit', [\App\Http\Controllers\Admin\TaskController::class, 'edit'])->middleware('permission:manage_tasks');
        Route::put('/{id}', [\App\Http\Controllers\Admin\TaskController::class, 'update'])->middleware('permission:manage_tasks');
        Route::delete('/{id}', [\App\Http\Controllers\Admin\TaskController::class, 'destroy'])->middleware('permission:manage_tasks');
        
        // Comment and Status routes - require update_task_status permission
        Route::post('/{id}/comment', [\App\Http\Controllers\Admin\TaskController::class, 'addComment'])->middleware('permission:update_task_status');
        Route::post('/{id}/status', [\App\Http\Controllers\Admin\TaskController::class, 'updateStatus'])->middleware('permission:update_task_status');
    });
    
    // Task Management API (Staff - View and Update Only)
    Route::prefix('staff/tasks')->group(function () {
        // List and statistics - require view_tasks permission
        Route::get('/', [\App\Http\Controllers\Staff\TaskController::class, 'index'])->middleware('permission:view_tasks');
        Route::get('/statistics', [\App\Http\Controllers\Staff\TaskController::class, 'statistics'])->middleware('permission:view_tasks');
        
        // Show specific task - require view_tasks permission
        Route::get('/{id}', [\App\Http\Controllers\Staff\TaskController::class, 'show'])->middleware('permission:view_tasks');
        
        // Status and comment routes - require update_task_status permission
        Route::post('/{id}/status', [\App\Http\Controllers\Staff\TaskController::class, 'updateStatus'])->middleware('permission:update_task_status');
        Route::post('/{id}/comment', [\App\Http\Controllers\Staff\TaskController::class, 'addComment'])->middleware('permission:update_task_status');
    });
    
    // Resource routes
    Route::apiResource('users', UserController::class);
    Route::apiResource('roles', RoleController::class);
    Route::apiResource('permissions', PermissionController::class);
    Route::apiResource('categories', CategoryController::class)->except(['index', 'show']);
    Route::apiResource('subcategories', SubCategoryController::class)->except(['index', 'show']);
    Route::apiResource('products', ProductController::class)->except(['index', 'show']);
    // Route::apiResource('media', MediaController::class); // Removed - Media Library feature disabled
    Route::apiResource('settings', SettingController::class);
    Route::apiResource('shopping-cart', ShoppingCartController::class);
    Route::apiResource('proforma-invoices', ProformaInvoiceController::class);
    Route::patch('/proforma-invoices/{id}/status', [ProformaInvoiceController::class, 'updateStatus']);
    Route::delete('/proforma-invoices/{id}/items/{productId}', [ProformaInvoiceController::class, 'removeItem']);
    Route::apiResource('pages', PageController::class)->except(['index', 'show']);
    Route::apiResource('user-groups', UserGroupController::class);
    Route::apiResource('user-group-members', UserGroupMemberController::class);
});
<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\API\AuthController;
use App\Http\Controllers\API\UserController;
use App\Http\Controllers\API\RoleController;
use App\Http\Controllers\API\PermissionController;
use App\Http\Controllers\API\CategoryController;
use App\Http\Controllers\API\SubCategoryController;
use App\Http\Controllers\API\ProductController;
use App\Http\Controllers\API\MediaController;
use App\Http\Controllers\API\SettingController;
use App\Http\Controllers\API\ShoppingCartController;
use App\Http\Controllers\API\ProformaInvoiceController;
use App\Http\Controllers\API\PageController;
use App\Http\Controllers\API\UserGroupController;
use App\Http\Controllers\API\UserGroupMemberController;
use App\Http\Controllers\API\NotificationController;

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
    
    // Public resources
    Route::apiResource('categories', CategoryController::class)->only(['index', 'show']);
    Route::apiResource('products', ProductController::class)->only(['index', 'show']);
    Route::apiResource('pages', PageController::class)->only(['index', 'show']);
});

// Protected API routes
Route::prefix('v1')->middleware('auth:sanctum')->group(function () {
    // Auth routes
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/user', [AuthController::class, 'user']);
    
    // Notification routes
    Route::post('/notifications/send-to-user', [NotificationController::class, 'sendToUser']);
    Route::post('/notifications/send-to-group', [NotificationController::class, 'sendToUserGroup']);
    Route::post('/notifications/device-token', [NotificationController::class, 'registerDeviceToken']);
    Route::get('/notifications/stats', [NotificationController::class, 'getStatistics']);
    
    // Resource routes
    Route::apiResource('users', UserController::class);
    Route::apiResource('roles', RoleController::class);
    Route::apiResource('permissions', PermissionController::class);
    Route::apiResource('categories', CategoryController::class)->except(['index', 'show']);
    Route::apiResource('subcategories', SubCategoryController::class);
    Route::apiResource('products', ProductController::class)->except(['index', 'show']);
    Route::apiResource('media', MediaController::class);
    Route::apiResource('settings', SettingController::class);
    Route::apiResource('shopping-cart', ShoppingCartController::class);
    Route::apiResource('proforma-invoices', ProformaInvoiceController::class);
    Route::apiResource('pages', PageController::class)->except(['index', 'show']);
    Route::apiResource('user-groups', UserGroupController::class);
    Route::apiResource('user-group-members', UserGroupMemberController::class);
});
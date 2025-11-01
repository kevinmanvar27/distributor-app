<?php

use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Auth\LoginController;
use App\Http\Controllers\DashboardController;
use App\Http\Controllers\Admin\SettingsController;
use App\Http\Controllers\Admin\FirebaseController;
use App\Http\Controllers\Admin\ProfileController;
use App\Http\Controllers\Admin\UserController;
use App\Http\Controllers\Admin\RoleController;
use App\Http\Controllers\Admin\PermissionController;
use App\Http\Controllers\Admin\ProductController;

// Redirect root URL to admin login page
Route::get('/', function () {
    return redirect()->route('login');
});

// Authentication Routes
Route::get('admin/login', [LoginController::class, 'showLoginForm'])->name('login');
Route::post('admin/login', [LoginController::class, 'login']);
Route::post('logout', [LoginController::class, 'logout'])->name('logout');

// Dynamic CSS Route
Route::get('/css/dynamic.css', function () {
    $setting = \App\Models\Setting::first();
    
    // Font settings
    $fontColor = $setting && $setting->font_color ? $setting->font_color : '#333333';
    $fontStyle = $setting && $setting->font_style ? $setting->font_style : 'Arial, sans-serif';
    
    // Theme color settings
    $themeColor = $setting && $setting->theme_color ? $setting->theme_color : '#FF6B00';
    $backgroundColor = $setting && $setting->background_color ? $setting->background_color : '#FFFFFF';
    
    // Text color settings
    $sidebarTextColor = $setting && $setting->sidebar_text_color ? $setting->sidebar_text_color : '#333333';
    $headingTextColor = $setting && $setting->heading_text_color ? $setting->heading_text_color : '#333333';
    $labelTextColor = $setting && $setting->label_text_color ? $setting->label_text_color : '#333333';
    $generalTextColor = $setting && $setting->general_text_color ? $setting->general_text_color : '#333333';
    $linkColor = $setting && $setting->link_color ? $setting->link_color : '#333333';
    $linkHoverColor = $setting && $setting->link_hover_color ? $setting->link_hover_color : '#FF6B00';
    
    $css = ":root { 
        --font-color: {$fontColor}; 
        --font-style: {$fontStyle};
        --theme-color: {$themeColor};
        --background-color: {$backgroundColor};
        --sidebar-text-color: {$sidebarTextColor};
        --heading-text-color: {$headingTextColor};
        --label-text-color: {$labelTextColor};
        --general-text-color: {$generalTextColor};
        --link-color: {$linkColor};
        --link-hover-color: {$linkHoverColor};
    }";
    
    return response($css, 200)->header('Content-Type', 'text/css');
});

// Admin Routes (protected by auth middleware)
Route::middleware('auth')->group(function () {
    Route::get('/admin/dashboard', [DashboardController::class, 'index'])->name('dashboard');
    Route::get('/admin/color-palette', function () {
        return view('admin.color-palette');
    })->name('admin.color-palette');
    Route::get('/admin/test-links', function () {
        return view('admin.test-links');
    })->name('admin.test-links');
    Route::get('/admin/settings', [SettingsController::class, 'index'])->name('admin.settings');
    Route::post('/admin/settings', [SettingsController::class, 'update'])->name('admin.settings.update');
    Route::post('/admin/settings/reset', [SettingsController::class, 'reset'])->name('admin.settings.reset');
    
    // Profile Routes
    Route::get('/admin/profile', [ProfileController::class, 'show'])->name('admin.profile');
    Route::post('/admin/profile', [ProfileController::class, 'update'])->name('admin.profile.update');
    Route::post('/admin/profile/avatar', [ProfileController::class, 'updateAvatar'])->name('admin.profile.avatar.update');
    Route::post('/admin/profile/avatar/remove', [ProfileController::class, 'removeAvatar'])->name('admin.profile.avatar.remove');
    
    // User Management Routes
    Route::prefix('admin')->group(function () {
        // Regular users management
        Route::get('/users', [UserController::class, 'index'])->name('admin.users.index');
        Route::get('/users/staff', [UserController::class, 'staff'])->name('admin.users.staff');
        
        Route::resource('users', UserController::class)->except(['index'])->names([
            'create' => 'admin.users.create',
            'store' => 'admin.users.store',
            'edit' => 'admin.users.edit',
            'update' => 'admin.users.update',
            'destroy' => 'admin.users.destroy',
        ]);
        
        // User Avatar Routes
        Route::post('/users/{user}/avatar', [UserController::class, 'updateAvatar'])->name('admin.users.avatar.update');
        Route::delete('/users/{user}/avatar', [UserController::class, 'removeAvatar'])->name('admin.users.avatar.remove');
        
        // Role and Permission Management Routes (only accessible to super_admin)
        Route::middleware('permission:manage_roles')->group(function () {
            Route::resource('roles', RoleController::class)->names([
                'index' => 'admin.roles.index',
                'create' => 'admin.roles.create',
                'store' => 'admin.roles.store',
                'show' => 'admin.roles.show',
                'edit' => 'admin.roles.edit',
                'update' => 'admin.roles.update',
                'destroy' => 'admin.roles.destroy',
            ]);
            
            Route::resource('permissions', PermissionController::class)->names([
                'index' => 'admin.permissions.index',
                'create' => 'admin.permissions.create',
                'store' => 'admin.permissions.store',
                'show' => 'admin.permissions.show',
                'edit' => 'admin.permissions.edit',
                'update' => 'admin.permissions.update',
                'destroy' => 'admin.permissions.destroy',
            ]);
        });
    });
    
    // Database Management Routes
    Route::post('/admin/settings/database/clean', [SettingsController::class, 'cleanDatabase'])->name('admin.settings.database.clean');
    Route::post('/admin/settings/database/export', [SettingsController::class, 'exportDatabase'])->name('admin.settings.database.export');
    
    // Theme switching route
    Route::post('/admin/theme/switch', function () {
        $theme = request('theme', 'light');
        session(['theme' => $theme]);
        return response()->json(['status' => 'success', 'theme' => $theme]);
    })->name('admin.theme.switch');
    
    // Firebase Notification Test Route
    Route::get('/admin/test-firebase', function () {
        return response()->json([
            'configured' => is_firebase_configured(),
            'project_id' => firebase_project_id(),
            'client_email' => firebase_client_email(),
            'has_private_key' => !empty(firebase_private_key())
        ]);
    })->name('admin.test.firebase');
    
    // Firebase Configuration Test Route
    Route::get('/admin/firebase/test', [FirebaseController::class, 'testConfiguration'])->name('admin.firebase.test');
    
    // Firebase Statistics Route
    Route::get('/admin/firebase/stats', [FirebaseController::class, 'getStatistics'])->name('admin.firebase.stats');
    
    // Product Management Routes
    Route::prefix('admin')->group(function () {
        Route::resource('products', ProductController::class)->names([
            'index' => 'admin.products.index',
            'create' => 'admin.products.create',
            'store' => 'admin.products.store',
            'show' => 'admin.products.show',
            'edit' => 'admin.products.edit',
            'update' => 'admin.products.update',
            'destroy' => 'admin.products.destroy',
        ]);
        
        // Media Library Routes
        Route::get('/media', [ProductController::class, 'getMedia'])->name('admin.media.index');
        Route::post('/media', [ProductController::class, 'storeMedia'])->name('admin.media.store');
        Route::delete('/media/{media}', [ProductController::class, 'destroyMedia'])->name('admin.media.destroy');
    });
});
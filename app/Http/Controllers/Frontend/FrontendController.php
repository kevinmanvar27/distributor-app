<?php

namespace App\Http\Controllers\Frontend;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Category;
use App\Models\Product;

class FrontendController extends Controller
{
    /**
     * Show the home page
     *
     * @return \Illuminate\View\View
     */
    public function index()
    {
        // Fetch all active categories with their images
        $categories = Category::where('is_active', true)
            ->with('image')
            ->get();
            
        // Fetch all active or published products with their main photos
        // Note: Not loading galleryMedia due to implementation issues
        $products = Product::whereIn('status', ['active', 'published'])
            ->with('mainPhoto')
            ->get();

        return view('frontend.home', compact('categories', 'products'));
    }
    
    /**
     * Show the user profile page
     *
     * @return \Illuminate\View\View
     */
    public function profile()
    {
        return view('frontend.profile', ['user' => auth()->user()]);
    }
}
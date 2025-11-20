<?php

namespace App\Http\Controllers\Frontend;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Category;
use App\Models\Product;
use Illuminate\Support\Str;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Storage;
use Illuminate\Validation\Rule;
use Illuminate\Support\Facades\Validator;

class FrontendController extends Controller
{
    /**
     * Show the home page
     *
     * @return \Illuminate\View\View
     */
    public function index()
    {
        // Fetch all active categories with their images and subcategories
        $categories = Category::where('is_active', true)
            ->with('image', 'subCategories')
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
    
    /**
     * Show the category detail page
     *
     * @param  \App\Models\Category  $category
     * @return \Illuminate\View\View
     */
    public function showCategory(Category $category)
    {
        // Check if category is active
        if (!$category->is_active) {
            abort(404);
        }
        
        // Load active subcategories with their images
        $subCategories = $category->subCategories()
            ->where('is_active', true)
            ->with('image')
            ->get();
            
        // Load products associated with this category (active or published)
        // Products store categories in a JSON array in the product_categories field
        $products = Product::whereIn('status', ['active', 'published'])
            ->get()
            ->filter(function ($product) use ($category) {
                if (!$product->product_categories) {
                    return false;
                }
                
                foreach ($product->product_categories as $catData) {
                    if (isset($catData['category_id']) && $catData['category_id'] == $category->id) {
                        return true;
                    }
                }
                
                return false;
            })
            ->values();
            
        // SEO meta tags
        $metaTitle = $category->name . ' - ' . setting('site_title', 'Frontend App');
        $metaDescription = $category->description ?? 'Explore products in ' . $category->name . ' category';
        
        return view('frontend.category', compact('category', 'subCategories', 'products', 'metaTitle', 'metaDescription'));
    }
    
    /**
     * Update the user profile
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\RedirectResponse
     */
    public function updateProfile(Request $request)
    {
        /** @var \App\Models\User $user */
        $user = Auth::user();
        
        // Validate the request
        $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'email', 'max:255', Rule::unique('users')->ignore($user->id)],
            'mobile_number' => ['nullable', 'string', 'max:20'],
            'date_of_birth' => ['nullable', 'date', 'before_or_equal:today'],
            'address' => ['nullable', 'string', 'max:500'],
        ]);
        
        // Update user information
        $user->name = $request->name;
        $user->email = $request->email;
        $user->mobile_number = $request->mobile_number;
        $user->date_of_birth = $request->date_of_birth;
        $user->address = $request->address;
        $user->save();
        
        return redirect()->route('frontend.profile')->with('success', 'Profile updated successfully.');
    }
    
    /**
     * Update the user's avatar
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\RedirectResponse
     */
    public function updateAvatar(Request $request)
    {
        /** @var \App\Models\User $user */
        $user = Auth::user();
        
        // Validate only the avatar field
        $request->validate([
            'avatar' => ['required', 'image', 'mimes:jpeg,png,jpg,gif', 'max:2048'], // 2MB max
        ], [
            'avatar.required' => 'Please select an image to upload.',
            'avatar.image' => 'The file must be an image.',
            'avatar.max' => 'The image may not be greater than 2MB.',
        ]);
        
        // Delete old avatar if exists
        if ($user->avatar) {
            Storage::disk('public')->delete('avatars/' . $user->avatar);
        }
        
        // Store new avatar
        $avatarName = time() . '_' . $user->id . '.' . $request->file('avatar')->extension();
        $request->file('avatar')->storeAs('avatars', $avatarName, 'public');
        $user->avatar = $avatarName;
        $user->save();
        
        return redirect()->route('frontend.profile')->with('success', 'Profile picture updated successfully.');
    }
    
    /**
     * Remove the user's avatar
     *
     * @return \Illuminate\Http\RedirectResponse
     */
    public function removeAvatar()
    {
        /** @var \App\Models\User $user */
        $user = Auth::user();
        
        // Delete avatar file if exists
        if ($user->avatar) {
            Storage::disk('public')->delete('avatars/' . $user->avatar);
            $user->avatar = null;
            $user->save();
        }
        
        return redirect()->route('frontend.profile')->with('success', 'Profile picture removed successfully.');
    }
    
    /**
     * Change the user's password
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\RedirectResponse
     */
    public function changePassword(Request $request)
    {
        /** @var \App\Models\User $user */
        $user = Auth::user();
        
        // Validate the request
        $request->validate([
            'current_password' => ['required', 'string', function ($attribute, $value, $fail) use ($user) {
                if (!Hash::check($value, $user->password)) {
                    $fail('The current password is incorrect.');
                }
            }],
            'password' => ['required', 'string', 'min:8', 'confirmed', 'different:current_password'],
        ], [
            'password.different' => 'The new password must be different from your current password.',
            'password.confirmed' => 'The password confirmation does not match.',
        ]);
        
        // Update password
        $user->password = Hash::make($request->password);
        $user->save();
        
        return redirect()->route('frontend.profile')->with('success', 'Password changed successfully.');
    }
}
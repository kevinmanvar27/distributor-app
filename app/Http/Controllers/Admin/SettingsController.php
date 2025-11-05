<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;
use App\Models\Setting;
use App\Models\User;

class SettingsController extends Controller
{
    /**
     * Display the settings page
     *
     * @return \Illuminate\View\View
     */
    public function index()
    {
        // Get the first (and only) settings record, or create a new one with default values
        $setting = Setting::firstOrCreate([], [
            'site_title' => 'Hardware Store',
            'site_description' => 'Your one-stop shop for all hardware needs',
            'tagline' => 'Quality hardware solutions for everyone',
            'footer_text' => '© 2025 Hardware Store. All rights reserved.',
            'theme_color' => '#FF6B00',
            'background_color' => '#FFFFFF',
            'font_color' => '#333333',
            'font_style' => 'Arial, sans-serif',
            'sidebar_text_color' => '#333333',
            'heading_text_color' => '#333333',
            'label_text_color' => '#333333',
            'general_text_color' => '#333333',
            'link_color' => '#333333',
            'link_hover_color' => '#FF6B00',
            'header_logo' => null,
            'footer_logo' => null,
            'favicon' => null,
            'facebook_url' => null,
            'twitter_url' => null,
            'instagram_url' => null,
            'linkedin_url' => null,
            'youtube_url' => null,
            'whatsapp_url' => null,
            'maintenance_mode' => false,
            'maintenance_end_time' => null,
            'maintenance_message' => 'We are currently under maintenance. The website will be back online approximately at {end_time}.',
            'coming_soon_mode' => false,
            'launch_time' => null,
            'coming_soon_message' => "We're launching soon! Our amazing platform will be available at {launch_time}.",
            'razorpay_key_id' => null,
            'razorpay_key_secret' => null,
            'app_store_link' => null,
            'play_store_link' => null,
        ]);
        
        return view('admin.settings.index', compact('setting'));
    }
    
    /**
     * Update the settings
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\RedirectResponse
     */
    public function update(Request $request)
    {
        // Check if this is a password change request
        if ($request->filled('current_password')) {
            return $this->changePassword($request);
        }
        
        $request->validate([
            'header_logo' => 'nullable|image|mimes:jpeg,png,jpg,gif,svg|max:2048',
            'footer_logo' => 'nullable|image|mimes:jpeg,png,jpg,gif,svg|max:2048',
            'favicon' => 'nullable|image|mimes:jpeg,png,jpg,gif,svg,ico|max:2048',
            'site_title' => 'nullable|string|max:255',
            'site_description' => 'nullable|string',
            'tagline' => 'nullable|string|max:255',
            'footer_text' => 'nullable|string',
            'theme_color' => 'nullable|string|max:7',
            'background_color' => 'nullable|string|max:7',
            'font_color' => 'nullable|string|max:7',
            'font_style' => 'nullable|string|max:255',
            'sidebar_text_color' => 'nullable|string|max:7',
            'heading_text_color' => 'nullable|string|max:7',
            'label_text_color' => 'nullable|string|max:7',
            'general_text_color' => 'nullable|string|max:7',
            'link_color' => 'nullable|string|max:7',
            'link_hover_color' => 'nullable|string|max:7',
            'facebook_url' => 'nullable|url',
            'twitter_url' => 'nullable|url',
            'instagram_url' => 'nullable|url',
            'linkedin_url' => 'nullable|url',
            'youtube_url' => 'nullable|url',
            'whatsapp_url' => 'nullable|url',
            'razorpay_key_id' => 'nullable|string|max:255',
            'razorpay_key_secret' => 'nullable|string|max:255',
            'firebase_project_id' => 'nullable|string|max:255',
            'firebase_client_email' => 'nullable|string|max:255',
            'firebase_private_key' => 'nullable|string',
            'app_store_link' => 'nullable|url',
            'play_store_link' => 'nullable|url',
            // Site Management validation rules
            'maintenance_end_time' => 'nullable|date_format:d/m/Y H:i',
            'maintenance_message' => 'nullable|string',
            'launch_time' => 'nullable|date_format:d/m/Y H:i',
            'coming_soon_message' => 'nullable|string',
        ]);
        
        // Get the first (and only) settings record, or create a new one
        $setting = Setting::firstOrCreate([]);
        
        // Handle image removals
        if ($request->has('remove_header_logo')) {
            $this->removeImage($setting, 'header_logo');
        }
        
        if ($request->has('remove_footer_logo')) {
            $this->removeImage($setting, 'footer_logo');
        }
        
        if ($request->has('remove_favicon')) {
            $this->removeImage($setting, 'favicon');
        }
        
        // Handle image uploads and delete old images
        $this->handleImageUpload($request, $setting, 'header_logo');
        $this->handleImageUpload($request, $setting, 'footer_logo');
        $this->handleImageUpload($request, $setting, 'favicon');
        
        // Update text fields
        $setting->site_title = $request->site_title;
        $setting->site_description = $request->site_description;
        $setting->tagline = $request->tagline;
        $setting->footer_text = $request->footer_text;
        $setting->theme_color = $request->theme_color;
        $setting->background_color = $request->background_color;
        $setting->font_color = $request->font_color;
        $setting->font_style = $request->font_style;
        $setting->sidebar_text_color = $request->sidebar_text_color;
        $setting->heading_text_color = $request->heading_text_color;
        $setting->label_text_color = $request->label_text_color;
        $setting->general_text_color = $request->general_text_color;
        $setting->link_color = $request->link_color;
        $setting->link_hover_color = $request->link_hover_color;
        $setting->facebook_url = $request->facebook_url;
        $setting->twitter_url = $request->twitter_url;
        $setting->instagram_url = $request->instagram_url;
        $setting->linkedin_url = $request->linkedin_url;
        $setting->youtube_url = $request->youtube_url;
        $setting->whatsapp_url = $request->whatsapp_url;
        $setting->razorpay_key_id = $request->razorpay_key_id;
        $setting->razorpay_key_secret = $request->razorpay_key_secret;
        $setting->firebase_project_id = $request->firebase_project_id;
        $setting->firebase_client_email = $request->firebase_client_email;
        $setting->firebase_private_key = $request->firebase_private_key;
        $setting->app_store_link = $request->app_store_link;
        $setting->play_store_link = $request->play_store_link;
        
        // Update site management fields with mutual exclusivity
        $maintenanceMode = $request->boolean('maintenance_mode');
        $comingSoonMode = $request->boolean('coming_soon_mode');
        
        // Ensure only one mode is active at a time
        if ($maintenanceMode && $comingSoonMode) {
            // If both are checked, prioritize maintenance mode
            $setting->maintenance_mode = true;
            $setting->coming_soon_mode = false;
        } else {
            $setting->maintenance_mode = $maintenanceMode;
            $setting->coming_soon_mode = $comingSoonMode;
        }
        
        // Parse and save maintenance end time
        if ($request->filled('maintenance_end_time')) {
            $maintenanceEndTime = \DateTime::createFromFormat('d/m/Y H:i', $request->maintenance_end_time);
            $setting->maintenance_end_time = $maintenanceEndTime ? $maintenanceEndTime->format('Y-m-d H:i:s') : null;
        } else {
            $setting->maintenance_end_time = null;
        }
        
        $setting->maintenance_message = $request->maintenance_message;
        
        // Parse and save launch time
        if ($request->filled('launch_time')) {
            $launchTime = \DateTime::createFromFormat('d/m/Y H:i', $request->launch_time);
            $setting->launch_time = $launchTime ? $launchTime->format('Y-m-d H:i:s') : null;
        } else {
            $setting->launch_time = null;
        }
        
        $setting->coming_soon_message = $request->coming_soon_message;
        
        $setting->save();
        
        // Get the active tab from the request
        $activeTab = $request->input('active_tab', 'general');
        
        return redirect()->back()->with('success', 'Settings updated successfully.')->with('tab', $activeTab);
    }
    
    /**
     * Change the user's password
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\RedirectResponse
     */
    private function changePassword(Request $request)
    {
        $request->validate([
            'current_password' => 'required|string',
            'new_password' => 'required|string|min:8|confirmed|different:current_password',
        ], [
            'new_password.different' => 'The new password must be different from the current password.',
            'new_password.confirmed' => 'The password confirmation does not match.',
        ]);
        
        /** @var User $user */
        $user = Auth::user();
        
        // Check if current password is correct
        if (!Auth::attempt(['email' => $user->email, 'password' => $request->current_password])) {
            return redirect()->back()->withErrors(['current_password' => 'The current password is incorrect.'])->with('tab', 'password');
        }
        
        // Update password
        $user->password = bcrypt($request->new_password);
        $user->save();
        
        return redirect()->back()->with('success', 'Password changed successfully.')->with('tab', 'password');
    }
    
    /**
     * Handle image upload and delete old image
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Models\Setting  $setting
     * @param  string  $fieldName
     * @return void
     */
    private function handleImageUpload(Request $request, Setting $setting, string $fieldName)
    {
        if ($request->hasFile($fieldName)) {
            // Delete old image if exists
            if ($setting->$fieldName) {
                Storage::disk('public')->delete($setting->$fieldName);
            }
            
            // Store new image
            $path = $request->file($fieldName)->store('settings', 'public');
            $setting->$fieldName = $path;
        }
    }
    
    /**
     * Remove an image and delete it from storage
     *
     * @param  \App\Models\Setting  $setting
     * @param  string  $fieldName
     * @return void
     */
    private function removeImage(Setting $setting, string $fieldName)
    {
        if ($setting->$fieldName) {
            Storage::disk('public')->delete($setting->$fieldName);
            $setting->$fieldName = null;
        }
    }
    
    /**
     * Reset settings to default values
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\RedirectResponse
     */
    public function reset(Request $request)
    {
        $setting = Setting::first();
        if ($setting) {
            // Delete existing images
            $imageFields = ['header_logo', 'footer_logo', 'favicon'];
            foreach ($imageFields as $field) {
                if ($setting->$field) {
                    Storage::disk('public')->delete($setting->$field);
                }
            }
            
            // Reset all fields to default values
            $setting->update([
                'site_title' => 'Hardware Store',
                'site_description' => 'Your one-stop shop for all hardware needs',
                'tagline' => 'Quality hardware solutions for everyone',
                'footer_text' => '© 2025 Hardware Store. All rights reserved.',
                'theme_color' => '#FF6B00',
                'background_color' => '#FFFFFF',
                'font_color' => '#333333',
                'font_style' => 'Arial, sans-serif',
                'sidebar_text_color' => '#333333',
                'heading_text_color' => '#333333',
                'label_text_color' => '#333333',
                'general_text_color' => '#333333',
                'link_color' => '#333333',
                'link_hover_color' => '#FF6B00',
                'header_logo' => null,
                'footer_logo' => null,
                'favicon' => null,
                'facebook_url' => null,
                'twitter_url' => null,
                'instagram_url' => null,
                'linkedin_url' => null,
                'youtube_url' => null,
                'whatsapp_url' => null,
                'maintenance_mode' => false,
                'maintenance_end_time' => null,
                'maintenance_message' => 'We are currently under maintenance. The website will be back online approximately at {end_time}.',
                'coming_soon_mode' => false,
                'launch_time' => null,
                'coming_soon_message' => "We're launching soon! Our amazing platform will be available at {launch_time}.",
                'razorpay_key_id' => null,
                'razorpay_key_secret' => null,
                'app_store_link' => null,
                'play_store_link' => null,
            ]);
        }
        
        return redirect()->back()->with('success', 'Settings reset to default values successfully.');
    }
    
    /**
     * Clean the database by removing all user data
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\RedirectResponse
     */
    public function cleanDatabase(Request $request)
    {
        // Add database cleaning logic here
        // This is a placeholder implementation
        
        return redirect()->back()->with('success', 'Database cleaned successfully.');
    }
    
    /**
     * Export the full database
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\Response
     */
    public function exportDatabase(Request $request)
    {
        // Add database export logic here
        // This is a placeholder implementation
        
        return response()->download(public_path('sample.sql'), 'database_export.sql');
    }
}
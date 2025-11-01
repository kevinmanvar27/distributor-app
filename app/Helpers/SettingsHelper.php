<?php

if (!function_exists('tagline')) {
    /**
     * Get the tagline setting
     *
     * @return string
     */
    function tagline()
    {
        return setting('tagline', 'Quality hardware solutions for everyone');
    }
}

if (!function_exists('setting')) {
    /**
     * Get a setting value by key
     *
     * @param string $key
     * @param mixed $default
     * @return mixed
     */
    function setting($key, $default = null)
    {
        // Skip caching in testing environment
        if (app()->environment('testing')) {
            $settings = \App\Models\Setting::first();
            if ($settings && isset($settings->$key)) {
                return $settings->$key;
            }
            return $default;
        }
        
        static $settings = null;
        
        if ($settings === null) {
            $settings = \App\Models\Setting::first();
        }
        
        if ($settings && isset($settings->$key)) {
            return $settings->$key;
        }
        
        return $default;
    }
}

if (!function_exists('sidebar_text_color')) {
    /**
     * Get the sidebar text color setting
     *
     * @return string
     */
    function sidebar_text_color()
    {
        return setting('sidebar_text_color', '#333333');
    }
}

if (!function_exists('heading_text_color')) {
    /**
     * Get the heading text color setting
     *
     * @return string
     */
    function heading_text_color()
    {
        return setting('heading_text_color', '#333333');
    }
}

if (!function_exists('label_text_color')) {
    /**
     * Get the label text color setting
     *
     * @return string
     */
    function label_text_color()
    {
        return setting('label_text_color', '#333333');
    }
}

if (!function_exists('general_text_color')) {
    /**
     * Get the general text color setting
     *
     * @return string
     */
    function general_text_color()
    {
        return setting('general_text_color', '#333333');
    }
}

if (!function_exists('link_color')) {
    /**
     * Get the link color setting
     *
     * @return string
     */
    function link_color()
    {
        return setting('link_color', '#333333');
    }
}

if (!function_exists('link_hover_color')) {
    /**
     * Get the link hover color setting
     *
     * @return string
     */
    function link_hover_color()
    {
        return setting('link_hover_color', '#FF6B00');
    }
}

if (!function_exists('app_store_link')) {
    /**
     * Get the app store link setting
     *
     * @return string
     */
    function app_store_link()
    {
        return setting('app_store_link');
    }
}

if (!function_exists('play_store_link')) {
    /**
     * Get the play store link setting
     *
     * @return string
     */
    function play_store_link()
    {
        return setting('play_store_link');
    }
}

if (!function_exists('firebase_project_id')) {
    /**
     * Get the Firebase project ID setting
     *
     * @return string
     */
    function firebase_project_id()
    {
        return setting('firebase_project_id');
    }
}

if (!function_exists('firebase_client_email')) {
    /**
     * Get the Firebase client email setting
     *
     * @return string
     */
    function firebase_client_email()
    {
        return setting('firebase_client_email');
    }
}

if (!function_exists('firebase_private_key')) {
    /**
     * Get the Firebase private key setting
     *
     * @return string
     */
    function firebase_private_key()
    {
        return setting('firebase_private_key');
    }
}

if (!function_exists('is_firebase_configured')) {
    /**
     * Check if Firebase is properly configured
     *
     * @return bool
     */
    function is_firebase_configured()
    {
        return setting('firebase_project_id') && 
               setting('firebase_client_email') && 
               setting('firebase_private_key');
    }
}

if (!function_exists('user_role')) {
    /**
     * Get the current user's role
     *
     * @return string|null
     */
    function user_role()
    {
        if (\Illuminate\Support\Facades\Auth::check()) {
            return \Illuminate\Support\Facades\Auth::user()->user_role;
        }
        
        return null;
    }
}

if (!function_exists('has_role')) {
    /**
     * Check if the current user has a specific role
     *
     * @param string $role
     * @return bool
     */
    function has_role($role)
    {
        if (\Illuminate\Support\Facades\Auth::check()) {
            $user = \Illuminate\Support\Facades\Auth::user();
            // Handle IDE false positive by explicitly checking type
            if ($user instanceof \App\Models\User) {
                return $user->hasRole($role);
            }
        }
        
        return false;
    }
}

if (!function_exists('has_any_role')) {
    /**
     * Check if the current user has any of the specified roles
     *
     * @param array $roles
     * @return bool
     */
    function has_any_role($roles)
    {
        if (\Illuminate\Support\Facades\Auth::check()) {
            $user = \Illuminate\Support\Facades\Auth::user();
            // Handle IDE false positive by explicitly checking type
            if ($user instanceof \App\Models\User) {
                return $user->hasAnyRole($roles);
            }
        }
        
        return false;
    }
}

if (!function_exists('is_admin')) {
    /**
     * Check if the current user is an admin
     *
     * @return bool
     */
    function is_admin()
    {
        if (\Illuminate\Support\Facades\Auth::check()) {
            $user = \Illuminate\Support\Facades\Auth::user();
            // Handle IDE false positive by explicitly checking type
            if ($user instanceof \App\Models\User) {
                return $user->isAdmin();
            }
        }
        
        return false;
    }
}

if (!function_exists('is_super_admin')) {
    /**
     * Check if the current user is a super admin
     *
     * @return bool
     */
    function is_super_admin()
    {
        if (\Illuminate\Support\Facades\Auth::check()) {
            $user = \Illuminate\Support\Facades\Auth::user();
            // Handle IDE false positive by explicitly checking type
            if ($user instanceof \App\Models\User) {
                return $user->isSuperAdmin();
            }
        }
        
        return false;
    }
}

<?php

namespace App\Http\Controllers\Frontend;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class FrontendController extends Controller
{
    /**
     * Show the home page
     *
     * @return \Illuminate\View\View
     */
    public function index()
    {
        return view('frontend.home');
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
<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\User;
use App\Models\UserGroup;
use App\Models\Product;
use App\Models\Category;

class DashboardController extends Controller
{
    /**
     * Show the dashboard
     *
     * @return \Illuminate\View\View
     */
    public function index()
    {
        $userCount = User::count();
        $userGroupCount = UserGroup::count();
        $productCount = Product::count();
        $categoryCount = Category::count();

        return view('admin.dashboard.index', compact('userCount', 'userGroupCount', 'productCount', 'categoryCount'));
    }
}
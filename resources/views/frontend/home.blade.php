@extends('frontend.layouts.app')

@section('title', 'Home - ' . setting('site_title', 'Frontend App'))

@section('content')
<div class="container-fluid px-0">
    <!-- Hero Section -->
    <div class="hero-section text-center py-5 mb-5" style="background: linear-gradient(135deg, {{ setting('theme_color', '#007bff') }} 0%, {{ setting('link_hover_color', '#0056b3') }} 100%); color: white;">
        <div class="container">
            <div class="row justify-content-center">
                <div class="col-lg-8">
                    <h1 class="display-4 fw-bold mb-4">Welcome to {{ setting('site_title', 'Frontend App') }}</h1>
                    <p class="lead mb-4">
                        @auth
                            Welcome back, {{ Auth::user()->name }}! Explore our latest products and categories.
                        @else
                            Discover our amazing products and categories. Join us today!
                        @endauth
                    </p>
                    @auth
                    <div class="d-flex justify-content-center gap-3">
                        <a href="{{ route('frontend.profile') }}" class="btn btn-light btn-lg rounded-pill px-4">
                            <i class="fas fa-user me-2"></i>My Profile
                        </a>
                        <form method="POST" action="{{ route('frontend.logout') }}" class="d-inline">
                            @csrf
                            <button type="submit" class="btn btn-outline-light btn-lg rounded-pill px-4">
                                <i class="fas fa-sign-out-alt me-2"></i>Logout
                            </button>
                        </form>
                    </div>
                    @else
                    <div class="d-flex justify-content-center gap-3">
                        <a href="{{ route('frontend.login') }}" class="btn btn-light btn-lg rounded-pill px-4">
                            <i class="fas fa-sign-in-alt me-2"></i>Login
                        </a>
                        <a href="{{ route('frontend.register') }}" class="btn btn-outline-light btn-lg rounded-pill px-4">
                            <i class="fas fa-user-plus me-2"></i>Register
                        </a>
                    </div>
                    @endauth
                </div>
            </div>
        </div>
    </div>
</div>

<div class="container">
    <!-- Categories Section -->
    <div class="section mb-5">
        <div class="row mb-4">
            <div class="col-12">
                <div class="d-flex justify-content-between align-items-center">
                    <h2 class="mb-0 heading-text" style="color: {{ setting('theme_color', '#007bff') }};">
                        <i class="fas fa-tags me-2"></i>Categories
                    </h2>
                    <a href="#" class="btn btn-theme">View All</a>
                </div>
                <hr class="my-3">
            </div>
        </div>
        
        @if($categories->count() > 0)
        <div class="row">
            @foreach($categories as $category)
            <div class="col-md-6 col-lg-4 col-xl-3 mb-4">
                <div class="card h-100 shadow-sm border-0 category-card">
                    <div class="position-relative">
                        @if($category->image)
                            <img src="{{ $category->image->url }}" class="card-img-top" alt="{{ $category->name }}" style="height: 200px; object-fit: cover;">
                        @else
                            <div class="bg-light d-flex align-items-center justify-content-center" style="height: 200px;">
                                <i class="fas fa-image fa-3x text-muted"></i>
                            </div>
                        @endif
                        <div class="position-absolute top-0 end-0 m-2">
                            <span class="badge bg-theme text-white">{{ $category->is_active ? 'Active' : 'Inactive' }}</span>
                        </div>
                    </div>
                    <div class="card-body d-flex flex-column">
                        <h5 class="card-title">{{ $category->name }}</h5>
                        <p class="card-text flex-grow-1">{{ Str::limit($category->description ?? 'No description available', 100) }}</p>
                        <div class="mt-auto">
                            <small class="text-muted">{{ $category->subCategories->count() }} subcategories</small>
                        </div>
                    </div>
                    <div class="card-footer bg-transparent border-0">
                        <a href="#" class="btn btn-theme w-100">Explore</a>
                    </div>
                </div>
            </div>
            @endforeach
        </div>
        @else
        <div class="row">
            <div class="col-12">
                <div class="alert alert-info text-center">
                    <i class="fas fa-info-circle me-2"></i>No categories available at the moment.
                </div>
            </div>
        </div>
        @endif
    </div>
    
    <!-- Products Section -->
    <div class="section mb-5">
        <div class="row mb-4">
            <div class="col-12">
                <div class="d-flex justify-content-between align-items-center">
                    <h2 class="mb-0 heading-text" style="color: {{ setting('theme_color', '#007bff') }};">
                        <i class="fas fa-box-open me-2"></i>Products
                    </h2>
                    <a href="#" class="btn btn-theme">View All</a>
                </div>
                <hr class="my-3">
            </div>
        </div>
        
        @if($products->count() > 0)
        <div class="row">
            @foreach($products as $product)
            <div class="col-md-6 col-lg-4 col-xl-3 mb-4">
                <div class="card h-100 shadow-sm border-0 product-card">
                    <div class="position-relative">
                        @if($product->mainPhoto)
                            <img src="{{ $product->mainPhoto->url }}" class="card-img-top" alt="{{ $product->name }}" style="height: 200px; object-fit: cover;">
                        @else
                            <div class="bg-light d-flex align-items-center justify-content-center" style="height: 200px;">
                                <i class="fas fa-image fa-3x text-muted"></i>
                            </div>
                        @endif
                        <div class="position-absolute top-0 end-0 m-2">
                            <span class="badge bg-success text-white">{{ ucfirst($product->status) }}</span>
                        </div>
                    </div>
                    <div class="card-body d-flex flex-column">
                        <h5 class="card-title">{{ $product->name }}</h5>
                        <p class="card-text flex-grow-1">{{ Str::limit($product->description ?? 'No description available', 100) }}</p>
                        <div class="mt-auto">
                            <div class="d-flex justify-content-between align-items-center">
                                <p class="fw-bold text-success mb-0">₹{{ number_format($product->selling_price, 2) }}</p>
                                @if($product->mrp > $product->selling_price)
                                    <small class="text-muted text-decoration-line-through">₹{{ number_format($product->mrp, 2) }}</small>
                                @endif
                            </div>
                            <div class="mt-2">
                                <small class="text-muted">
                                    @if($product->in_stock)
                                        <i class="fas fa-check-circle text-success me-1"></i>In Stock ({{ $product->stock_quantity }})
                                    @else
                                        <i class="fas fa-times-circle text-danger me-1"></i>Out of Stock
                                    @endif
                                </small>
                            </div>
                        </div>
                    </div>
                    <div class="card-footer bg-transparent border-0">
                        <div class="d-grid gap-2">
                            <a href="#" class="btn btn-theme">Buy Now</a>
                            <a href="#" class="btn btn-outline-theme">
                                <i class="fas fa-shopping-cart me-1"></i>Add to Cart
                            </a>
                        </div>
                    </div>
                </div>
            </div>
            @endforeach
        </div>
        @else
        <div class="row">
            <div class="col-12">
                <div class="alert alert-info text-center">
                    <i class="fas fa-info-circle me-2"></i>No products available at the moment.
                </div>
            </div>
        </div>
        @endif
    </div>
</div>

<style>
    .hero-section {
        background-size: cover;
        background-position: center;
    }
    
    .category-card:hover, .product-card:hover {
        transform: translateY(-5px);
        transition: transform 0.3s ease;
        box-shadow: 0 10px 20px rgba(0,0,0,0.1);
    }
    
    .btn-theme {
        background-color: {{ setting('theme_color', '#007bff') }} !important;
        border-color: {{ setting('theme_color', '#007bff') }} !important;
        color: white !important;
    }
    
    .btn-theme:hover {
        background-color: {{ setting('link_hover_color', '#0056b3') }} !important;
        border-color: {{ setting('link_hover_color', '#0056b3') }} !important;
    }
    
    .btn-outline-theme {
        border-color: {{ setting('theme_color', '#007bff') }} !important;
        color: {{ setting('theme_color', '#007bff') }} !important;
    }
    
    .btn-outline-theme:hover {
        background-color: {{ setting('theme_color', '#007bff') }} !important;
        border-color: {{ setting('theme_color', '#007bff') }} !important;
        color: white !important;
    }
    
    .badge.bg-theme {
        background-color: {{ setting('theme_color', '#007bff') }} !important;
    }
    
    .section {
        animation: fadeIn 0.5s ease-in;
    }
    
    @keyframes fadeIn {
        from { opacity: 0; }
        to { opacity: 1; }
    }
</style>
@endsection
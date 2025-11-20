@extends('frontend.layouts.app')

@section('title', $metaTitle ?? 'Category - ' . setting('site_title', 'Frontend App'))
@section('meta_description', $metaDescription ?? setting('tagline', 'Your Frontend Application'))

@section('content')
<div class="container">
    <!-- Breadcrumb -->
    <nav aria-label="breadcrumb" class="my-4">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="{{ route('frontend.home') }}">Home</a></li>
            <li class="breadcrumb-item active" aria-current="page">{{ $category->name }}</li>
        </ol>
    </nav>
    
    <!-- Category Header -->
    <div class="row mb-5">
        <div class="col-12">
            <div class="card border-0 shadow-sm">
                <div class="card-body">
                    <div class="row align-items-center">
                        <div class="col-md-3 text-center mb-4 mb-md-0">
                            @if($category->image)
                                <img src="{{ $category->image->url }}" class="img-fluid rounded" alt="{{ $category->name }}" style="max-height: 200px; object-fit: cover;">
                            @else
                                <div class="bg-light d-flex align-items-center justify-content-center rounded" style="height: 200px;">
                                    <i class="fas fa-image fa-3x text-muted"></i>
                                </div>
                            @endif
                        </div>
                        <div class="col-md-9">
                            <h1 class="mb-3 heading-text">{{ $category->name }}</h1>
                            <p class="lead general-text">{{ $category->description ?? 'No description available for this category.' }}</p>
                            <div class="d-flex align-items-center">
                                <span class="badge bg-success me-2">{{ $subCategories->count() }} Subcategories</span>
                                <span class="badge bg-primary">{{ $products->count() }} Products</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>
    
    <!-- Subcategories Section -->
    @if($subCategories->count() > 0)
    <div class="section mb-5">
        <div class="row mb-4">
            <div class="col-12">
                <h2 class="mb-0 heading-text">
                    <i class="fas fa-tags me-2"></i>Subcategories
                </h2>
                <hr class="my-3">
            </div>
        </div>
        
        <div class="row">
            @foreach($subCategories as $subCategory)
            <div class="col-md-6 col-lg-4 col-xl-3 mb-4">
                <div class="card h-100 shadow-sm border-0 category-card">
                    <div class="position-relative">
                        @if($subCategory->image)
                            <img src="{{ $subCategory->image->url }}" class="card-img-top" alt="{{ $subCategory->name }}" style="height: 150px; object-fit: cover;">
                        @else
                            <div class="bg-light d-flex align-items-center justify-content-center" style="height: 150px;">
                                <i class="fas fa-image fa-2x text-muted"></i>
                            </div>
                        @endif
                        <div class="position-absolute top-0 end-0 m-2">
                            <span class="badge bg-theme text-white">{{ $subCategory->is_active ? 'Active' : 'Inactive' }}</span>
                        </div>
                    </div>
                    <div class="card-body d-flex flex-column">
                        <h5 class="card-title">{{ $subCategory->name }}</h5>
                        <p class="card-text flex-grow-1">{{ Str::limit($subCategory->description ?? 'No description available', 100) }}</p>
                    </div>
                </div>
            </div>
            @endforeach
        </div>
    </div>
    @endif
    
    <!-- Products Section -->
    <div class="section mb-5">
        <div class="row mb-4">
            <div class="col-12">
                <h2 class="mb-0 heading-text">
                    <i class="fas fa-box-open me-2"></i>Products
                </h2>
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
                            <button type="button" class="btn btn-theme buy-now-btn" data-product-id="{{ $product->id }}">
                                Buy Now
                            </button>
                            <button type="button" class="btn btn-outline-theme add-to-cart-btn" data-product-id="{{ $product->id }}">
                                <i class="fas fa-shopping-cart me-1"></i>Add to Cart
                            </button>
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
                    <i class="fas fa-info-circle me-2"></i>No products available in this category at the moment.
                </div>
            </div>
        </div>
        @endif
    </div>
</div>

<style>
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
    
    /* Responsive adjustments */
    @media (max-width: 768px) {
        .card-img-top {
            height: 150px !important;
        }
    }
</style>
@endsection
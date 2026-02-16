@extends('frontend.layouts.app')

@section('title', 'Home - ' . setting('site_title', 'Frontend App'))

@section('content')
<div class="container-fluid px-0">
    <!-- Hero Section -->
    <div class="hero-section text-center py-5 mb-5">
        <div class="container">
            <div class="row justify-content-center">
                <div class="col-lg-9 col-xl-8">
                    <h1 class="display-3 fw-bold mb-4 fade-in" style="color: white !important;">
                        Welcome to {{ setting('site_title', 'Frontend App') }}
                    </h1>
                    <p class="lead mb-5 fade-in" style="color: rgba(255,255,255,0.95) !important; font-size: 1.25rem; line-height: 1.8;">
                        @auth
                            Welcome back, <strong>{{ Auth::user()->name }}</strong>! Explore our latest products and categories.
                        @else
                            Discover our amazing products and categories. Join us today for the best deals!
                        @endauth
                    </p>
                    @auth
                    <div class="d-flex justify-content-center gap-3 flex-wrap fade-in">
                        <a href="{{ route('frontend.profile') }}" class="btn btn-light btn-lg rounded-pill px-5 py-3 btn-ripple hover-lift">
                            <i class="fas fa-user me-2"></i>My Profile
                        </a>
                        <a href="{{ route('frontend.cart.index') }}" class="btn btn-outline-light btn-lg rounded-pill px-5 py-3 btn-ripple hover-lift">
                            <i class="fas fa-shopping-cart me-2"></i>View Cart
                        </a>
                    </div>
                    @else
                    <div class="d-flex justify-content-center gap-3 flex-wrap fade-in">
                        <a href="{{ route('frontend.login') }}" class="btn btn-light btn-lg rounded-pill px-5 py-3 btn-ripple hover-lift">
                            <i class="fas fa-sign-in-alt me-2"></i>Login
                        </a>
                        <a href="{{ route('frontend.register') }}" class="btn btn-outline-light btn-lg rounded-pill px-5 py-3 btn-ripple hover-lift">
                            <i class="fas fa-user-plus me-2"></i>Register
                        </a>
                    </div>
                    @endauth
                </div>
            </div>
        </div>
    </div>
</div>

<div class="container py-5">
    <!-- Categories Section -->
    <div class="section mb-5">
        <div class="row mb-4 align-items-center">
            <div class="col-md-8">
                <h2 class="mb-2 fw-bold" style="color: var(--heading-text-color); font-size: 2rem;">
                    <i class="fas fa-tags me-3" style="color: var(--theme-color);"></i>Browse Categories
                </h2>
                <p class="text-muted mb-0">Explore our wide range of product categories</p>
            </div>
            <div class="col-md-4 text-md-end mt-3 mt-md-0">
                <a href="#" class="btn btn-outline-theme btn-ripple hover-lift">
                    <i class="fas fa-th-large me-2"></i>View All Categories
                </a>
            </div>
        </div>
        
        @if($categories->count() > 0)
        <div class="row g-4">
            @foreach($categories as $index => $category)
            <div class="col-sm-6 col-md-4 col-lg-3 fade-in" style="animation-delay: {{ $index * 0.1 }}s;">
                <div class="card h-100 border-0 category-card">
                    <div class="position-relative overflow-hidden" style="border-radius: var(--radius-lg) var(--radius-lg) 0 0;">
                        @if($category->image)
                            <img src="{{ $category->image->url }}" class="card-img-top" alt="{{ $category->name }}" style="height: 220px; object-fit: cover;">
                        @else
                            <div class="bg-gradient-theme d-flex align-items-center justify-content-center" style="height: 220px;">
                                <i class="fas fa-image fa-4x text-white opacity-50"></i>
                            </div>
                        @endif
                        @if($category->product_count > 0)
                        <div class="position-absolute top-0 end-0 m-3">
                            <span class="badge bg-success shadow-sm" style="font-size: 0.875rem; padding: 0.5rem 0.875rem;">
                                {{ $category->product_count }} Products
                            </span>
                        </div>
                        @endif
                    </div>
                    <div class="card-body d-flex flex-column p-4">
                        <h5 class="card-title fw-bold mb-2" style="color: var(--heading-text-color);">{{ $category->name }}</h5>
                        <p class="card-text text-muted flex-grow-1 mb-3" style="font-size: 0.9375rem;">
                            {{ Str::limit($category->description ?? 'Explore our collection', 80) }}
                        </p>
                        <div class="d-flex align-items-center text-muted" style="font-size: 0.875rem;">
                            <i class="fas fa-layer-group me-2 text-theme"></i>
                            <span>{{ $category->subCategories->count() }} Subcategories</span>
                        </div>
                    </div>
                    <div class="card-footer bg-transparent border-0 p-4 pt-0">
                        <a href="{{ route('frontend.category.show', $category) }}" class="btn btn-theme w-100 btn-ripple hover-lift">
                            <i class="fas fa-arrow-right me-2"></i>Explore Category
                        </a>
                    </div>
                </div>
            </div>
            @endforeach
        </div>
        @else
        <div class="row">
            <div class="col-12">
                <div class="alert alert-info d-flex align-items-center" style="border-radius: var(--radius-lg);">
                    <i class="fas fa-info-circle me-3" style="font-size: 1.5rem;"></i>
                    <div>
                        <h5 class="mb-1">No Categories Available</h5>
                        <p class="mb-0">Categories will appear here once they are added.</p>
                    </div>
                </div>
            </div>
        </div>
        @endif
    </div>
    
    <!-- Products Section -->
    <div class="section mb-5">
        <div class="row mb-4 align-items-center">
            <div class="col-md-8">
                <h2 class="mb-2 fw-bold" style="color: var(--heading-text-color); font-size: 2rem;">
                    <i class="fas fa-box-open me-3" style="color: var(--theme-color);"></i>Featured Products
                </h2>
                <p class="text-muted mb-0">Check out our latest and most popular products</p>
            </div>
            <div class="col-md-4 text-md-end mt-3 mt-md-0">
                <a href="#" class="btn btn-outline-theme btn-ripple hover-lift">
                    <i class="fas fa-shopping-bag me-2"></i>View All Products
                </a>
            </div>
        </div>
        
        @if($products->count() > 0)
        <div class="row g-4">
            @foreach($products as $index => $product)
            <div class="col-sm-6 col-md-4 col-lg-3 fade-in" style="animation-delay: {{ $index * 0.1 }}s;">
                <div class="card h-100 border-0 product-card">
                    <div class="position-relative overflow-hidden" style="border-radius: var(--radius-lg) var(--radius-lg) 0 0;">
                        @if($product->mainPhoto)
                            <img src="{{ $product->mainPhoto->url }}" class="card-img-top" alt="{{ $product->name }}" style="height: 220px; object-fit: cover;">
                        @else
                            <div class="bg-gradient-theme d-flex align-items-center justify-content-center" style="height: 220px;">
                                <i class="fas fa-image fa-4x text-white opacity-50"></i>
                            </div>
                        @endif
                        <div class="position-absolute top-0 end-0 m-3">
                            <span class="badge {{ $product->status === 'active' || $product->status === 'published' ? 'bg-success' : 'bg-secondary' }} shadow-sm">
                                {{ ucfirst($product->status) }}
                            </span>
                        </div>
                        @php
                            $hasSellingPrice = !is_null($product->selling_price) && $product->selling_price !== '';
                            if ($hasSellingPrice && $product->mrp > $product->selling_price) {
                                $discountPercent = round((($product->mrp - $product->selling_price) / $product->mrp) * 100);
                            }
                        @endphp
                        @if(isset($discountPercent) && $discountPercent > 0)
                        <div class="position-absolute top-0 start-0 m-3">
                            <span class="badge bg-danger shadow-sm" style="font-size: 0.875rem; padding: 0.5rem 0.875rem;">
                                {{ $discountPercent }}% OFF
                            </span>
                        </div>
                        @endif
                    </div>
                    <div class="card-body d-flex flex-column p-4">
                        <h5 class="card-title fw-bold mb-2" style="color: var(--heading-text-color);">
                            <a href="{{ route('frontend.product.show', $product->slug) }}" class="text-decoration-none" style="color: inherit;">
                                {{ Str::limit($product->name, 50) }}
                            </a>
                        </h5>
                        <p class="card-text text-muted flex-grow-1 mb-3" style="font-size: 0.875rem; line-height: 1.6;">
                            {{ Str::limit($product->description ?? 'No description available', 80) }}
                        </p>
                        
                        <!-- Price Section -->
                        <div class="mb-3">
                            @php
                                $displayPrice = $hasSellingPrice ? $product->selling_price : $product->mrp;
                                $calculatedPrice = $displayPrice;
                                
                                if (Auth::check() && $hasSellingPrice) {
                                    $user = Auth::user();
                                    
                                    if (!is_null($user->discount_percentage) && $user->discount_percentage > 0) {
                                        $calculatedPrice = $product->selling_price * (1 - $user->discount_percentage / 100);
                                    } else {
                                        $userGroups = $user->userGroups;
                                        if ($userGroups->count() > 0) {
                                            $highestGroupDiscount = 0;
                                            foreach ($userGroups as $group) {
                                                if (!is_null($group->discount_percentage) && $group->discount_percentage > $highestGroupDiscount) {
                                                    $highestGroupDiscount = $group->discount_percentage;
                                                }
                                            }
                                            
                                            if ($highestGroupDiscount > 0) {
                                                $calculatedPrice = $product->selling_price * (1 - $highestGroupDiscount / 100);
                                            }
                                        }
                                    }
                                }
                            @endphp
                            <div class="d-flex align-items-center gap-2 flex-wrap">
                                <span class="price-tag" style="font-size: 1.5rem; font-weight: 700; color: var(--theme-color);">
                                    ₹{{ number_format($calculatedPrice, 2) }}
                                </span>
                                @if($hasSellingPrice && $product->mrp > $product->selling_price)
                                    <span class="original-price" style="font-size: 1rem;">
                                        ₹{{ number_format($product->mrp, 2) }}
                                    </span>
                                @endif
                            </div>
                        </div>
                        
                        <!-- Stock Status -->
                        <div class="mb-3">
                            @php
                                $displayStock = $product->isVariable() ? $product->total_stock : $product->stock_quantity;
                                $isInStock = $displayStock > 0;
                            @endphp
                            @if($isInStock)
                                <small class="text-success d-flex align-items-center">
                                    <i class="fas fa-check-circle me-2"></i>
                                    <span class="fw-medium">In Stock ({{ $displayStock }} available)</span>
                                </small>
                            @else
                                <small class="text-danger d-flex align-items-center">
                                    <i class="fas fa-times-circle me-2"></i>
                                    <span class="fw-medium">Out of Stock</span>
                                </small>
                            @endif
                        </div>
                    </div>
                    
                    <div class="card-footer bg-transparent border-0 p-4 pt-0">
                        @if($product->isVariable())
                            <a href="{{ route('frontend.product.show', $product->slug) }}" class="btn btn-theme w-100 btn-ripple hover-lift">
                                <i class="fas fa-eye me-2"></i>View Options
                            </a>
                        @else
                            <div class="d-grid gap-2">
                                <button type="button" class="btn btn-theme buy-now-btn btn-ripple hover-lift" data-product-id="{{ $product->id }}">
                                    <i class="fas fa-bolt me-2"></i>Buy Now
                                </button>
                                <button type="button" class="btn btn-outline-theme add-to-cart-btn btn-ripple hover-lift" data-product-id="{{ $product->id }}">
                                    <i class="fas fa-shopping-cart me-2"></i>Add to Cart
                                </button>
                            </div>
                        @endif
                    </div>
                </div>
            </div>
            @endforeach
        </div>
        @else
        <div class="row">
            <div class="col-12">
                <div class="alert alert-info d-flex align-items-center" style="border-radius: var(--radius-lg);">
                    <i class="fas fa-info-circle me-3" style="font-size: 1.5rem;"></i>
                    <div>
                        <h5 class="mb-1">No Products Available</h5>
                        <p class="mb-0">Products will appear here once they are added.</p>
                    </div>
                </div>
            </div>
        </div>
        @endif
    </div>
</div>

<style>
    /* Additional page-specific styles */
    .hero-section {
        background: linear-gradient(135deg, var(--theme-color) 0%, var(--link-hover-color) 100%);
        position: relative;
        overflow: hidden;
    }
    
    .hero-section::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: 
            radial-gradient(circle at 20% 50%, rgba(255, 255, 255, 0.1) 0%, transparent 50%),
            radial-gradient(circle at 80% 80%, rgba(255, 255, 255, 0.1) 0%, transparent 50%),
            radial-gradient(circle at 40% 20%, rgba(255, 255, 255, 0.05) 0%, transparent 40%);
        pointer-events: none;
    }
    
    .category-card,
    .product-card {
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
    }
    
    .category-card:hover,
    .product-card:hover {
        transform: translateY(-8px) scale(1.02);
    }
    
    @media (max-width: 768px) {
        .hero-section .display-3 {
            font-size: 2.25rem !important;
        }
        
        .hero-section .lead {
            font-size: 1rem !important;
        }
    }
</style>
@endsection

@section('scripts')
<script>
$(document).ready(function() {
    $('.explore-btn').on('click', function() {
        var categoryId = $(this).data('category-id');
        var categoryName = $(this).data('category-name');
        var card = $(this).closest('.card');
        
        if (card.find('.subcategories-container').length > 0) {
            card.find('.subcategories-container').slideToggle(300);
            $(this).text(card.find('.subcategories-container').is(':visible') ? 'Hide Subcategories' : 'Explore');
            return;
        }
        
        var originalText = $(this).text();
        $(this).html('<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Loading...');
        $(this).prop('disabled', true);
        
        $.ajax({
            url: '/frontend/category/' + categoryId + '/subcategories',
            type: 'GET',
            dataType: 'html',
            success: function(response) {
                var subContainer = $('<div class="subcategories-container mt-3" style="display: none;"></div>');
                subContainer.html(response);
                card.find('.card-body').append(subContainer);
                subContainer.slideDown(300);
                
                $('.explore-btn[data-category-id="' + categoryId + '"]').text('Hide Subcategories');
            },
            error: function(xhr, status, error) {
                console.error('AJAX Error:', error);
                showToast('Error loading subcategories. Please try again.', 'error');
                $('.explore-btn[data-category-id="' + categoryId + '"]').text(originalText);
            },
            complete: function() {
                $('.explore-btn[data-category-id="' + categoryId + '"]').prop('disabled', false);
            }
        });
    });
});
</script>
@endsection

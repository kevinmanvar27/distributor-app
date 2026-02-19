@extends('frontend.layouts.app')

@section('title', 'All Products - ' . setting('site_title', 'Frontend App'))

@section('content')
<div class="container py-5">
    <!-- Page Header -->
    <div class="row mb-4">
        <div class="col-md-8">
            <h1 class="display-4 fw-bold mb-3" style="color: var(--heading-text-color);">
                <i class="fas fa-box-open me-3" style="color: var(--theme-color);"></i>All Products
            </h1>
            <p class="lead text-muted">Browse through all our available products</p>
        </div>
        <div class="col-md-4 text-md-end mt-3 mt-md-0">
            <div class="dropdown">
                <button class="btn btn-outline-theme dropdown-toggle" type="button" id="sortDropdown" data-bs-toggle="dropdown" aria-expanded="false">
                    <i class="fas fa-sort me-2"></i>Sort By
                </button>
                <ul class="dropdown-menu" aria-labelledby="sortDropdown">
                    <li><a class="dropdown-item {{ $sort === 'default' ? 'active' : '' }}" href="{{ route('frontend.products.all') }}">Default</a></li>
                    <li><a class="dropdown-item {{ $sort === 'name' ? 'active' : '' }}" href="{{ route('frontend.products.all', ['sort' => 'name']) }}">Name (A-Z)</a></li>
                    <li><a class="dropdown-item {{ $sort === 'price-low' ? 'active' : '' }}" href="{{ route('frontend.products.all', ['sort' => 'price-low']) }}">Price: Low to High</a></li>
                    <li><a class="dropdown-item {{ $sort === 'price-high' ? 'active' : '' }}" href="{{ route('frontend.products.all', ['sort' => 'price-high']) }}">Price: High to Low</a></li>
                </ul>
            </div>
        </div>
    </div>
    
    @if($products->count() > 0)
    <div class="row g-4" id="products-container">
        @foreach($products->take(8) as $index => $product)
        <div class="col-sm-6 col-md-4 col-lg-3 fade-in product-item" style="animation-delay: {{ $index * 0.05 }}s;">
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
                    @auth
                    <button class="btn btn-sm btn-light position-absolute top-0 start-0 m-3 wishlist-btn {{ $product->isInWishlist(Auth::id()) ? 'in-wishlist' : '' }}" 
                            data-product-id="{{ $product->id }}"
                            title="{{ $product->isInWishlist(Auth::id()) ? 'Remove from wishlist' : 'Add to wishlist' }}"
                            style="border-radius: 50%; width: 40px; height: 40px; padding: 0; display: flex; align-items: center; justify-content: center;">
                        <i class="fas fa-heart {{ $product->isInWishlist(Auth::id()) ? 'text-danger' : '' }}"></i>
                    </button>
                    @endauth
                    @php
                        $hasSellingPrice = !is_null($product->selling_price) && $product->selling_price !== '';
                        if ($hasSellingPrice && $product->mrp > $product->selling_price) {
                            $discountPercent = round((($product->mrp - $product->selling_price) / $product->mrp) * 100);
                        }
                    @endphp
                    @if(isset($discountPercent) && $discountPercent > 0)
                    <div class="position-absolute bottom-0 start-0 m-3">
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
    
    @if($totalProducts > 8)
    <div class="row mt-5">
        <div class="col-12 text-center">
            <button id="load-more-btn" class="btn btn-theme btn-lg px-5 py-3 btn-ripple hover-lift" data-offset="8">
                <i class="fas fa-plus-circle me-2"></i>Load More Products
                <span class="ms-2 badge bg-white text-theme">{{ $totalProducts - 8 }} more</span>
            </button>
        </div>
    </div>
    @endif
    @else
    <div class="row">
        <div class="col-12">
            <div class="alert alert-info d-flex align-items-center justify-content-center" style="border-radius: var(--radius-lg); min-height: 300px;">
                <div class="text-center">
                    <i class="fas fa-info-circle mb-3" style="font-size: 3rem; color: var(--theme-color);"></i>
                    <h4 class="mb-2">No Products Available</h4>
                    <p class="mb-3">Products will appear here once they are added.</p>
                    <a href="{{ route('frontend.home') }}" class="btn btn-theme">
                        <i class="fas fa-home me-2"></i>Back to Home
                    </a>
                </div>
            </div>
        </div>
    </div>
    @endif
</div>

<style>
    .product-card {
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    }
    
    .product-card:hover {
        transform: translateY(-8px) scale(1.02);
        box-shadow: 0 8px 24px rgba(0,0,0,0.15);
    }
    
    .fade-in {
        animation: fadeInUp 0.6s ease-out forwards;
        opacity: 0;
    }
    
    @keyframes fadeInUp {
        from {
            opacity: 0;
            transform: translateY(30px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }
    
    .original-price {
        text-decoration: line-through;
        color: #999;
    }
</style>
@endsection

@section('scripts')
<script>
$(document).ready(function() {
    let isLoading = false;
    let currentOffset = 8;
    let remainingCount = {{ $totalProducts - 8 }};
    const currentSort = '{{ $sort }}';
    
    $('#load-more-btn').on('click', function() {
        if (isLoading) return;
        
        isLoading = true;
        const btn = $(this);
        const originalHtml = btn.html();
        
        // Show loading state
        btn.html('<span class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span>Loading...');
        btn.prop('disabled', true);
        
        $.ajax({
            url: '{{ route("frontend.products.all") }}',
            type: 'GET',
            data: {
                offset: currentOffset,
                sort: currentSort
            },
            dataType: 'json',
            success: function(response) {
                if (response.html) {
                    // Append new products
                    $('#products-container').append(response.html);
                    
                    // Trigger fade-in animation for new items
                    setTimeout(function() {
                        $('.product-item').each(function(index) {
                            $(this).css('animation-delay', (index * 0.05) + 's');
                        });
                    }, 50);
                    
                    // Update offset and remaining count
                    currentOffset = response.newOffset;
                    remainingCount = {{ $totalProducts }} - currentOffset;
                    
                    // Update or hide button
                    if (response.hasMore && remainingCount > 0) {
                        btn.html('<i class="fas fa-plus-circle me-2"></i>Load More Products<span class="ms-2 badge bg-white text-theme">' + remainingCount + ' more</span>');
                        btn.prop('disabled', false);
                    } else {
                        btn.fadeOut(300, function() {
                            $(this).remove();
                        });
                    }
                }
            },
            error: function(xhr, status, error) {
                console.error('Error loading more products:', error);
                btn.html(originalHtml);
                btn.prop('disabled', false);
                
                // Show error message
                showToast('Error loading more products. Please try again.', 'error');
            },
            complete: function() {
                isLoading = false;
            }
        });
    });
});
</script>
@endsection

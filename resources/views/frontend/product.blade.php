@extends('frontend.layouts.app')

@section('title', $metaTitle ?? 'Product - ' . setting('site_title', 'Frontend App'))
@section('meta_description', $metaDescription ?? setting('tagline', 'Your Frontend Application'))

@section('content')
<div class="container">
    <!-- Breadcrumb -->
    <nav aria-label="breadcrumb" class="my-4">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="{{ route('frontend.home') }}">Home</a></li>
            <li class="breadcrumb-item active" aria-current="page">{{ $product->name }}</li>
        </ol>
    </nav>
    
    <div class="row">
        <!-- Product Gallery -->
        <div class="col-lg-6 mb-4">
            <div class="card shadow-sm border-0">
                <div class="card-body">
                    <!-- Main Product Image -->
                    <div class="main-image-container mb-3">
                        @if($product->mainPhoto)
                            <img id="main-image" src="{{ $product->mainPhoto->url }}" class="img-fluid rounded" alt="{{ $product->name }}" style="width: 100%; height: 400px; object-fit: cover;">
                        @else
                            <div class="bg-light d-flex align-items-center justify-content-center rounded" style="width: 100%; height: 400px;">
                                <i class="fas fa-image fa-3x text-muted"></i>
                            </div>
                        @endif
                    </div>
                    
                    <!-- Thumbnail Gallery -->
                    @if($product->galleryMedia && count($product->galleryMedia) > 0)
                    <div class="thumbnail-gallery d-flex flex-wrap gap-2">
                        <!-- Main Photo Thumbnail -->
                        @if($product->mainPhoto)
                        <div class="thumbnail-item active" data-image="{{ $product->mainPhoto->url }}">
                            <img src="{{ $product->mainPhoto->url }}" class="img-thumbnail" alt="{{ $product->name }}" style="width: 80px; height: 80px; object-fit: cover;">
                        </div>
                        @endif
                        
                        <!-- Gallery Thumbnails -->
                        @foreach($product->galleryMedia as $media)
                        <div class="thumbnail-item" data-image="{{ $media->url }}">
                            <img src="{{ $media->url }}" class="img-thumbnail" alt="{{ $product->name }}" style="width: 80px; height: 80px; object-fit: cover;">
                        </div>
                        @endforeach
                    </div>
                    @endif
                </div>
            </div>
        </div>
        
        <!-- Product Details -->
        <div class="col-lg-6 mb-4">
            <div class="card shadow-sm border-0">
                <div class="card-body">
                    <!-- Product Name -->
                    <h1 class="heading-text mb-3">{{ $product->name }}</h1>
                    
                    <!-- Product Status -->
                    <div class="mb-3">
                        <span class="badge {{ $product->status === 'active' || $product->status === 'published' ? 'bg-success' : 'bg-secondary' }}">
                            {{ ucfirst($product->status) }}
                        </span>
                    </div>
                    
                    <!-- Pricing Information -->
                    <div class="pricing-section mb-4">
                        @php
                            $hasSellingPrice = !is_null($product->selling_price) && $product->selling_price !== '';
                            $displayPrice = $hasSellingPrice ? $product->selling_price : $product->mrp;
                            $calculatedPrice = $displayPrice;
                            
                            if (Auth::check() && $hasSellingPrice) {
                                $user = Auth::user();
                                
                                // Check for individual discount first
                                if (!is_null($user->discount_percentage) && $user->discount_percentage > 0) {
                                    $calculatedPrice = $product->selling_price * (1 - $user->discount_percentage / 100);
                                } 
                                // If no individual discount, check for group discount
                                else {
                                    // Get user's groups and find the one with the highest discount
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
                        
                        <div class="price-display">
                            <span class="fw-bold text-success h4">₹{{ number_format($calculatedPrice, 2) }}</span>
                            @if($hasSellingPrice && $product->mrp > $product->selling_price)
                                <span class="text-muted text-decoration-line-through ms-2">₹{{ number_format($product->mrp, 2) }}</span>
                                @php
                                    $discountPercentage = round((($product->mrp - $product->selling_price) / $product->mrp) * 100);
                                @endphp
                                <span class="badge bg-danger ms-2">{{ $discountPercentage }}% OFF</span>
                            @endif
                        </div>
                    </div>
                    
                    <!-- Availability Status -->
                    <div class="availability-section mb-4">
                        @if($product->in_stock)
                            <div class="d-flex align-items-center">
                                <i class="fas fa-check-circle text-success me-2"></i>
                                <span class="fw-bold text-success">In Stock</span>
                                <span class="ms-2">({{ $product->stock_quantity }} available)</span>
                            </div>
                        @else
                            <div class="d-flex align-items-center">
                                <i class="fas fa-times-circle text-danger me-2"></i>
                                <span class="fw-bold text-danger">Out of Stock</span>
                            </div>
                        @endif
                    </div>
                    
                    <!-- Action Buttons -->
                    <div class="action-buttons mb-4">
                        @if($product->in_stock)
                            <div class="d-grid gap-2">
                                <button type="button" class="btn btn-theme btn-lg buy-now-btn" data-product-id="{{ $product->id }}">
                                    <i class="fas fa-bolt me-2"></i>Buy Now
                                </button>
                                <button type="button" class="btn btn-outline-theme btn-lg add-to-cart-btn" data-product-id="{{ $product->id }}">
                                    <i class="fas fa-shopping-cart me-2"></i>Add to Cart
                                </button>
                            </div>
                        @else
                            <button type="button" class="btn btn-secondary btn-lg" disabled>
                                <i class="fas fa-exclamation-circle me-2"></i>Out of Stock
                            </button>
                        @endif
                    </div>
                    
                    <!-- Product Meta Information -->
                    <div class="product-meta">
                        <div class="row">
                            <div class="col-sm-6">
                                <p class="mb-1"><strong>SKU:</strong> {{ $product->id }}</p>
                                <p class="mb-1"><strong>Status:</strong> {{ ucfirst($product->status) }}</p>
                            </div>
                            <div class="col-sm-6">
                                @if($product->created_at)
                                    <p class="mb-1"><strong>Added:</strong> {{ $product->created_at->format('M d, Y') }}</p>
                                @endif
                                @if($product->updated_at)
                                    <p class="mb-1"><strong>Updated:</strong> {{ $product->updated_at->format('M d, Y') }}</p>
                                @endif
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Product Description -->
        <div class="col-12 mb-4">
            <div class="card shadow-sm border-0">
                <div class="card-body">
                    <h2 class="heading-text mb-3"><i class="fas fa-align-left me-2"></i>Product Description</h2>
                    <div class="general-text">
                        @if($product->description)
                            <p>{{ $product->description }}</p>
                        @else
                            <p class="text-muted">No description available for this product.</p>
                        @endif
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>

<!-- JavaScript for Image Gallery -->
<script>
document.addEventListener('DOMContentLoaded', function() {
    // Thumbnail click functionality
    const thumbnailItems = document.querySelectorAll('.thumbnail-item');
    const mainImage = document.getElementById('main-image');
    
    if (thumbnailItems.length > 0 && mainImage) {
        thumbnailItems.forEach(item => {
            item.addEventListener('click', function() {
                // Remove active class from all thumbnails
                thumbnailItems.forEach(thumb => thumb.classList.remove('active'));
                
                // Add active class to clicked thumbnail
                this.classList.add('active');
                
                // Update main image
                const imageUrl = this.getAttribute('data-image');
                mainImage.src = imageUrl;
                mainImage.alt = "{{ $product->name }}";
            });
        });
    }
});
</script>

<style>
    :root {
        --theme-color: {{ setting('theme_color', '#007bff') }};
        --hover-color: {{ setting('link_hover_color', '#0056b3') }};
    }
    
    .thumbnail-item {
        cursor: pointer;
        border: 2px solid transparent;
        transition: all 0.2s ease;
    }
    
    .thumbnail-item:hover {
        border-color: var(--theme-color);
    }
    
    .thumbnail-item.active {
        border-color: var(--theme-color);
        box-shadow: 0 0 0 2px rgba(0, 123, 255, 0.25);
    }
    
    .btn-theme {
        background-color: var(--theme-color) !important;
        border-color: var(--theme-color) !important;
        color: white !important;
    }
    
    .btn-theme:hover {
        background-color: var(--hover-color) !important;
        border-color: var(--hover-color) !important;
    }
    
    .btn-outline-theme {
        border-color: var(--theme-color) !important;
        color: var(--theme-color) !important;
    }
    
    .btn-outline-theme:hover {
        background-color: var(--theme-color) !important;
        border-color: var(--theme-color) !important;
        color: white !important;
    }
    
    .price-display {
        font-size: 1.5rem;
    }
    
    @media (max-width: 768px) {
        .main-image-container img {
            height: 300px !important;
        }
        
        .thumbnail-item img {
            width: 60px !important;
            height: 60px !important;
        }
        
        .price-display {
            font-size: 1.25rem;
        }
    }
</style>
@endsection
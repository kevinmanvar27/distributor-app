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
            <div class="card shadow-sm border-0 product-gallery-card hover-lift">
                <div class="card-body">
                    <!-- Main Product Image -->
                    <div class="main-image-container mb-3">
                        @if($product->mainPhoto)
                            <img id="main-image" src="{{ $product->mainPhoto->url }}" class="img-fluid rounded main-product-image" alt="{{ $product->name }}" style="width: 100%; height: 400px; object-fit: cover;">
                        @else
                            <div class="bg-light d-flex align-items-center justify-content-center rounded" style="width: 100%; height: 400px;">
                                <i class="fas fa-image fa-3x text-muted"></i>
                            </div>
                        @endif
                        
                        <!-- Image Zoom Overlay -->
                        <div class="image-zoom-overlay">
                            <i class="fas fa-search-plus"></i>
                        </div>
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
                        @foreach($product->galleryMedia as $index => $media)
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
            <div class="card shadow-sm border-0 product-details-card hover-lift">
                <div class="card-body">
                    <!-- Product Name -->
                    <h1 class="heading-text mb-3 product-title">{{ $product->name }}</h1>
                    
                    <!-- Product Status -->
                    <div class="mb-3">
                        <span class="badge status-badge {{ $product->status === 'active' || $product->status === 'published' ? 'bg-success' : 'bg-secondary' }}">
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
                                
                                if (!is_null($user->discount_percentage) && $user->discount_percentage > 0) {
                                    $calculatedPrice = $product->selling_price * (1 - $user->discount_percentage / 100);
                                } 
                                else {
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
                            <span class="fw-bold text-success h4 current-price">₹{{ number_format($calculatedPrice, 2) }}</span>
                            @if($hasSellingPrice && $product->mrp > $product->selling_price)
                                <span class="text-muted text-decoration-line-through ms-2 original-price">₹{{ number_format($product->mrp, 2) }}</span>
                                @php
                                    $discountPercentage = round((($product->mrp - $product->selling_price) / $product->mrp) * 100);
                                @endphp
                                <span class="badge bg-danger ms-2 discount-badge">{{ $discountPercentage }}% OFF</span>
                            @endif
                        </div>
                    </div>
                    
                    <!-- Availability Status -->
                    <div class="availability-section mb-4">
                        @if($product->in_stock)
                            <div class="d-flex align-items-center stock-status in-stock">
                                <i class="fas fa-check-circle text-success me-2 stock-icon"></i>
                                <span class="fw-bold text-success">In Stock</span>
                                <span class="ms-2 stock-quantity">({{ $product->stock_quantity }} available)</span>
                            </div>
                        @else
                            <div class="d-flex align-items-center stock-status out-of-stock">
                                <i class="fas fa-times-circle text-danger me-2 stock-icon"></i>
                                <span class="fw-bold text-danger">Out of Stock</span>
                            </div>
                        @endif
                    </div>
                    
                    <!-- Action Buttons -->
                    <div class="action-buttons mb-4">
                        @if($product->in_stock)
                            <div class="d-grid gap-2">
                                <button type="button" class="btn btn-theme btn-lg buy-now-btn btn-ripple hover-lift" data-product-id="{{ $product->id }}">
                                    <i class="fas fa-bolt me-2"></i>Buy Now
                                </button>
                                <button type="button" class="btn btn-outline-theme btn-lg add-to-cart-btn btn-ripple hover-lift" data-product-id="{{ $product->id }}">
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
                                <p class="mb-1 meta-item"><strong>SKU:</strong> <span class="meta-value">{{ $product->id }}</span></p>
                                <p class="mb-1 meta-item"><strong>Status:</strong> <span class="meta-value">{{ ucfirst($product->status) }}</span></p>
                            </div>
                            <div class="col-sm-6">
                                @if($product->created_at)
                                    <p class="mb-1 meta-item"><strong>Added:</strong> <span class="meta-value">{{ $product->created_at->format('M d, Y') }}</span></p>
                                @endif
                                @if($product->updated_at)
                                    <p class="mb-1 meta-item"><strong>Updated:</strong> <span class="meta-value">{{ $product->updated_at->format('M d, Y') }}</span></p>
                                @endif
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
        
        <!-- Product Description -->
        <div class="col-12 mb-4">
            <div class="card shadow-sm border-0 description-card hover-lift">
                <div class="card-body">
                    <h2 class="heading-text mb-3"><i class="fas fa-align-left me-2"></i>Product Description</h2>
                    <div class="general-text description-content">
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

<style>
    /* Product Gallery Styles */
    .product-gallery-card {
        overflow: hidden;
    }
    
    .main-image-container {
        position: relative;
        overflow: hidden;
        border-radius: 8px;
    }
    
    .main-product-image {
    }
    
    .image-zoom-overlay {
        position: absolute;
        top: 50%;
        left: 50%;
        transform: translate(-50%, -50%);
        background: rgba(0,0,0,0.5);
        color: white;
        width: 60px;
        height: 60px;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        opacity: 0;
        font-size: 1.5rem;
        cursor: pointer;
    }
    
    .main-image-container:hover .image-zoom-overlay {
        opacity: 1;
    }
    
    /* Thumbnail Styles */
    .thumbnail-item {
        cursor: pointer;
        border: 2px solid transparent;
        opacity: 1;
        border-radius: 8px;
        overflow: hidden;
    }
    
    .thumbnail-item:hover {
        border-color: var(--theme-color);
        box-shadow: 0 5px 15px rgba(0,0,0,0.15);
    }
    
    .thumbnail-item.active {
        border-color: var(--theme-color);
        box-shadow: 0 0 0 3px rgba(var(--theme-color-rgb), 0.25);
    }
    
    /* Product Title */
    .product-title {
    }
    
    /* Status Badge */
    .status-badge {
    }
    
    /* Price */
    .current-price {
        display: inline-block;
    }
    
    .discount-badge {
    }
    
    .original-price {
        position: relative;
        text-decoration: line-through;
    }
    
    /* Stock Status */
    .stock-status {
        padding: 10px 15px;
        border-radius: 8px;
    }
    
    .stock-status.in-stock {
        background: rgba(40, 167, 69, 0.1);
    }
    
    .stock-status.out-of-stock {
        background: rgba(220, 53, 69, 0.1);
    }
    
    .stock-icon {
    }
    
    .stock-quantity {
        opacity: 1;
    }
    
    /* Action Buttons */
    .action-buttons .btn {
        position: relative;
        overflow: hidden;
    }
    
    .action-buttons .btn i {
    }
    
    .buy-now-btn:hover {
    }
    
    /* Meta Information */
    .meta-item {
        padding: 8px;
        border-radius: 5px;
    }
    
    .meta-item:hover {
        background-color: rgba(var(--theme-color-rgb), 0.05);
    }
    
    .meta-value {
        color: var(--theme-color);
    }
    
    /* Description Card */
    .description-card {
        position: relative;
        overflow: hidden;
    }
    
    .description-card::before {
        content: '';
        position: absolute;
        top: 0;
        left: 0;
        width: 4px;
        height: 100%;
        background: linear-gradient(180deg, var(--theme-color), var(--link-hover-color));
    }
    
    .description-content {
    }
    
    /* Responsive */
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

<!-- JavaScript for Image Gallery -->
<script>
document.addEventListener('DOMContentLoaded', function() {
    // Thumbnail click functionality
    const thumbnailItems = document.querySelectorAll('.thumbnail-item');
    const mainImage = document.getElementById('main-image');
    
    if (thumbnailItems.length > 0 && mainImage) {
        thumbnailItems.forEach((item, index) => {
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
    
    // Image zoom on click
    const mainImageContainer = document.querySelector('.main-image-container');
    if (mainImageContainer && mainImage) {
        mainImageContainer.addEventListener('click', function() {
            // Create lightbox
            const lightbox = document.createElement('div');
            lightbox.className = 'lightbox-overlay';
            lightbox.innerHTML = `
                <div class="lightbox-content">
                    <img src="${mainImage.src}" alt="${mainImage.alt}">
                    <button class="lightbox-close">&times;</button>
                </div>
            `;
            document.body.appendChild(lightbox);
            document.body.style.overflow = 'hidden';
            
            // Animate in
            setTimeout(() => lightbox.classList.add('active'), 10);
            
            // Close on click
            lightbox.addEventListener('click', function(e) {
                if (e.target === lightbox || e.target.classList.contains('lightbox-close')) {
                    lightbox.classList.remove('active');
                    setTimeout(() => {
                        document.body.removeChild(lightbox);
                        document.body.style.overflow = '';
                    }, 300);
                }
            });
        });
    }
});
</script>

<style>
    /* Lightbox Styles */
    .lightbox-overlay {
        position: fixed;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        background: rgba(0,0,0,0.9);
        display: flex;
        align-items: center;
        justify-content: center;
        z-index: 9999;
        opacity: 0;
    }
    
    .lightbox-overlay.active {
        opacity: 1;
    }
    
    .lightbox-content {
        position: relative;
        max-width: 90%;
        max-height: 90%;
    }
    
    .lightbox-overlay.active .lightbox-content {
    }
    
    .lightbox-content img {
        max-width: 100%;
        max-height: 90vh;
        object-fit: contain;
        border-radius: 8px;
    }
    
    .lightbox-close {
        position: absolute;
        top: -40px;
        right: 0;
        background: none;
        border: none;
        color: white;
        font-size: 2rem;
        cursor: pointer;
    }
    
    .lightbox-close:hover {
    }
</style>
@endsection

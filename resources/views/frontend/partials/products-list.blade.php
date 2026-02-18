@if($products->count() > 0)
<div class="row">
    @foreach($products as $index => $product)
    <div class="col-md-6 col-lg-4 col-xl-3 mb-4">
        <div class="card h-100 shadow-sm border-0 product-card d-flex flex-column">
            <div class="position-relative product-image-container">
                @if($product->mainPhoto)
                    <img src="{{ $product->mainPhoto->url }}" class="card-img-top product-image" alt="{{ $product->name }}" loading="lazy">
                @else
                    <div class="bg-light d-flex align-items-center justify-content-center product-placeholder" style="height: 200px;">
                        <i class="fas fa-image fa-3x text-muted placeholder-icon"></i>
                    </div>
                @endif
                <div class="position-absolute top-0 end-0 m-2">
                    <span class="badge bg-success text-white status-badge">{{ ucfirst($product->status) }}</span>
                </div>
                @auth
                <button class="btn btn-sm btn-light position-absolute top-0 start-0 m-2 wishlist-btn {{ $product->isInWishlist(Auth::id()) ? 'in-wishlist' : '' }}" 
                        data-product-id="{{ $product->id }}"
                        title="{{ $product->isInWishlist(Auth::id()) ? 'Remove from wishlist' : 'Add to wishlist' }}"
                        style="border-radius: 50%; width: 36px; height: 36px; padding: 0; display: flex; align-items: center; justify-content: center; z-index: 10;">
                    <i class="fas fa-heart {{ $product->isInWishlist(Auth::id()) ? 'text-danger' : '' }}"></i>
                </button>
                @endauth
                <div class="product-overlay">
                    <a href="{{ route('frontend.product.show', $product->slug) }}" class="btn btn-light btn-sm quick-view-btn">
                        <i class="fas fa-eye me-1"></i>Quick View
                    </a>
                </div>
            </div>
            <div class="card-body d-flex flex-column p-3">
                <h5 class="card-title product-title mb-2">
                    <a href="{{ route('frontend.product.show', $product->slug) }}" class="product-link text-decoration-none">
                        {{ $product->name }}
                    </a>
                </h5>
                <p class="card-text flex-grow-1 product-description mb-3">{{ Str::limit($product->description ?? 'No description available', 100) }}</p>
                <div class="mt-auto">
                    <div class="d-flex justify-content-between align-items-center mb-2 price-container">
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
                        <p class="fw-bold text-success mb-0 fs-5 product-price">₹{{ number_format($calculatedPrice, 2) }}</p>
                        @if($hasSellingPrice && $product->mrp > $product->selling_price)
                            <small class="text-muted text-decoration-line-through original-price">₹{{ number_format($product->mrp, 2) }}</small>
                        @endif
                    </div>
                    <div class="mb-0 stock-status">
                        <small class="text-muted">
                            @php
                                // For variable products, show total stock from all variations
                                $displayStock = $product->isVariable() ? $product->total_stock : $product->stock_quantity;
                                $isInStock = $displayStock > 0;
                            @endphp
                            @if($isInStock)
                                <i class="fas fa-check-circle text-success me-1 stock-icon"></i>In Stock ({{ $displayStock }})
                            @else
                                <i class="fas fa-times-circle text-danger me-1 stock-icon"></i>Out of Stock
                            @endif
                        </small>
                    </div>
                </div>
            </div>
            <div class="card-footer bg-transparent border-0 p-3 pt-0 mt-auto">
                @if($product->isVariable())
                    {{-- Variable Product: Show only View Product button --}}
                    <a href="{{ route('frontend.product.show', $product->slug) }}" class="btn btn-theme w-100 action-btn py-2">
                        <i class="fas fa-eye me-2 btn-icon"></i>View Product
                    </a>
                @else
                    {{-- Simple Product: Show Buy Now and Add to Cart buttons stacked vertically --}}
                    <div class="d-grid gap-2">
                        <button type="button" class="btn btn-theme buy-now-btn action-btn py-2" data-product-id="{{ $product->id }}">
                            <i class="fas fa-bolt me-2 btn-icon"></i>Buy Now
                        </button>
                        <button type="button" class="btn btn-outline-theme add-to-cart-btn action-btn py-2" data-product-id="{{ $product->id }}">
                            <i class="fas fa-shopping-cart me-2 btn-icon"></i>Add to Cart
                        </button>
                    </div>
                @endif
            </div>
        </div>
    </div>
    @endforeach
</div>

<style>
    /* ==================== PRODUCT CARD STYLES ==================== */
    .product-card {
        border-radius: 12px;
        overflow: hidden;
        transition: all 0.3s ease;
        display: flex;
        flex-direction: column;
        height: 100%;
    }
    
    .product-card:hover {
        box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15) !important;
        transform: translateY(-5px);
    }
    
    /* Image container */
    .product-image-container {
        overflow: hidden;
        position: relative;
        flex-shrink: 0;
    }
    
    .product-image {
        height: 200px;
        object-fit: cover;
        width: 100%;
        transition: transform 0.3s ease;
    }
    
    .product-card:hover .product-image {
        transform: scale(1.1);
    }
    
    .product-placeholder {
        background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
    }
    
    .placeholder-icon {
        opacity: 0.3;
        transition: all 0.3s ease;
    }
    
    .product-card:hover .placeholder-icon {
        opacity: 0.5;
        transform: scale(1.1);
    }
    
    /* Overlay */
    .product-overlay {
        position: absolute;
        top: 0;
        left: 0;
        right: 0;
        bottom: 0;
        background: rgba(0, 0, 0, 0.6);
        display: flex;
        align-items: center;
        justify-content: center;
        opacity: 0;
        transition: opacity 0.3s ease;
    }
    
    .product-card:hover .product-overlay {
        opacity: 1;
    }
    
    .quick-view-btn {
        background: white !important;
        color: var(--theme-color) !important;
        border: none;
        padding: 0.5rem 1.5rem;
        font-weight: 600;
        border-radius: 50px;
        transition: all 0.3s ease;
        box-shadow: 0 4px 15px rgba(0, 0, 0, 0.2);
    }
    
    .quick-view-btn:hover {
        background: var(--theme-color) !important;
        color: white !important;
        transform: scale(1.05);
        box-shadow: 0 6px 20px rgba(0, 0, 0, 0.3);
    }
    
    /* Status badge */
    .status-badge {
        font-size: 0.75rem;
        padding: 0.35rem 0.75rem;
        border-radius: 50px;
        font-weight: 600;
        box-shadow: 0 2px 8px rgba(0, 0, 0, 0.15);
        transition: all 0.3s ease;
    }
    
    .product-card:hover .status-badge {
        transform: scale(1.05);
    }
    
    /* Card body - flexible layout */
    .card-body {
        display: flex;
        flex-direction: column;
        flex-grow: 1;
    }
    
    /* Product title */
    .product-title {
        font-size: 1rem;
        margin-bottom: 0.5rem;
        line-height: 1.4;
    }
    
    .product-link {
        color: var(--heading-text-color, #333) !important;
        font-weight: 600;
        transition: color 0.3s ease;
        display: inline-block;
    }
    
    .product-link:hover {
        color: var(--theme-color, #007bff) !important;
    }
    
    /* Description */
    .product-description {
        color: #6c757d;
        font-size: 0.875rem;
        line-height: 1.5;
        margin-bottom: 1rem;
        flex-grow: 1;
    }
    
    /* Price container */
    .price-container {
        margin-bottom: 0.5rem;
    }
    
    .product-price {
        color: var(--theme-color, #28a745) !important;
        font-size: 1.25rem !important;
        font-weight: 700 !important;
    }
    
    .original-price {
        font-size: 0.875rem;
        opacity: 0.7;
    }
    
    /* Stock status */
    .stock-status {
        font-size: 0.8125rem;
    }
    
    .stock-icon {
        font-size: 0.75rem;
    }
    
    /* Card footer - always at bottom */
    .card-footer {
        margin-top: auto;
        flex-shrink: 0;
    }
    
    /* Vertical button container */
    .d-grid {
        display: grid;
        width: 100%;
    }
    
    /* Action buttons */
    .action-btn {
        position: relative;
        overflow: hidden;
        font-weight: 600;
        border-radius: 8px;
        transition: all 0.3s ease;
        font-size: 0.875rem;
        padding: 0.625rem 1rem;
        border-width: 2px;
        width: 100%;
        display: flex;
        align-items: center;
        justify-content: center;
    }
    
    .action-btn::before {
        content: '';
        position: absolute;
        top: 50%;
        left: 50%;
        width: 0;
        height: 0;
        background: rgba(255, 255, 255, 0.3);
        border-radius: 50%;
        transform: translate(-50%, -50%);
        transition: width 0.6s, height 0.6s;
    }
    
    .action-btn:hover::before {
        width: 300px;
        height: 300px;
    }
    
    .action-btn:hover {
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
    }
    
    .action-btn:active {
        transform: translateY(0);
    }
    
    .btn-icon {
        transition: transform 0.3s ease;
    }
    
    .action-btn:hover .btn-icon {
        transform: scale(1.1);
    }
    
    .buy-now-btn {
        background: var(--theme-color, #007bff) !important;
        border-color: var(--theme-color, #007bff) !important;
        color: white !important;
    }
    
    .buy-now-btn:hover {
        background: var(--link-hover-color, #0056b3) !important;
        border-color: var(--link-hover-color, #0056b3) !important;
    }
    
    .add-to-cart-btn {
        border-color: var(--theme-color, #007bff) !important;
        color: var(--theme-color, #007bff) !important;
    }
    
    .add-to-cart-btn:hover {
        background: var(--theme-color, #007bff) !important;
        color: white !important;
    }
    
    /* Responsive */
    @media (max-width: 768px) {
        .product-image {
            height: 180px !important;
        }
        
        .product-card:hover {
            transform: none;
        }
        
        .product-overlay {
            display: none;
        }
        
        .action-btn {
            font-size: 0.8125rem;
            padding: 0.5rem 0.75rem;
        }
    }
    
    @media (max-width: 576px) {
        .product-image {
            height: 160px !important;
        }
        
        .product-title {
            font-size: 0.9375rem;
        }
        
        .product-description {
            font-size: 0.8125rem;
        }
        
        .product-price {
            font-size: 1.125rem !important;
        }
    }
</style>
@else
<div class="row">
    <div class="col-12">
        <div class="alert alert-info text-center py-5 empty-state">
            <i class="fas fa-info-circle fa-2x mb-3 empty-icon"></i>
            <h4 class="alert-heading">No Products Found</h4>
            <p class="mb-0">There are currently no products available in this category. Please check back later or explore other categories.</p>
        </div>
    </div>
</div>

<style>
    .empty-state {
        border-radius: 12px;
        background: linear-gradient(135deg, #e3f2fd 0%, #f8f9fa 100%);
        border: none;
    }
    
    .empty-icon {
        color: #17a2b8;
    }
</style>
@endif

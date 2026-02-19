@foreach($products as $index => $product)
<div class="col-sm-6 col-md-4 col-lg-3 fade-in product-item">
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

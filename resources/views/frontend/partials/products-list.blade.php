@if($products->count() > 0)
<div class="row">
    @foreach($products as $product)
    <div class="col-md-6 col-lg-4 col-xl-3 mb-4">
        <div class="card h-100 shadow-sm border-0 product-card">
            <div class="position-relative">
                @if($product->mainPhoto)
                    <img src="{{ $product->mainPhoto->url }}" class="card-img-top" alt="{{ $product->name }}" loading="lazy">
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
                <h5 class="card-title">
                    <a href="{{ route('frontend.product.show', $product->slug) }}" class="product-link text-decoration-none">
                        {{ $product->name }}
                    </a>
                </h5>
                <p class="card-text flex-grow-1">{{ Str::limit($product->description ?? 'No description available', 100) }}</p>
                <div class="mt-auto">
                    <div class="d-flex justify-content-between align-items-center mb-2">
                        @php
                            // Check if selling price is set, otherwise use MRP
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
                        <p class="fw-bold text-success mb-0 fs-5">₹{{ number_format($calculatedPrice, 2) }}</p>
                        @if($hasSellingPrice && $product->mrp > $product->selling_price)
                            <small class="text-muted text-decoration-line-through">₹{{ number_format($product->mrp, 2) }}</small>
                        @endif
                    </div>
                    <div class="mb-2">
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
            <div class="card-footer bg-transparent border-0 pt-0">
                <div class="d-grid gap-2">
                    <button type="button" class="btn btn-theme buy-now-btn" data-product-id="{{ $product->id }}">
                        <i class="fas fa-bolt me-1"></i>Buy Now
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
        <div class="alert alert-info text-center py-5">
            <i class="fas fa-info-circle fa-2x mb-3"></i>
            <h4 class="alert-heading">No Products Found</h4>
            <p class="mb-0">There are currently no products available in this category. Please check back later or explore other categories.</p>
        </div>
    </div>
</div>
@endif
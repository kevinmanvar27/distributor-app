@extends('frontend.layouts.app')

@section('title', 'My Wishlist - ' . setting('site_title', 'Frontend App'))

@section('content')
<div class="container py-5">
    <!-- Page Header -->
    <div class="row mb-4">
        <div class="col-12">
            <div class="d-flex align-items-center justify-content-between flex-wrap gap-3">
                <div>
                    <h1 class="heading-text mb-2" style="color: var(--heading-text-color);">
                        <i class="fas fa-heart me-2" style="color: var(--theme-color);"></i>My Wishlist
                    </h1>
                    <p class="text-muted mb-0">Save your favorite products for later</p>
                </div>
                @if($wishlistItems->count() > 0)
                <div>
                    <span class="badge bg-theme fs-6 px-3 py-2">
                        {{ $wishlistItems->count() }} {{ $wishlistItems->count() === 1 ? 'Item' : 'Items' }}
                    </span>
                </div>
                @endif
            </div>
        </div>
    </div>

    <!-- Alert Messages -->
    @if(session('success'))
        <div class="alert-theme alert-success alert-dismissible fade show shadow-sm" role="alert">
            <i class="fas fa-check-circle me-2"></i>{{ session('success') }}
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    @endif

    @if(session('error'))
        <div class="alert-theme alert-danger alert-dismissible fade show shadow-sm" role="alert">
            <i class="fas fa-exclamation-circle me-2"></i>{{ session('error') }}
            <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
    @endif

    @if($wishlistItems->count() > 0)
        <!-- Clear All Button -->
        <div class="row mb-3">
            <div class="col-12">
                <div class="d-flex justify-content-end">
                    <form action="{{ route('frontend.wishlist.clear') }}" method="POST" onsubmit="return confirm('Are you sure you want to clear your entire wishlist?');">
                        @csrf
                        @method('DELETE')
                        <button type="submit" class="btn btn-outline-danger btn-sm">
                            <i class="fas fa-trash-alt me-2"></i>Clear All
                        </button>
                    </form>
                </div>
            </div>
        </div>

        <!-- Wishlist Items Grid -->
        <div class="row g-4">
            @foreach($wishlistItems as $item)
                <div class="col-12" data-wishlist-item="{{ $item->product_id }}">
                    <div class="card h-100 shadow-sm border-0 hover-lift" style="transition: all 0.3s ease;">
                        <div class="card-body p-4">
                            <div class="row g-4 align-items-center">
                                <!-- Product Image -->
                                <div class="col-md-3 col-lg-2">
                                    <a href="{{ route('frontend.product.show', $item->product->slug) }}" class="d-block">
                                        @if($item->product->mainPhoto)
                                            <img src="{{ $item->product->mainPhoto->url }}" 
                                                 alt="{{ $item->product->name }}" 
                                                 class="img-fluid rounded shadow-sm"
                                                 style="width: 100%; height: 150px; object-fit: cover;">
                                        @else
                                            <div class="bg-light rounded d-flex align-items-center justify-content-center" style="width: 100%; height: 150px;">
                                                <i class="fas fa-image fa-3x text-muted"></i>
                                            </div>
                                        @endif
                                    </a>
                                </div>

                                <!-- Product Details -->
                                <div class="col-md-5 col-lg-6">
                                    <a href="{{ route('frontend.product.show', $item->product->slug) }}" 
                                       class="text-decoration-none">
                                        <h5 class="card-title mb-2 fw-bold" style="color: var(--heading-text-color);">
                                            {{ $item->product->name }}
                                        </h5>
                                    </a>
                                    
                                    @if($item->product->description)
                                        <p class="text-muted small mb-3" style="line-height: 1.6;">
                                            {{ Str::limit(strip_tags($item->product->description), 120) }}
                                        </p>
                                    @endif

                                    <!-- Price -->
                                    <div class="mb-3">
                                        @if($item->product->isVariable())
                                            @php
                                                $priceRange = $item->product->price_range;
                                            @endphp
                                            @if($priceRange['min'] == $priceRange['max'])
                                                <h4 class="mb-0 fw-bold" style="color: var(--theme-color);">
                                                    ₹{{ number_format($priceRange['min'], 2) }}
                                                </h4>
                                            @else
                                                <h4 class="mb-0 fw-bold" style="color: var(--theme-color);">
                                                    ₹{{ number_format($priceRange['min'], 2) }} - ₹{{ number_format($priceRange['max'], 2) }}
                                                </h4>
                                            @endif
                                        @else
                                            <h4 class="mb-0 fw-bold d-inline-block" style="color: var(--theme-color);">
                                                ₹{{ number_format($item->product->discounted_price, 2) }}
                                            </h4>
                                            @if($item->product->mrp > $item->product->discounted_price)
                                                <span class="text-muted text-decoration-line-through ms-2">
                                                    ₹{{ number_format($item->product->mrp, 2) }}
                                                </span>
                                                @php
                                                    $discount = round((($item->product->mrp - $item->product->discounted_price) / $item->product->mrp) * 100);
                                                @endphp
                                                <span class="badge bg-danger ms-2">{{ $discount }}% OFF</span>
                                            @endif
                                        @endif
                                    </div>

                                    <!-- Stock Status & Added Date -->
                                    <div class="d-flex align-items-center gap-3 flex-wrap">
                                        @if($item->product->is_available)
                                            <span class="badge bg-success">
                                                <i class="fas fa-check-circle me-1"></i>In Stock
                                            </span>
                                        @else
                                            <span class="badge bg-danger">
                                                <i class="fas fa-times-circle me-1"></i>Out of Stock
                                            </span>
                                        @endif
                                        <small class="text-muted">
                                            <i class="far fa-calendar-alt me-1"></i>Added {{ $item->created_at->format('M d, Y') }}
                                        </small>
                                    </div>
                                </div>

                                <!-- Actions -->
                                <div class="col-md-4 col-lg-4">
                                    <div class="d-grid gap-2">
                                        @if($item->product->is_available)
                                            @if($item->product->isVariable())
                                                <a href="{{ route('frontend.product.show', $item->product->slug) }}" 
                                                   class="btn btn-theme btn-lg">
                                                    <i class="fas fa-eye me-2"></i>View Product
                                                </a>
                                            @else
                                                <form action="{{ route('frontend.wishlist.move-to-cart', $item->id) }}" method="POST">
                                                    @csrf
                                                    <button type="submit" class="btn btn-theme btn-lg w-100">
                                                        <i class="fas fa-shopping-cart me-2"></i>Add to Cart
                                                    </button>
                                                </form>
                                            @endif
                                        @else
                                            <button class="btn btn-secondary btn-lg" disabled>
                                                <i class="fas fa-exclamation-circle me-2"></i>Out of Stock
                                            </button>
                                        @endif
                                        
                                        <button onclick="removeFromWishlist({{ $item->product_id }})" 
                                                class="btn btn-outline-danger btn-lg">
                                            <i class="fas fa-heart-broken me-2"></i>Remove
                                        </button>
                                        
                                        <a href="{{ route('frontend.product.show', $item->product->slug) }}" 
                                           class="btn btn-outline-secondary btn-lg">
                                            <i class="fas fa-info-circle me-2"></i>View Details
                                        </a>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            @endforeach
        </div>
    @else
        <!-- Empty Wishlist -->
        <div class="row">
            <div class="col-12">
                <div class="card border-0 shadow-sm text-center py-5" style="background-color: rgba(var(--theme-color-rgb, 255, 107, 0), 0.05);">
                    <div class="card-body p-5">
                        <div class="mb-4">
                            <i class="fas fa-heart-broken fa-5x" style="color: var(--theme-color); opacity: 0.3;"></i>
                        </div>
                        <h2 class="heading-text mb-3" style="color: var(--heading-text-color);">Your Wishlist is Empty</h2>
                        <p class="mb-4 fs-5" style="color: var(--general-text-color); opacity: 0.7;">Start adding products you love to your wishlist!</p>
                        <a href="{{ route('frontend.home') }}" class="btn btn-theme btn-lg px-5 py-3">
                            <i class="fas fa-shopping-bag me-2"></i>Continue Shopping
                        </a>
                    </div>
                </div>
            </div>
        </div>
    @endif
</div>

@push('styles')
<style>
    .btn-theme {
        background-color: var(--theme-color);
        border-color: var(--theme-color);
        color: white;
    }
    
    .btn-theme:hover {
        background-color: var(--link-hover-color);
        border-color: var(--link-hover-color);
        color: white;
        transform: translateY(-2px);
        box-shadow: 0 4px 12px rgba(0,0,0,0.15);
    }
    
    .bg-theme {
        background-color: var(--theme-color) !important;
    }
    
    .hover-lift {
        transition: all 0.3s ease;
    }
    
    .hover-lift:hover {
        transform: translateY(-5px);
        box-shadow: 0 8px 25px rgba(0,0,0,0.1) !important;
    }
    
    .card {
        border-radius: 12px;
        overflow: hidden;
    }
    
    .heading-text {
        font-family: var(--h1-font-family);
        font-size: var(--desktop-h1-size);
    }
    
    @media (max-width: 768px) {
        .heading-text {
            font-size: var(--tablet-h1-size);
        }
    }
    
    @media (max-width: 576px) {
        .heading-text {
            font-size: var(--mobile-h1-size);
        }
    }
</style>
@endpush

@push('scripts')
<script>
function removeFromWishlist(productId) {
    if (!confirm('Are you sure you want to remove this item from your wishlist?')) {
        return;
    }

    // Show loading state
    const itemElement = document.querySelector(`[data-wishlist-item="${productId}"]`);
    if (itemElement) {
        itemElement.style.opacity = '0.5';
        itemElement.style.pointerEvents = 'none';
    }

    fetch('{{ route('frontend.wishlist.remove') }}', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'X-CSRF-TOKEN': '{{ csrf_token() }}'
        },
        body: JSON.stringify({
            product_id: productId
        })
    })
    .then(response => response.json())
    .then(data => {
        if (data.success) {
            // Fade out and remove the item
            if (itemElement) {
                itemElement.style.transition = 'all 0.3s ease';
                itemElement.style.opacity = '0';
                itemElement.style.transform = 'scale(0.9)';
                
                setTimeout(() => {
                    itemElement.remove();
                    
                    // Check if wishlist is empty and reload
                    const remainingItems = document.querySelectorAll('[data-wishlist-item]');
                    if (remainingItems.length === 0) {
                        location.reload();
                    }
                }, 300);
            }

            // Update wishlist count in header
            const wishlistCountElements = document.querySelectorAll('.wishlist-count');
            wishlistCountElements.forEach(element => {
                element.textContent = data.wishlist_count;
                
                // Add animation to count badge
                element.style.transform = 'scale(1.3)';
                setTimeout(() => {
                    element.style.transform = 'scale(1)';
                }, 200);
            });

            // Show success message
            const alertDiv = document.createElement('div');
            alertDiv.className = 'alert alert-success alert-dismissible fade show shadow-sm';
            alertDiv.innerHTML = `
                <i class="fas fa-check-circle me-2"></i>Product removed from wishlist successfully!
                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
            `;
            document.querySelector('.container').insertBefore(alertDiv, document.querySelector('.container').firstChild);
            
            // Auto dismiss after 3 seconds
            setTimeout(() => {
                alertDiv.remove();
            }, 3000);
        } else {
            // Restore item state
            if (itemElement) {
                itemElement.style.opacity = '1';
                itemElement.style.pointerEvents = 'auto';
            }
            alert(data.message || 'Failed to remove item from wishlist');
        }
    })
    .catch(error => {
        console.error('Error:', error);
        // Restore item state
        if (itemElement) {
            itemElement.style.opacity = '1';
            itemElement.style.pointerEvents = 'auto';
        }
        alert('An error occurred. Please try again.');
    });
}
</script>
@endpush
@endsection


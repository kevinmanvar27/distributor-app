@extends('frontend.layouts.app')

@section('title', 'Shopping Cart - ' . setting('site_title', 'Frontend App'))

@section('content')
<div class="container">
    <nav aria-label="breadcrumb" class="my-4">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="{{ route('frontend.home') }}">Home</a></li>
            <li class="breadcrumb-item active" aria-current="page">Shopping Cart</li>
        </ol>
    </nav>
    
    <div class="row">
        <div class="col-12">
            <h1 class="mb-4 heading-text">
                <i class="fas fa-shopping-cart me-2"></i>Shopping Cart
            </h1>
        </div>
    </div>
    
    @if($cartItems->count() > 0)
    <div class="row">
        <div class="col-lg-8">
            
            
            <!-- Cart Items Section -->
            <div class="card shadow-sm border-0 mb-4">
                <div class="card-body">
                    <div class="table-responsive">
                        <table class="table table-borderless">
                            <thead>
                                <tr>
                                    <th>Product</th>
                                    <th>Price</th>
                                    <th>Quantity</th>
                                    <th>Total</th>
                                    <th>Actions</th>
                                </tr>
                            </thead>
                            <tbody>
                                @foreach($cartItems as $item)
                                <tr data-cart-item-id="{{ $item->id }}">
                                    <td>
                                        <div class="d-flex align-items-center">
                                            @if($item->product->mainPhoto)
                                                <img src="{{ $item->product->mainPhoto->url }}" class="img-fluid rounded me-3" alt="{{ $item->product->name }}" style="width: 80px; height: 80px; object-fit: cover;">
                                            @else
                                                <div class="bg-light d-flex align-items-center justify-content-center rounded me-3" style="width: 80px; height: 80px;">
                                                    <i class="fas fa-image text-muted"></i>
                                                </div>
                                            @endif
                                            <div>
                                                <h6 class="mb-1">{{ $item->product->name }}</h6>
                                                <small class="text-muted">{{ Str::limit($item->product->description ?? 'No description', 50) }}</small>
                                            </div>
                                        </div>
                                    </td>
                                    <td>
                                        <p class="fw-bold text-success mb-0">₹{{ number_format($item->price, 2) }}</p>
                                    </td>
                                    <td>
                                        <div class="input-group" style="width: 120px;">
                                            <button class="btn btn-outline-theme decrement-qty" type="button">-</button>
                                            <input type="number" class="form-control text-center qty-input" value="{{ $item->quantity }}" min="1" data-max="{{ $item->product->stock_quantity }}">
                                            <button class="btn btn-outline-theme increment-qty" type="button">+</button>
                                        </div>
                                        @if($item->product->stock_quantity < 10)
                                            <small class="text-warning">
                                                <i class="fas fa-exclamation-triangle me-1"></i>
                                                Only {{ $item->product->stock_quantity }} left in stock
                                            </small>
                                        @endif
                                    </td>
                                    <td>
                                        <p class="fw-bold mb-0 item-total">₹{{ number_format($item->price * $item->quantity, 2) }}</p>
                                    </td>
                                    <td>
                                        <button class="btn btn-danger remove-item" data-id="{{ $item->id }}">
                                            <i class="fas fa-trash"></i>
                                        </button>
                                    </td>
                                </tr>
                                @endforeach
                            </tbody>
                        </table>
                    </div>
                </div>
            </div>

            <!-- Personal Details and Shipping Address Section -->
            <div class="card shadow-sm border-0 mb-4">
                <div class="card-header bg-white border-0">
                    <h5 class="mb-0 fw-bold heading-text">Personal Details & Shipping Address</h5>
                </div>
                <div class="card-body">
                    <form action="{{ route('frontend.profile.update') }}" method="POST">
                        @csrf
                        @method('POST')
                        
                        <div class="row">
                            <div class="col-md-6 mb-3">
                                <label for="name" class="form-label fw-medium label-text">Full Name <span class="text-danger">*</span></label>
                                <input type="text" class="form-control" id="name" name="name" value="{{ old('name', Auth::user()->name) }}" required>
                            </div>
                            
                            <div class="col-md-6 mb-3">
                                <label for="email" class="form-label fw-medium label-text">Email Address <span class="text-danger">*</span></label>
                                <input type="email" class="form-control" id="email" name="email" value="{{ old('email', Auth::user()->email) }}" required>
                            </div>
                            
                            <div class="col-md-6 mb-3">
                                <label for="mobile_number" class="form-label fw-medium label-text">Mobile Number</label>
                                <input type="text" class="form-control" id="mobile_number" name="mobile_number" value="{{ old('mobile_number', Auth::user()->mobile_number) }}">
                            </div>
                            
                            <div class="col-md-6 mb-3">
                                <label for="date_of_birth" class="form-label fw-medium label-text">Date of Birth</label>
                                <input type="date" class="form-control" id="date_of_birth" name="date_of_birth" value="{{ old('date_of_birth', Auth::user()->date_of_birth ? Auth::user()->date_of_birth->format('Y-m-d') : '') }}">
                            </div>
                            
                            <div class="col-12 mb-3">
                                <label for="address" class="form-label fw-medium label-text">Shipping Address</label>
                                <textarea class="form-control" id="address" name="address" rows="3" placeholder="Enter your complete shipping address">{{ old('address', Auth::user()->address) }}</textarea>
                            </div>
                        </div>
                        
                        <div class="d-flex justify-content-end">
                            <button type="submit" class="btn btn-theme rounded-pill px-4">
                                <i class="fas fa-save me-2"></i>Update Details
                            </button>
                        </div>
                    </form>
                </div>
            </div>
        </div>
        
        <div class="col-lg-4">
            <!-- Order Summary Section -->
            <div class="card shadow-sm border-0 mb-4">
                <div class="card-body">
                    <h5 class="card-title mb-4">Order Summary</h5>
                    
                    <!-- Price Breakdown -->
                    <div class="mb-3">
                        <div class="d-flex justify-content-between mb-2">
                            <span>Subtotal:</span>
                            <span class="fw-bold cart-subtotal">₹{{ number_format($total, 2) }}</span>
                        </div>
                        <div class="d-flex justify-content-between mb-2">
                            <span>Shipping:</span>
                            <span class="fw-bold">Free</span>
                        </div>
                        <div class="d-flex justify-content-between mb-2">
                            <span>Tax:</span>
                            <span class="fw-bold">₹0.00</span>
                        </div>
                    </div>
                    
                    <hr>
                    
                    <!-- Total -->
                    <div class="d-flex justify-content-between mb-4">
                        <h5>Total:</h5>
                        <h5 class="fw-bold cart-total">₹{{ number_format($total, 2) }}</h5>
                    </div>
                </div>
            </div>
            
            <!-- Payment Options Section -->
            <div class="card shadow-sm border-0">
                <div class="card-body">
                    <h5 class="card-title mb-4">Payment Options</h5>
                    
                    <!-- Online Payment -->
                    <button class="btn btn-theme w-100 mb-3 d-flex align-items-center justify-content-center" id="online-payment">
                        <i class="fas fa-credit-card me-2"></i>Online Payment
                    </button>
                    
                    <!-- Cash on Delivery -->
                    <button class="btn btn-outline-theme w-100 mb-3 d-flex align-items-center justify-content-center" id="cod-payment">
                        <i class="fas fa-money-bill-wave me-2"></i>Cash on Delivery
                    </button>
                    
                    <!-- Send Proforma Invoice -->
                    <button class="btn btn-outline-secondary w-100 d-flex align-items-center justify-content-center" id="invoice-payment">
                        <i class="fas fa-file-invoice me-2"></i>Send Proforma Invoice
                    </button>
                    
                    <a href="{{ route('frontend.home') }}" class="btn btn-link w-100 mt-3">
                        <i class="fas fa-arrow-left me-2"></i>Continue Shopping
                    </a>
                </div>
            </div>
        </div>
    </div>
    @else
    <div class="row">
        <div class="col-12">
            <div class="card shadow-sm border-0">
                <div class="card-body text-center py-5">
                    <i class="fas fa-shopping-cart fa-3x text-muted mb-3"></i>
                    <h3 class="mb-3">Your cart is empty</h3>
                    <p class="mb-4">Looks like you haven't added any items to your cart yet.</p>
                    <a href="{{ route('frontend.home') }}" class="btn btn-theme">
                        <i class="fas fa-shopping-bag me-2"></i>Start Shopping
                    </a>
                </div>
            </div>
        </div>
    </div>
    @endif
</div>

<style>
    .btn-theme {
        background-color: <?php echo e(setting('theme_color', '#007bff')); ?> !important;
        border-color: <?php echo e(setting('theme_color', '#007bff')); ?> !important;
        color: white !important;
    }
    
    .btn-theme:hover {
        background-color: <?php echo e(setting('link_hover_color', '#0056b3')); ?> !important;
        border-color: <?php echo e(setting('link_hover_color', '#0056b3')); ?> !important;
    }
    
    .btn-outline-theme {
        border-color: <?php echo e(setting('theme_color', '#007bff')); ?> !important;
        color: <?php echo e(setting('theme_color', '#007bff')); ?> !important;
    }
    
    .btn-outline-theme:hover {
        background-color: <?php echo e(setting('theme_color', '#007bff')); ?> !important;
        border-color: <?php echo e(setting('theme_color', '#007bff')); ?> !important;
        color: white !important;
    }
    
    .table td, .table th {
        vertical-align: middle;
    }
</style>

<script>
document.addEventListener('DOMContentLoaded', function() {
    // Handle quantity increment
    document.querySelectorAll('.increment-qty').forEach(button => {
        button.addEventListener('click', function() {
            const input = this.parentNode.querySelector('.qty-input');
            const currentValue = parseInt(input.value);
            const maxValue = parseInt(input.dataset.max);
            
            if (currentValue < maxValue) {
                input.value = currentValue + 1;
                updateCartItem(input.closest('tr').dataset.cartItemId, input.value);
            }
        });
    });
    
    // Handle quantity decrement
    document.querySelectorAll('.decrement-qty').forEach(button => {
        button.addEventListener('click', function() {
            const input = this.parentNode.querySelector('.qty-input');
            const currentValue = parseInt(input.value);
            
            if (currentValue > 1) {
                input.value = currentValue - 1;
                updateCartItem(input.closest('tr').dataset.cartItemId, input.value);
            }
        });
    });
    
    // Handle quantity input change
    document.querySelectorAll('.qty-input').forEach(input => {
        input.addEventListener('change', function() {
            const maxValue = parseInt(this.dataset.max);
            let value = parseInt(this.value);
            
            if (isNaN(value) || value < 1) {
                value = 1;
            } else if (value > maxValue) {
                value = maxValue;
                alert(`Only ${maxValue} items available in stock.`);
            }
            
            this.value = value;
            updateCartItem(this.closest('tr').dataset.cartItemId, value);
        });
    });
    
    // Handle remove item
    document.querySelectorAll('.remove-item').forEach(button => {
        button.addEventListener('click', function() {
            const itemId = this.dataset.id;
            removeCartItem(itemId);
        });
    });
    
    // Payment option handlers
    document.getElementById('online-payment').addEventListener('click', function() {
        alert('Online payment functionality would be implemented here. Redirecting to payment gateway...');
        // In a real implementation, this would redirect to a payment gateway
    });
    
    document.getElementById('cod-payment').addEventListener('click', function() {
        alert('Cash on Delivery selected. Your order will be processed for delivery.');
        // In a real implementation, this would process the COD order
    });
    
    document.getElementById('invoice-payment').addEventListener('click', function() {
        alert('Proforma Invoice will be sent to your email address.');
        // In a real implementation, this would generate and send an invoice
    });
    
    // Function to update cart item
    function updateCartItem(itemId, quantity) {
        fetch(`/cart/update/${itemId}`, {
            method: 'PUT',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
            },
            body: JSON.stringify({
                quantity: quantity
            })
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                // Update item total
                const row = document.querySelector(`tr[data-cart-item-id="${itemId}"]`);
                row.querySelector('.item-total').textContent = '₹' + data.item_total;
                
                // Update cart totals
                document.querySelectorAll('.cart-subtotal, .cart-total').forEach(el => {
                    el.textContent = '₹' + data.cart_total;
                });
                
                // Show success message
                showToast(data.message, 'success');
            } else {
                showToast(data.message, 'error');
            }
        })
        .catch(error => {
            showToast('An error occurred while updating the cart.', 'error');
        });
    }
    
    // Function to remove cart item
    function removeCartItem(itemId) {
        if (!confirm('Are you sure you want to remove this item from your cart?')) {
            return;
        }
        
        fetch(`/cart/remove/${itemId}`, {
            method: 'DELETE',
            headers: {
                'Content-Type': 'application/json',
                'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
            }
        })
        .then(response => response.json())
        .then(data => {
            if (data.success) {
                // Remove the row from the table
                document.querySelector(`tr[data-cart-item-id="${itemId}"]`).remove();
                
                // Update cart totals
                document.querySelectorAll('.cart-subtotal, .cart-total').forEach(el => {
                    el.textContent = '₹' + data.cart_total;
                });
                
                // Update cart count in header
                updateCartCount(data.cart_count);
                
                // Show success message
                showToast(data.message, 'success');
                
                // If cart is empty, show empty message
                if (data.cart_count === 0) {
                    setTimeout(() => {
                        location.reload();
                    }, 1000);
                }
            } else {
                showToast(data.message, 'error');
            }
        })
        .catch(error => {
            showToast('An error occurred while removing the item.', 'error');
        });
    }
    
    // Function to show toast message
    function showToast(message, type) {
        // Create toast element
        const toast = document.createElement('div');
        toast.className = `toast align-items-center text-white bg-${type === 'success' ? 'success' : 'danger'} border-0 position-fixed`;
        toast.style = 'top: 20px; right: 20px; z-index: 9999;';
        toast.setAttribute('role', 'alert');
        toast.setAttribute('aria-live', 'assertive');
        toast.setAttribute('aria-atomic', 'true');
        
        toast.innerHTML = `
            <div class="d-flex">
                <div class="toast-body">
                    ${message}
                </div>
                <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
            </div>
        `;
        
        document.body.appendChild(toast);
        
        // Show toast
        const bsToast = new bootstrap.Toast(toast);
        bsToast.show();
        
        // Remove toast after it's hidden
        toast.addEventListener('hidden.bs.toast', function() {
            document.body.removeChild(toast);
        });
    }
    
    // Function to update cart count in header
    function updateCartCount(count) {
        const cartCountElement = document.querySelector('.cart-count');
        if (cartCountElement) {
            cartCountElement.textContent = count;
            if (count > 0) {
                cartCountElement.classList.remove('d-none');
            } else {
                cartCountElement.classList.add('d-none');
            }
        }
    }
});
</script>
@endsection
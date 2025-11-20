<!DOCTYPE html>
<html lang="{{ str_replace('_', '-', app()->getLocale()) }}">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <meta name="csrf-token" content="{{ csrf_token() }}">
    <!-- Site settings for JavaScript access -->
    <meta name="site-title" content="{{ setting('site_title', 'Frontend App') }}">
    <meta name="company-address" content="{{ setting('address', 'Company Address') }}">
    <meta name="company-email" content="{{ setting('company_email', 'company@example.com') }}">
    <meta name="company-phone" content="{{ setting('company_phone', '+1 (555) 123-4567') }}">
    
    <title>{{ setting('site_title', 'Frontend App') }} - {{ setting('tagline', 'Your Frontend Application') }}</title>
    
    <!-- Favicon -->
    @if(setting('favicon'))
        <link rel="icon" type="image/x-icon" href="{{ asset('storage/' . setting('favicon')) }}">
    @else
        <link rel="icon" type="image/x-icon" href="data:image/x-icon;base64,AAABAAEAEBAQAAEABAAoAQAAFgAAACgAAAAQAAAAIAAAAAEABAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAADAQAAVzABAEAjBQAaDwYAWjUGAGE6CQBrQQ0ATS8dAFAzHgBhPBMARjMcAFE0HgBmQg8ARjMeAFI1HgBhQg4AUzceAGZDDwBpRg4Aa0gOAHBKDgBzTA4Afk0OAHRNDgCETQ4A">
    @endif
    
    <!-- Bootstrap CSS CDN -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    
    <!-- Fonts -->
    <link rel="preconnect" href="https://fonts.bunny.net">
    <link href="https://fonts.bunny.net/css?family=figtree:400,500,600&display=swap" rel="stylesheet" />
    
    <!-- Font Awesome for icons -->
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.2/css/all.min.css">
    
    <!-- Custom Styles with dynamic settings -->
    <style>
        body {
            background-color: #f8f9fa !important;
            color: #333333 !important;
            font-family: Arial, sans-serif !important;
            font-size: 16px !important;
        }
        
        /* Text color styles */
        .navbar-brand, .navbar-nav .nav-link {
            color: #333333 !important;
        }
        
        .sidebar-text {
            color: #333333 !important;
        }
        
        .heading-text {
            color: #333333 !important;
        }
        
        .label-text {
            color: #333333 !important;
        }
        
        .general-text {
            color: #333333 !important;
        }
        
        /* Button styles */
        .btn-theme {
            background-color: {{ setting('theme_color', '#007bff') }} !important;
            border-color: {{ setting('theme_color', '#007bff') }} !important;
            color: white !important;
        }
        
        .btn-theme:hover {
            background-color: {{ setting('link_hover_color', '#0056b3') }} !important;
            border-color: {{ setting('link_hover_color', '#0056b3') }} !important;
        }
        
        /* Link styles */
        a {
            color: {{ setting('link_color', '#007bff') }} !important;
        }
        
        a:hover {
            color: {{ setting('link_hover_color', '#0056b3') }} !important;
        }
        
        /* Font size styles for headings with higher specificity */
        h1, .h1 {
            font-size: 36px !important;
        }
        
        h2, .h2 {
            font-size: 30px !important;
        }
        
        h3, .h3 {
            font-size: 24px !important;
        }
        
        h4, .h4 {
            font-size: 20px !important;
        }
        
        h5, .h5 {
            font-size: 18px !important;
        }
        
        h6, .h6 {
            font-size: 16px !important;
        }
        
        p, .lead {
            font-size: 16px !important;
        }
        
        /* Responsive font sizes with higher specificity */
        @media (max-width: 992px) {
            h1, .h1 {
                font-size: 32px !important;
            }
            
            h2, .h2 {
                font-size: 28px !important;
            }
            
            h3, .h3 {
                font-size: 22px !important;
            }
            
            h4, .h4 {
                font-size: 18px !important;
            }
            
            h5, .h5 {
                font-size: 16px !important;
            }
            
            h6, .h6 {
                font-size: 14px !important;
            }
            
            body, p, .lead {
                font-size: 14px !important;
            }
        }
        
        @media (max-width: 768px) {
            h1, .h1 {
                font-size: 28px !important;
            }
            
            h2, .h2 {
                font-size: 24px !important;
            }
            
            h3, .h3 {
                font-size: 20px !important;
            }
            
            h4, .h4 {
                font-size: 16px !important;
            }
            
            h5, .h5 {
                font-size: 14px !important;
            }
            
            h6, .h6 {
                font-size: 12px !important;
            }
            
            body, p, .lead {
                font-size: 12px !important;
            }
        }
        
        /* Header and Footer Styles */
        .site-header {
            background-color: #ffffff;
            box-shadow: 0 2px 4px rgba(0,0,0,.05);
        }
        
        .site-footer {
            background-color: #f8f9fa;
            border-top: 1px solid #dee2e6;
            padding: 2rem 0;
            margin-top: auto;
        }
        
        .footer-logo {
            max-height: 40px;
        }
    </style>
    
    @yield('styles')
</head>
<body class="d-flex flex-column min-vh-100">
    <!-- Header -->
    <header class="site-header py-3">
        <div class="container">
            <div class="d-flex justify-content-between align-items-center">
                <div class="d-flex align-items-center">
                    @if(setting('header_logo'))
                        <img src="{{ asset('storage/' . setting('header_logo')) }}" alt="{{ setting('site_title', 'Frontend App') }}" class="rounded" height="50">
                    @else
                        <h1 class="h4 mb-0 fw-bold heading-text">{{ setting('site_title', 'Frontend App') }}</h1>
                    @endif
                </div>
                
                <nav class="d-none d-md-block">
                    <ul class="navbar-nav flex-row">
                        <li class="nav-item me-3">
                            <a class="nav-link" href="/">Home</a>
                        </li>
                        <!-- Add more navigation items as needed -->
                    </ul>
                </nav>
                
                <div class="d-flex align-items-center">
                    @auth
                        <a href="{{ route('frontend.cart.index') }}" class="btn btn-sm btn-outline-theme position-relative me-3">
                            <i class="fas fa-shopping-cart"></i>
                            <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger cart-count">
                                {{ Auth::user()->cartItems()->count() }}
                            </span>
                        </a>
                        <div class="dropdown">
                            <button class="btn btn-sm btn-theme dropdown-toggle" type="button" id="userDropdown" data-bs-toggle="dropdown" aria-expanded="false">
                                {{ Auth::user()->name }}
                            </button>
                            <ul class="dropdown-menu dropdown-menu-end">
                                <li><a class="dropdown-item" href="{{ route('frontend.profile') }}">Profile</a></li>
                                <li><a class="dropdown-item" href="{{ route('frontend.profile') }}#change-password">Change Password</a></li>
                                <li><a class="dropdown-item" href="{{ route('frontend.cart.proforma.invoices') }}">Proforma Invoice</a></li>
                                <li>
                                    <form method="POST" action="{{ route('frontend.logout') }}">
                                        @csrf
                                        <button type="submit" class="dropdown-item">Logout</button>
                                    </form>
                                </li>
                            </ul>
                        </div>
                    @else
                        <a href="{{ route('frontend.cart.index') }}" class="btn btn-sm btn-outline-theme position-relative me-3">
                            <i class="fas fa-shopping-cart"></i>
                            <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger cart-count">
                                0
                            </span>
                        </a>
                        <a href="{{ route('frontend.login') }}" class="btn btn-sm btn-theme">Login</a>
                    @endauth
                </div>
            </div>
        </div>
    </header>
    
    <div id="app" class="flex-grow-1">
        @yield('content')
    </div>
    
    <!-- Footer -->
    <footer class="site-footer">
        <div class="container">
            <div class="row align-items-center">
                <div class="col-md-6 mb-3 mb-md-0">
                    <div class="d-flex align-items-center">
                        @if(setting('footer_logo'))
                            <img src="{{ asset('storage/' . setting('footer_logo')) }}" alt="{{ setting('site_title', 'Frontend App') }}" class="rounded footer-logo">
                        @else
                            <span class="general-text">
                                {{ setting('footer_text', '© ' . date('Y') . ' ' . config('app.name', 'Laravel') . '. All rights reserved.') }}
                            </span>
                        @endif
                    </div>
                </div>
                <div class="col-md-6">
                    <ul class="nav justify-content-md-end">
                        @if(setting('facebook_url'))
                        <li class="nav-item">
                            <a class="nav-link text-secondary px-2 py-0" href="{{ setting('facebook_url') }}" target="_blank" data-bs-toggle="tooltip" title="Facebook">
                                <i class="fab fa-facebook-f"></i>
                            </a>
                        </li>
                        @endif
                        @if(setting('twitter_url'))
                        <li class="nav-item">
                            <a class="nav-link text-secondary px-2 py-0" href="{{ setting('twitter_url') }}" target="_blank" data-bs-toggle="tooltip" title="Twitter">
                                <i class="fab fa-twitter"></i>
                            </a>
                        </li>
                        @endif
                        @if(setting('instagram_url'))
                        <li class="nav-item">
                            <a class="nav-link text-secondary px-2 py-0" href="{{ setting('instagram_url') }}" target="_blank" data-bs-toggle="tooltip" title="Instagram">
                                <i class="fab fa-instagram"></i>
                            </a>
                        </li>
                        @endif
                        @if(setting('linkedin_url'))
                        <li class="nav-item">
                            <a class="nav-link text-secondary px-2 py-0" href="{{ setting('linkedin_url') }}" target="_blank" data-bs-toggle="tooltip" title="LinkedIn">
                                <i class="fab fa-linkedin-in"></i>
                            </a>
                        </li>
                        @endif
                        @if(setting('youtube_url'))
                        <li class="nav-item">
                            <a class="nav-link text-secondary px-2 py-0" href="{{ setting('youtube_url') }}" target="_blank" data-bs-toggle="tooltip" title="YouTube">
                                <i class="fab fa-youtube"></i>
                            </a>
                        </li>
                        @endif
                        @if(setting('whatsapp_url'))
                        <li class="nav-item">
                            <a class="nav-link text-secondary px-2 py-0" href="{{ setting('whatsapp_url') }}" target="_blank" data-bs-toggle="tooltip" title="WhatsApp">
                                <i class="fab fa-whatsapp"></i>
                            </a>
                        </li>
                        @endif
                    </ul>
                </div>
            </div>
        </div>
    </footer>
    
    <!-- Bootstrap Bundle with Popper -->
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    
    <!-- jQuery -->
    <script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
    
    <script>
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
        
        // Function to get guest cart from localStorage
        function getGuestCart() {
            const cart = localStorage.getItem('guest_cart');
            return cart ? JSON.parse(cart) : [];
        }
        
        // Function to save guest cart to localStorage
        function saveGuestCart(cart) {
            localStorage.setItem('guest_cart', JSON.stringify(cart));
        }
        
        // Function to add item to guest cart
        function addToGuestCart(productId, quantity = 1) {
            let cart = getGuestCart();
            
            // Check if product already exists in cart
            const existingItemIndex = cart.findIndex(item => item.product_id == productId);
            
            if (existingItemIndex !== -1) {
                // Update quantity if product already exists
                cart[existingItemIndex].quantity += quantity;
            } else {
                // Add new item to cart
                cart.push({
                    product_id: productId,
                    quantity: quantity,
                    added_at: new Date().toISOString()
                });
            }
            
            saveGuestCart(cart);
            return cart;
        }
        
        // Function to get guest cart count
        function getGuestCartCount() {
            const cart = getGuestCart();
            return cart.reduce((total, item) => total + item.quantity, 0);
        }
        
        // Function to update guest cart count display
        function updateGuestCartCount() {
            const count = getGuestCartCount();
            updateCartCount(count);
        }
        
        // Function to clear guest cart from localStorage
        function clearGuestCart() {
            localStorage.removeItem('guest_cart');
        }
        
        // Initialize cart count on page load for guests
        document.addEventListener('DOMContentLoaded', function() {
            @guest
                updateGuestCartCount();
            @endguest
            
            // Check if we just logged in successfully and clear localStorage cart
            @if(session('login_success'))
                clearGuestCart();
            @endif
        });
        
        // Handle Add to Cart buttons
        document.addEventListener('click', function(e) {
            if (e.target.classList.contains('add-to-cart-btn') || e.target.closest('.add-to-cart-btn')) {
                const button = e.target.classList.contains('add-to-cart-btn') ? e.target : e.target.closest('.add-to-cart-btn');
                const productId = button.dataset.productId;
                
                // Disable button and show loading state
                button.disabled = true;
                const originalText = button.innerHTML;
                button.innerHTML = '<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Adding...';
                
                @auth
                    // For authenticated users, use AJAX request
                    fetch('/cart/add', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json',
                            'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
                        },
                        body: JSON.stringify({
                            product_id: productId
                        })
                    })
                    .then(response => response.json())
                    .then(data => {
                        if (data.success) {
                            // Update cart count
                            updateCartCount(data.cart_count);
                            
                            // Show success message
                            showToast(data.message, 'success');
                        } else {
                            showToast(data.message, 'error');
                        }
                    })
                    .catch(error => {
                        showToast('An error occurred while adding the product to cart.', 'error');
                    })
                    .finally(() => {
                        // Re-enable button
                        button.disabled = false;
                        button.innerHTML = originalText;
                    });
                @else
                    // For guests, use localStorage
                    try {
                        addToGuestCart(productId);
                        updateGuestCartCount();
                        showToast('Product added to cart successfully!', 'success');
                    } catch (error) {
                        showToast('An error occurred while adding the product to cart.', 'error');
                    } finally {
                        // Re-enable button
                        button.disabled = false;
                        button.innerHTML = originalText;
                    }
                @endauth
            }
            
            // Handle Buy Now buttons
            if (e.target.classList.contains('buy-now-btn') || e.target.closest('.buy-now-btn')) {
                const button = e.target.classList.contains('buy-now-btn') ? e.target : e.target.closest('.buy-now-btn');
                const productId = button.dataset.productId;
                
                // Disable button and show loading state
                button.disabled = true;
                const originalText = button.innerHTML;
                button.innerHTML = '<span class="spinner-border spinner-border-sm" role="status" aria-hidden="true"></span> Adding...';
                
                @auth
                    // For authenticated users, use AJAX request
                    fetch('/cart/add', {
                        method: 'POST',
                        headers: {
                            'Content-Type': 'application/json',
                            'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
                        },
                        body: JSON.stringify({
                            product_id: productId
                        })
                    })
                    .then(response => response.json())
                    .then(data => {
                        if (data.success) {
                            // Update cart count
                            updateCartCount(data.cart_count);
                            
                            // Redirect to cart page
                            window.location.href = '/cart';
                        } else {
                            showToast(data.message, 'error');
                            button.disabled = false;
                            button.innerHTML = originalText;
                        }
                    })
                    .catch(error => {
                        showToast('An error occurred while adding the product to cart.', 'error');
                        button.disabled = false;
                        button.innerHTML = originalText;
                    });
                @else
                    // For guests, use localStorage and redirect to login
                    try {
                        addToGuestCart(productId);
                        updateGuestCartCount();
                        // Redirect to login page
                        window.location.href = '/login';
                    } catch (error) {
                        showToast('An error occurred while adding the product to cart.', 'error');
                        button.disabled = false;
                        button.innerHTML = originalText;
                    }
                @endauth
            }
        });
    </script>
    
    @yield('scripts')
</body>
</html>
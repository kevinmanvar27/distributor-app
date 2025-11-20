@extends('frontend.layouts.app')

@section('title', $metaTitle ?? 'Category - ' . setting('site_title', 'Frontend App'))
@section('meta_description', $metaDescription ?? setting('tagline', 'Your Frontend Application'))

@section('content')
<div class="container mt-4">
    <div class="row">          
        <!-- Category Header -->
        <div class="row mb-4">
            <div class="col-12">
                <nav aria-label="breadcrumb" class="mb-3">
                    <ol class="breadcrumb">
                        <li class="breadcrumb-item"><a href="{{ route('frontend.home') }}">Home</a></li>
                        <li class="breadcrumb-item active" aria-current="page">{{ $category->name }}</li>
                    </ol>
                </nav>
                <div class="d-flex justify-content-between align-items-center">
                    <h1 class="display-5 fw-bold mb-0">{{ $category->name }}</h1>
                </div>
                @if($category->description)
                    <p class="lead">{{ $category->description }}</p>
                @endif
            </div>
        </div>
        <!-- Sidebar for Subcategories -->
        <div class="col-lg-3 col-md-4 mb-4">
            <div class="card shadow-sm border-0 h-100 sticky-top">
                <div class="card-header bg-theme text-white py-3">
                    <h5 class="mb-0 d-flex align-items-center">
                        <i class="fas fa-tags me-2"></i>
                        <span>{{ $category->name }}</span>
                    </h5>
                </div>
                <div class="card-body p-0">
                    @if($subCategories->count() > 0)
                        <div class="list-group list-group-flush">
                            <!-- All Products Option -->
                            <button type="button" class="list-group-item list-group-item-action active subcategory-filter d-flex justify-content-between align-items-center" data-subcategory-id="">
                                <span>All Products</span>
                                <span class="badge bg-primary rounded-pill">{{ $products->count() }}</span>
                            </button>
                            
                            <!-- Subcategory Items -->
                            @foreach($subCategories as $subCategory)
                                <button type="button" class="list-group-item list-group-item-action subcategory-filter d-flex justify-content-between align-items-center" data-subcategory-id="{{ $subCategory->id }}">
                                    <span>{{ $subCategory->name }}</span>
                                    <!-- Count of products in this subcategory -->
                                    @php
                                        $subCategoryProductCount = $products->filter(function ($product) use ($subCategory) {
                                            if (!$product->product_categories) return false;
                                            foreach ($product->product_categories as $catData) {
                                                if (isset($catData['subcategory_ids']) && in_array($subCategory->id, $catData['subcategory_ids'])) {
                                                    return true;
                                                }
                                            }
                                            return false;
                                        })->count();
                                    @endphp
                                    @if($subCategoryProductCount > 0)
                                        <span class="badge bg-secondary rounded-pill">{{ $subCategoryProductCount }}</span>
                                    @endif
                                </button>
                            @endforeach
                        </div>
                    @else
                        <div class="p-3">
                            <p class="text-muted text-center mb-0">
                                <i class="fas fa-info-circle me-2"></i>No subcategories available.
                            </p>
                        </div>
                    @endif
                </div>
            </div>
        </div>
        
        <!-- Main Content Area for Products -->
        <div class="col-lg-9 col-md-8">
            <!-- Products Section -->
            <div class="section">
                <div class="row mb-3 align-items-center">
                    <div class="col-md-6">
                        <h2 class="mb-0 heading-text" style="color: <?php echo e(setting('theme_color', '#007bff')); ?>;">
                            <i class="fas fa-box-open me-2"></i>Products
                        </h2>
                    </div>
                    <div class="col-md-6 text-md-end">
                        <!-- Sorting options can be added here -->
                        <div class="d-flex justify-content-md-end align-items-center">
                            <span class="me-2 text-muted">Sort by:</span>
                            <select class="form-select form-select-sm w-auto" id="sort-products">
                                <option value="default" {{ (isset($sort) && $sort == 'default') ? 'selected' : '' }}>Default</option>
                                <option value="name" {{ (isset($sort) && $sort == 'name') ? 'selected' : '' }}>Name</option>
                                <option value="price-low" {{ (isset($sort) && $sort == 'price-low') ? 'selected' : '' }}>Price: Low to High</option>
                                <option value="price-high" {{ (isset($sort) && $sort == 'price-high') ? 'selected' : '' }}>Price: High to Low</option>
                            </select>
                        </div>
                    </div>
                </div>
                <hr class="my-3">
                
                <!-- Loading Spinner -->
                <div id="loading-spinner" class="text-center d-none my-5">
                    <div class="spinner-border text-primary" role="status">
                        <span class="visually-hidden">Loading...</span>
                    </div>
                    <p class="mt-2 text-muted">Loading products...</p>
                </div>
                
                <!-- Products Container -->
                <div id="products-container">
                    @include('frontend.partials.products-list', ['products' => $products])
                </div>
                
                <!-- Pagination or Load More Button -->
                @if($products->count() > 12)
                    <div class="text-center mt-4">
                        <button class="btn btn-theme" id="load-more-products">
                            <i class="fas fa-sync-alt me-2"></i>Load More Products
                        </button>
                    </div>
                @endif
            </div>
        </div>
    </div>
</div>

<style>
    :root {
        --theme-color: <?php echo e(setting('theme_color', '#007bff')); ?>;
        --hover-color: <?php echo e(setting('link_hover_color', '#0056b3')); ?>;
        --sidebar-active: var(--theme-color); /* Using theme primary color for active state */
    }
    
    .bg-theme {
        background-color: var(--theme-color) !important;
    }
    
    .subcategory-card:hover, .product-card:hover {
        transform: translateY(-5px);
        transition: transform 0.3s ease;
        box-shadow: 0 10px 20px rgba(0,0,0,0.1);
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
    
    .badge.bg-theme {
        background-color: var(--theme-color) !important;
    }
    
    .section {
        animation: fadeIn 0.5s ease-in;
    }
    
    /* Sidebar enhancements */
    .card.h-100 {
        min-height: 300px;
    }
    
    .sticky-top {
        top: 20px;
    }
    
    .list-group-item {
        border: none;
        border-radius: 0 !important;
        padding: 12px 15px;
        transition: all 0.2s ease;
    }
    
    .list-group-item:first-child {
        border-top-left-radius: calc(0.375rem - 1px) !important;
        border-top-right-radius: calc(0.375rem - 1px) !important;
    }
    
    .list-group-item:last-child {
        border-bottom-left-radius: calc(0.375rem - 1px) !important;
        border-bottom-right-radius: calc(0.375rem - 1px) !important;
    }
    
    .list-group-item:hover {
        background-color: rgba(0, 123, 255, 0.1);
    }
    
    .list-group-item.active {
        background-color: white !important; /* Using theme primary color for active state */
        border-color: var(--sidebar-active) !important; /* Using theme primary color for active state */
        color:  var(--sidebar-active) !important;
    }
    
    .list-group-item.active:hover {
        background-color: var(--hover-color); /* Using hover color on active hover */
        border-color: var(--hover-color); /* Using hover color on active hover */
    }
    
    /* Product card enhancements */
    .product-card {
        transition: all 0.3s ease;
        border-radius: 8px;
        overflow: hidden;
    }
    
    .product-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 10px 20px rgba(0,0,0,0.15);
    }
    
    .card-img-top {
        height: 200px;
        object-fit: cover;
    }
    
    /* Breadcrumb styling */
    .breadcrumb {
        background-color: #f8f9fa;
        padding: 0.75rem 1rem;
        border-radius: 0.375rem;
    }
    
    /* Sorting dropdown */
    #sort-products {
        border-color: #dee2e6;
        border-radius: 0.375rem;
    }
    
    /* Loading spinner */
    #loading-spinner {
        padding: 2rem;
    }
    
    @keyframes fadeIn {
        from { opacity: 0; }
        to { opacity: 1; }
    }
    
    /* Responsive adjustments */
    @media (max-width: 768px) {
        .card-img-top {
            height: 150px !important;
        }
        
        .card.h-100 {
            min-height: auto;
        }
        
        .sticky-top {
            position: static;
        }
        
        .text-md-end {
            text-align: left !important;
        }
        
        .justify-content-md-end {
            justify-content: flex-start !important;
        }
    }
</style>

<!-- AJAX Script for Filtering -->
<script>
document.addEventListener('DOMContentLoaded', function() {
    // Get the base URL for filtering
    const baseUrl = "{{ route('frontend.category.show', $category->slug) }}";
    
    // Add click event to all subcategory filter buttons
    const subcategoryFilterButtons = document.querySelectorAll('.subcategory-filter');
    subcategoryFilterButtons.forEach(button => {
        button.addEventListener('click', function() {
            const subcategoryId = this.getAttribute('data-subcategory-id');
            
            // Update active state
            subcategoryFilterButtons.forEach(btn => btn.classList.remove('active'));
            this.classList.add('active');
            
            // Show loading spinner
            document.getElementById('loading-spinner').classList.remove('d-none');
            document.getElementById('products-container').classList.add('d-none');
            
            // Get current sort value
            const currentSort = document.getElementById('sort-products').value;
            
            // Make AJAX request with both subcategory and sort parameters
            let url = `${baseUrl}?subcategory=${subcategoryId}`;
            if (currentSort && currentSort !== 'default') {
                url += `&sort=${currentSort}`;
            }
            
            fetch(url, {
                method: 'GET',
                headers: {
                    'X-Requested-With': 'XMLHttpRequest',
                    'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
                }
            })
            .then(response => response.text())
            .then(html => {
                // Update products container
                document.getElementById('products-container').innerHTML = html;
                
                // Hide loading spinner and show products
                document.getElementById('loading-spinner').classList.add('d-none');
                document.getElementById('products-container').classList.remove('d-none');
                
                // Update product count in header
                const productCount = document.querySelectorAll('#products-container .col-md-6').length;
                document.querySelector('.badge.bg-primary').textContent = `${productCount} Products`;
            })
            .catch(error => {
                console.error('Error:', error);
                // Hide loading spinner and show products
                document.getElementById('loading-spinner').classList.add('d-none');
                document.getElementById('products-container').classList.remove('d-none');
                
                // Show error message
                showToast('Failed to load products. Please try again.', 'error');
            });
        });
    });
    
    // Handle sorting
    const sortSelect = document.getElementById('sort-products');
    if (sortSelect) {
        sortSelect.addEventListener('change', function() {
            const sortBy = this.value;
            const subcategoryId = document.querySelector('.subcategory-filter.active')?.getAttribute('data-subcategory-id') || '';
            
            // Show loading spinner
            document.getElementById('loading-spinner').classList.remove('d-none');
            document.getElementById('products-container').classList.add('d-none');
            
            // Make AJAX request with both subcategory and sort parameters
            let url = `${baseUrl}?sort=${sortBy}`;
            if (subcategoryId) {
                url += `&subcategory=${subcategoryId}`;
            }
            
            fetch(url, {
                method: 'GET',
                headers: {
                    'X-Requested-With': 'XMLHttpRequest',
                    'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
                }
            })
            .then(response => response.text())
            .then(html => {
                // Update products container
                document.getElementById('products-container').innerHTML = html;
                
                // Hide loading spinner and show products
                document.getElementById('loading-spinner').classList.add('d-none');
                document.getElementById('products-container').classList.remove('d-none');
                
                // Update product count in header
                const productCount = document.querySelectorAll('#products-container .col-md-6').length;
                document.querySelector('.badge.bg-primary').textContent = `${productCount} Products`;
            })
            .catch(error => {
                console.error('Error:', error);
                // Hide loading spinner and show products
                document.getElementById('loading-spinner').classList.add('d-none');
                document.getElementById('products-container').classList.remove('d-none');
                
                // Show error message
                showToast('Failed to sort products. Please try again.', 'error');
            });
        });
    }
    
    // Handle load more button
    const loadMoreButton = document.getElementById('load-more-products');
    if (loadMoreButton) {
        loadMoreButton.addEventListener('click', function() {
            // In a real implementation, this would load more products
            // For now, we'll just show a message
            showToast('Load more functionality would be implemented here', 'info');
        });
    }
    
    // Toast function for user feedback
    function showToast(message, type) {
        // Create toast element
        const toast = document.createElement('div');
        toast.className = `toast align-items-center text-white bg-${type === 'success' ? 'success' : type === 'error' ? 'danger' : 'info'} border-0 position-fixed`;
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
});
</script>
@endsection
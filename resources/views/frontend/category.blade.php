@extends('frontend.layouts.app')

@section('title', $metaTitle ?? 'Category - ' . setting('site_title', 'Frontend App'))
@section('meta_description', $metaDescription ?? setting('tagline', 'Your Frontend Application'))

@section('content')
<div class="container mt-4 mb-5">
    <!-- Breadcrumb -->
    <nav aria-label="breadcrumb" class="mb-4">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="{{ route('frontend.home') }}"><i class="fas fa-home me-1"></i>Home</a></li>
            <li class="breadcrumb-item active" aria-current="page">{{ $category->name }}</li>
        </ol>
    </nav>
    
    <!-- Category Header -->
    <div class="row mb-5">
        <div class="col-12">
            <div class="card border-0 shadow-sm" style="background: linear-gradient(135deg, var(--theme-color) 0%, var(--link-hover-color) 100%);">
                <div class="card-body p-4 p-md-5 text-white">
                    <h1 class="display-5 fw-bold mb-3" style="color: white !important;">
                        <i class="fas fa-folder-open me-3"></i>{{ $category->name }}
                    </h1>
                    @if($category->description)
                        <p class="lead mb-0" style="color: rgba(255,255,255,0.95) !important; font-size: 1.125rem;">
                            {{ $category->description }}
                        </p>
                    @endif
                </div>
            </div>
        </div>
    </div>
    
    <div class="row g-4">
        <!-- Sidebar for Subcategories -->
        <div class="col-lg-3 col-md-4">
            <div class="card border-0 shadow-sm sticky-sidebar">
                <div class="card-header bg-gradient-theme text-white py-3">
                    <h5 class="mb-0 fw-bold d-flex align-items-center">
                        <i class="fas fa-filter me-2"></i>
                        <span>Filter by Category</span>
                    </h5>
                </div>
                <div class="card-body p-0">
                    @if($subCategories->count() > 0)
                        <div class="list-group list-group-flush">
                            <!-- All Products Option -->
                            <button type="button" class="list-group-item list-group-item-action active subcategory-filter d-flex justify-content-between align-items-center" data-subcategory-id="">
                                <span class="fw-medium">All Products</span>
                                <span class="badge bg-theme rounded-pill">{{ $products->count() }}</span>
                            </button>
                            
                            <!-- Subcategory Items -->
                            @foreach($subCategories as $subCategory)
                                <button type="button" class="list-group-item list-group-item-action subcategory-filter d-flex justify-content-between align-items-center" data-subcategory-id="{{ $subCategory->id }}">
                                    <span>{{ $subCategory->name }}</span>
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
                        <div class="p-4 text-center">
                            <i class="fas fa-info-circle text-muted mb-2" style="font-size: 2rem;"></i>
                            <p class="text-muted mb-0">No subcategories available</p>
                        </div>
                    @endif
                </div>
            </div>
        </div>
        
        <!-- Main Content Area for Products -->
        <div class="col-lg-9 col-md-8">
            <!-- Products Header -->
            <div class="d-flex justify-content-between align-items-center mb-4 flex-wrap gap-3">
                <div>
                    <h2 class="mb-1 fw-bold" style="color: var(--heading-text-color);">
                        <i class="fas fa-box-open me-2 text-theme"></i>Products
                    </h2>
                    <p class="text-muted mb-0">Showing {{ $products->count() }} products</p>
                </div>
                <div class="d-flex align-items-center gap-2">
                    <label for="sort-products" class="mb-0 text-muted fw-medium">Sort by:</label>
                    <select class="form-select form-select-sm" id="sort-products" style="width: auto; min-width: 180px;">
                        <option value="default" {{ (isset($sort) && $sort == 'default') ? 'selected' : '' }}>Default</option>
                        <option value="name" {{ (isset($sort) && $sort == 'name') ? 'selected' : '' }}>Name (A-Z)</option>
                        <option value="price-low" {{ (isset($sort) && $sort == 'price-low') ? 'selected' : '' }}>Price: Low to High</option>
                        <option value="price-high" {{ (isset($sort) && $sort == 'price-high') ? 'selected' : '' }}>Price: High to Low</option>
                    </select>
                </div>
            </div>
            
            <!-- Loading Spinner -->
            <div id="loading-spinner" class="text-center d-none my-5">
                <div class="spinner-border text-theme" role="status" style="width: 3rem; height: 3rem;">
                    <span class="visually-hidden">Loading...</span>
                </div>
                <p class="mt-3 text-muted">Loading products...</p>
            </div>
            
            <!-- Products Container -->
            <div id="products-container">
                @include('frontend.partials.products-list', ['products' => $products])
            </div>
        </div>
    </div>
</div>

<style>
    .sticky-sidebar {
        position: sticky;
        top: 100px;
        max-height: calc(100vh - 120px);
        overflow-y: auto;
    }
    
    .list-group-item {
        border: none;
        padding: 1rem 1.25rem;
        transition: all 0.2s ease;
        cursor: pointer;
        border-left: 3px solid transparent;
    }
    
    .list-group-item:hover {
        background-color: rgba(255, 107, 0, 0.05);
        border-left-color: var(--theme-color);
        padding-left: 1.5rem;
    }
    
    .list-group-item.active {
        background: linear-gradient(90deg, rgba(255, 107, 0, 0.1) 0%, rgba(255, 107, 0, 0.05) 100%);
        border-left-color: var(--theme-color);
        color: var(--theme-color) !important;
        font-weight: 600;
    }
    
    .list-group-item.active .badge {
        background-color: var(--theme-color) !important;
    }
    
    .text-theme {
        color: var(--theme-color) !important;
    }
    
    .bg-gradient-theme {
        background: linear-gradient(135deg, var(--theme-color) 0%, var(--link-hover-color) 100%);
    }
    
    @media (max-width: 992px) {
        .sticky-sidebar {
            position: static;
            max-height: none;
            margin-bottom: 2rem;
        }
    }
</style>

<script>
document.addEventListener('DOMContentLoaded', function() {
    const baseUrl = "{{ route('frontend.category.show', $category->slug) }}";
    

    
    const subcategoryFilterButtons = document.querySelectorAll('.subcategory-filter');
    subcategoryFilterButtons.forEach(button => {
        button.addEventListener('click', function() {
            const subcategoryId = this.getAttribute('data-subcategory-id');
            
            subcategoryFilterButtons.forEach(btn => {
                btn.classList.remove('active');
            });
            this.classList.add('active');
            
            const productsContainer = document.getElementById('products-container');
            document.getElementById('loading-spinner').classList.remove('d-none');
            productsContainer.classList.add('d-none');
            
            const currentSort = document.getElementById('sort-products').value;
            let url = `${baseUrl}?subcategory=${subcategoryId}`;
            if (currentSort && currentSort !== 'default') { url += `&sort=${currentSort}`; }
            
            fetch(url, {
                method: 'GET',
                headers: {
                    'X-Requested-With': 'XMLHttpRequest',
                    'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
                }
            })
            .then(response => response.text())
            .then(html => {
                productsContainer.innerHTML = html;
                document.getElementById('loading-spinner').classList.add('d-none');
                productsContainer.classList.remove('d-none');
                
                const productCount = document.querySelectorAll('#products-container .col-md-6').length;
                const badge = document.querySelector('.badge.bg-primary');
                if (badge) { badge.textContent = `${productCount} Products`; }
            })
            .catch(error => {
                console.error('Error:', error);
                document.getElementById('loading-spinner').classList.add('d-none');
                productsContainer.classList.remove('d-none');
                showToast('Failed to load products. Please try again.', 'error');
            });
        });
    });
    
    const sortSelect = document.getElementById('sort-products');
    if (sortSelect) {
        sortSelect.addEventListener('change', function() {
            const sortBy = this.value;
            const subcategoryId = document.querySelector('.subcategory-filter.active')?.getAttribute('data-subcategory-id') || '';
            
            const productsContainer = document.getElementById('products-container');
            document.getElementById('loading-spinner').classList.remove('d-none');
            productsContainer.classList.add('d-none');
            
            let url = `${baseUrl}?sort=${sortBy}`;
            if (subcategoryId) { url += `&subcategory=${subcategoryId}`; }
            
            fetch(url, {
                method: 'GET',
                headers: {
                    'X-Requested-With': 'XMLHttpRequest',
                    'X-CSRF-TOKEN': document.querySelector('meta[name="csrf-token"]').getAttribute('content')
                }
            })
            .then(response => response.text())
            .then(html => {
                productsContainer.innerHTML = html;
                document.getElementById('loading-spinner').classList.add('d-none');
                productsContainer.classList.remove('d-none');
                
                const productCount = document.querySelectorAll('#products-container .col-md-6').length;
                const badge = document.querySelector('.badge.bg-primary');
                if (badge) { badge.textContent = `${productCount} Products`; }
            })
            .catch(error => {
                console.error('Error:', error);
                document.getElementById('loading-spinner').classList.add('d-none');
                productsContainer.classList.remove('d-none');
                showToast('Failed to sort products. Please try again.', 'error');
            });
        });
    }
    
    const loadMoreButton = document.getElementById('load-more-products');
    if (loadMoreButton) {
        loadMoreButton.addEventListener('click', function() {
            showToast('Load more functionality would be implemented here', 'info');
        });
    }
    
    function showToast(message, type) {
        const toast = document.createElement('div');
        toast.className = `toast align-items-center text-white bg-${type === 'success' ? 'success' : type === 'error' ? 'danger' : 'info'} border-0 position-fixed`;
        toast.style.cssText = 'top: 20px; right: 20px; z-index: 9999;';
        toast.setAttribute('role', 'alert');
        toast.setAttribute('aria-live', 'assertive');
        toast.setAttribute('aria-atomic', 'true');
        
        toast.innerHTML = `
            <div class="d-flex">
                <div class="toast-body">
                    <i class="fas fa-${type === 'success' ? 'check-circle' : type === 'error' ? 'exclamation-circle' : 'info-circle'} me-2"></i>
                    ${message}
                </div>
                <button type="button" class="btn-close btn-close-white me-2 m-auto" data-bs-dismiss="toast" aria-label="Close"></button>
            </div>
        `;
        
        document.body.appendChild(toast);
        const bsToast = new bootstrap.Toast(toast);
        bsToast.show();
        
        toast.addEventListener('hidden.bs.toast', function() {
            document.body.removeChild(toast);
        });
    }
});
</script>
@endsection

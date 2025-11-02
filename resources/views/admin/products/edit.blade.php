@extends('admin.layouts.app')

@section('title', 'Edit Product')

@section('content')
<div class="container-fluid h-100">
    <div class="row h-100">
        @include('admin.layouts.sidebar')
        
        <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4 main-content">
            @include('admin.layouts.header', ['pageTitle' => 'Edit Product'])
            
            <div class="pt-4 pb-2 mb-3">
                <div class="row">
                    <div class="col-12">
                        <div class="card border-0 shadow-sm">
                            <div class="card-header bg-white border-0 py-3 d-flex justify-content-between align-items-center">
                                <div>
                                    <h4 class="card-title mb-0 fw-bold">Edit Product</h4>
                                    <p class="mb-0 text-muted">Update product details</p>
                                </div>
                                <a href="{{ route('admin.products.index') }}" class="btn btn-outline-secondary rounded-pill px-4 py-2">
                                    <i class="fas fa-arrow-left me-2"></i> Back to Products
                                </a>
                            </div>
                            
                            <div class="card-body">
                                @if(session('success'))
                                    <div class="alert alert-success alert-dismissible fade show rounded-pill px-4 py-3" role="alert">
                                        <i class="fas fa-check-circle me-2"></i>{{ session('success') }}
                                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                                    </div>
                                @endif
                                
                                @if($errors->any())
                                    <div class="alert alert-danger rounded-pill px-4 py-3">
                                        <i class="fas fa-exclamation-circle me-2"></i>
                                        <ul class="mb-0">
                                            @foreach($errors->all() as $error)
                                                <li>{{ $error }}</li>
                                            @endforeach
                                        </ul>
                                    </div>
                                @endif
                                
                                <form action="{{ route('admin.products.update', $product) }}" method="POST" enctype="multipart/form-data" id="product-form">
                                    @csrf
                                    @method('PUT')
                                    
                                    <div class="row">
                                        <div class="col-lg-8">
                                            <div class="mb-4">
                                                <label for="name" class="form-label fw-bold">Product Name <span class="text-danger">*</span></label>
                                                <input type="text" class="form-control rounded-pill px-4 py-2" id="name" name="name" value="{{ old('name', $product->name) }}" required>
                                            </div>
                                            
                                            <div class="mb-4">
                                                <label for="description" class="form-label fw-bold">Description</label>
                                                <textarea class="form-control" id="description" name="description" rows="5" placeholder="Product description...">{{ old('description', $product->description) }}</textarea>
                                            </div>
                                            
                                            <div class="row">
                                                <div class="col-md-6 mb-4">
                                                    <label for="mrp" class="form-label fw-bold">MRP (₹) <span class="text-danger">*</span></label>
                                                    <input type="number" class="form-control rounded-pill px-4 py-2" id="mrp" name="mrp" value="{{ old('mrp', $product->mrp) }}" step="0.01" min="0" required>
                                                </div>
                                                <div class="col-md-6 mb-4">
                                                    <label for="selling_price" class="form-label fw-bold">Selling Price (₹)</label>
                                                    <input type="number" class="form-control rounded-pill px-4 py-2" id="selling_price" name="selling_price" value="{{ old('selling_price', $product->selling_price) }}" step="0.01" min="0">
                                                    <div class="form-text">Must be less than or equal to MRP</div>
                                                </div>
                                            </div>
                                            
                                            <div class="mb-4">
                                                <label class="form-label fw-bold">Stock Status</label>
                                                <div class="form-check form-switch mb-2">
                                                    <input type="hidden" name="in_stock" value="0">
                                                    <input class="form-check-input" type="checkbox" id="in_stock" name="in_stock" value="1" {{ old('in_stock', $product->in_stock) ? 'checked' : '' }}>
                                                    <label class="form-check-label" for="in_stock">
                                                        <span id="stock-status-text">{{ old('in_stock', $product->in_stock) ? 'In Stock' : 'Out of Stock' }}</span>
                                                    </label>
                                                </div>
                                                <div id="stock_quantity_container" class="{{ old('in_stock', $product->in_stock) ? '' : 'd-none' }}">
                                                    <label for="stock_quantity" class="form-label">Stock Quantity</label>
                                                    <input type="number" class="form-control rounded-pill px-4 py-2" id="stock_quantity" name="stock_quantity" value="{{ old('stock_quantity', $product->stock_quantity) }}" min="0">
                                                </div>
                                            </div>
                                            
                                            <div class="mb-4">
                                                <label for="status" class="form-label fw-bold">Product Status <span class="text-danger">*</span></label>
                                                <select class="form-select rounded-pill px-4 py-2" id="status" name="status" required>
                                                    <option value="draft" {{ old('status', $product->status) == 'draft' ? 'selected' : '' }}>Draft</option>
                                                    <option value="published" {{ old('status', $product->status) == 'published' ? 'selected' : '' }}>Published</option>
                                                </select>
                                            </div>
                                        </div>
                                        
                                        <div class="col-lg-4">
                                            <!-- Category Selection -->
                                            <div class="mb-4">
                                                <label class="form-label fw-bold">Categories</label>
                                                <div id="category-selection">
                                                    @if(isset($categories) && $categories->count() > 0)
                                                        @foreach($categories as $category)
                                                            @php
                                                                // Check if category is selected
                                                                $isCategorySelected = false;
                                                                if (is_array(old('product_categories')) && isset(old('product_categories')[$category->id])) {
                                                                    $isCategorySelected = true;
                                                                } elseif (is_array($product->product_categories) && in_array($category->id, array_column($product->product_categories, 'category_id'))) {
                                                                    $isCategorySelected = true;
                                                                }
                                                            @endphp
                                                            
                                                            <div class="form-check mb-2 category-item" data-category-id="{{ $category->id }}">
                                                                <input class="form-check-input category-checkbox" type="checkbox" id="category_{{ $category->id }}" value="{{ $category->id }}" name="product_categories[{{ $category->id }}][category_id]" {{ $isCategorySelected ? 'checked' : '' }}>
                                                                <label class="form-check-label fw-bold" for="category_{{ $category->id }}">
                                                                    {{ $category->name }}
                                                                </label>
                                                                
                                                                @if($category->subCategories->count() > 0)
                                                                    @php
                                                                        // Check if subcategories should be visible
                                                                        $showSubcategories = $isCategorySelected;
                                                                    @endphp
                                                                    
                                                                    <div class="subcategory-container ms-4 mt-2 {{ $showSubcategories ? '' : 'd-none' }}" id="subcategory_container_{{ $category->id }}">
                                                                        @foreach($category->subCategories as $subcategory)
                                                                            @php
                                                                                // Check if subcategory is selected
                                                                                $isSubcategorySelected = false;
                                                                                if ((is_array(old('product_categories')) && isset(old('product_categories')[$category->id]['subcategory_ids']) && in_array($subcategory->id, old('product_categories')[$category->id]['subcategory_ids']))) {
                                                                                    $isSubcategorySelected = true;
                                                                                } elseif (is_array($product->product_categories) && in_array($category->id, array_column($product->product_categories, 'category_id')) && 
                                                                                    isset(array_column($product->product_categories, 'subcategory_ids', 'category_id')[$category->id]) && 
                                                                                    in_array($subcategory->id, array_column($product->product_categories, 'subcategory_ids', 'category_id')[$category->id])) {
                                                                                    $isSubcategorySelected = true;
                                                                                }
                                                                            @endphp
                                                                            
                                                                            <div class="form-check mb-1">
                                                                                <input class="form-check-input subcategory-checkbox" type="checkbox" id="subcategory_{{ $subcategory->id }}" value="{{ $subcategory->id }}" name="product_categories[{{ $category->id }}][subcategory_ids][]" data-category-id="{{ $category->id }}" {{ $isSubcategorySelected ? 'checked' : '' }}>
                                                                                <label class="form-check-label" for="subcategory_{{ $subcategory->id }}">
                                                                                    {{ $subcategory->name }}
                                                                                </label>
                                                                            </div>
                                                                        @endforeach
                                                                    </div>
                                                                @endif
                                                            </div>
                                                        @endforeach
                                                    @else
                                                        <p class="text-muted">No categories available. Please create categories first.</p>
                                                    @endif
                                                </div>
                                                <div class="mt-2">
                                                    <button type="button" class="btn btn-outline-primary btn-sm rounded-pill" id="manage-categories-btn">
                                                        <i class="fas fa-plus me-1"></i> Manage Categories & Subcategories
                                                    </button>
                                                </div>
                                            </div>
                                        </div>
                                        
                                        <div class="col-lg-8">
                                            <div class="mb-4">
                                                <label class="form-label fw-bold">Main Photo</label>
                                                <div class="border rounded-3 p-3 text-center" id="main-photo-preview">
                                                    @if($product->mainPhoto)
                                                        <div class="bg-light d-flex align-items-center justify-content-center mb-2" style="height: 150px;">
                                                            <img src="{{ $product->mainPhoto->url }}" class="img-fluid" alt="{{ $product->name }}" style="max-height: 100%; max-width: 100%; object-fit: cover;">
                                                        </div>
                                                    @endif
                                                    <button type="button" class="btn btn-outline-primary btn-sm rounded-pill" data-bs-toggle="modal" data-bs-target="#mediaLibraryModal" data-target="main_photo">
                                                        <i class="fas fa-folder-open me-1"></i> {{ $product->mainPhoto ? 'Change Image' : 'Select from Media Library' }}
                                                    </button>
                                                    @if($product->mainPhoto)
                                                    <button type="button" class="btn btn-outline-danger btn-sm rounded-pill ms-2" id="remove-main-photo">
                                                        <i class="fas fa-trash me-1"></i> Remove
                                                    </button>
                                                    @endif
                                                    <input type="hidden" id="main_photo_id" name="main_photo_id" value="{{ old('main_photo_id', $product->main_photo_id) }}">
                                                </div>
                                            </div>
                                            
                                            <div class="mb-4">
                                                <label class="form-label fw-bold">Gallery Photos</label>
                                                <div class="border rounded-3 p-3" id="gallery-photos-container">
                                                    <div id="gallery-preview" class="d-flex flex-wrap gap-2 mb-3">
                                                        @if($product->product_gallery)
                                                            @foreach($product->product_gallery as $mediaId)
                                                                @php
                                                                    $media = \App\Models\Media::find($mediaId);
                                                                @endphp
                                                                @if($media)
                                                                <div class="position-relative gallery-item" data-id="{{ $mediaId }}" draggable="true">
                                                                    <div class="bg-light d-flex align-items-center justify-content-center" style="height: 80px; width: 80px;">
                                                                        <img src="{{ $media->url }}" class="img-fluid" alt="Gallery image" style="max-height: 100%; max-width: 100%; object-fit: cover;">
                                                                    </div>
                                                                    <button type="button" class="btn btn-danger btn-sm position-absolute top-0 end-0 rounded-circle p-1 remove-gallery-item" data-id="{{ $mediaId }}">
                                                                        <i class="fas fa-times"></i>
                                                                    </button>
                                                                    <input type="hidden" name="product_gallery[]" value="{{ $mediaId }}">
                                                                </div>
                                                                @endif
                                                            @endforeach
                                                        @endif
                                                    </div>
                                                    <button type="button" class="btn btn-outline-primary btn-sm rounded-pill" data-bs-toggle="modal" data-bs-target="#mediaLibraryModal" data-target="gallery">
                                                        <i class="fas fa-plus me-1"></i> {{ $product->product_gallery ? 'Add More Photos' : 'Add Photos' }}
                                                    </button>
                                                    <input type="hidden" id="product_gallery" name="product_gallery" value="{{ old('product_gallery', $product->product_gallery ? json_encode($product->product_gallery) : '[]') }}">
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    
                                    <div class="border-top pt-4 mt-4">
                                        <div class="d-flex justify-content-between align-items-center mb-3">
                                            <h5 class="mb-0 fw-bold">SEO Settings</h5>
                                            <button type="button" class="btn btn-outline-secondary btn-sm rounded-pill" id="toggle-seo-settings">
                                                <i class="fas fa-chevron-down me-1"></i> Expand
                                            </button>
                                        </div>
                                        
                                        <div id="seo-settings-content" class="d-none">
                                            <div class="mb-4">
                                                <label for="meta_title" class="form-label fw-bold">Meta Title</label>
                                                <input type="text" class="form-control rounded-pill px-4 py-2" id="meta_title" name="meta_title" value="{{ old('meta_title', $product->meta_title) }}" maxlength="255">
                                            </div>
                                            
                                            <div class="mb-4">
                                                <label for="meta_description" class="form-label fw-bold">Meta Description</label>
                                                <textarea class="form-control" id="meta_description" name="meta_description" rows="3" maxlength="500" placeholder="Brief description for search engines...">{{ old('meta_description', $product->meta_description) }}</textarea>
                                            </div>
                                            
                                            <div class="mb-4">
                                                <label for="meta_keywords" class="form-label fw-bold">Meta Keywords</label>
                                                <input type="text" class="form-control rounded-pill px-4 py-2" id="meta_keywords" name="meta_keywords" value="{{ old('meta_keywords', $product->meta_keywords) }}" placeholder="keyword1, keyword2, keyword3">
                                            </div>
                                        </div>
                                    </div>
                                    
                                    <div class="d-flex justify-content-end gap-2 mt-4">
                                        <a href="{{ route('admin.products.index') }}" class="btn btn-outline-secondary rounded-pill px-4 py-2">
                                            <i class="fas fa-times me-2"></i> Cancel
                                        </a>
                                        <button type="submit" class="btn btn-primary rounded-pill px-4 py-2">
                                            <i class="fas fa-save me-2"></i> Update Product
                                        </button>
                                    </div>
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            @include('admin.layouts.footer')
        </main>
    </div>
</div>

<!-- Media Library Modal -->
<div class="modal fade" id="mediaLibraryModal" tabindex="-1" aria-labelledby="mediaLibraryModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-xl modal-dialog-centered">
        <div class="modal-content border-0 shadow">
            <div class="modal-header border-0 pb-0">
                <h5 class="modal-title fw-bold" id="mediaLibraryModalLabel">Media Library</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body pt-0">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <div>
                        <button class="btn btn-outline-primary btn-sm rounded-pill" id="upload-media-btn">
                            <i class="fas fa-upload me-1"></i> Upload New
                        </button>
                    </div>
                    <div class="d-flex gap-2">
                        <input type="text" class="form-control form-control-sm rounded-pill" id="media-search" placeholder="Search media..." style="width: 200px;">
                        <select class="form-select form-select-sm rounded-pill" id="media-filter">
                            <option value="all">All Media</option>
                            <option value="images">Images</option>
                            <option value="videos">Videos</option>
                        </select>
                    </div>
                </div>
                
                <div class="row g-3" id="media-library-items">
                    <!-- Media items will be loaded here via AJAX -->
                    <div class="col-12 text-center py-5" id="media-loading">
                        <div class="spinner-border text-primary" role="status">
                            <span class="visually-hidden">Loading...</span>
                        </div>
                    </div>
                    <div class="col-12 text-center py-5 d-none" id="no-media-message">
                        <i class="fas fa-image fa-3x text-muted mb-3"></i>
                        <h5 class="mb-2">No media found</h5>
                        <p class="text-muted mb-3">Upload your first image to get started</p>
                        <div class="upload-area" id="empty-state-upload">
                            <i class="fas fa-cloud-upload-alt"></i>
                            <p class="mb-0">Drag & drop files here or click to upload</p>
                        </div>
                    </div>
                </div>
                
                <div class="d-flex justify-content-center mt-4" id="load-more-container">
                    <button class="btn btn-outline-primary rounded-pill d-none" id="load-more-btn">
                        <i class="fas fa-sync me-1"></i> Load More
                    </button>
                </div>
            </div>
            <div class="modal-footer border-0 pt-0">
                <button type="button" class="btn btn-outline-secondary rounded-pill px-4" data-bs-dismiss="modal">
                    <i class="fas fa-times me-2"></i> Cancel
                </button>
                <button type="button" class="btn btn-primary rounded-pill px-4" id="select-media-btn" disabled>
                    <i class="fas fa-check me-2"></i> Select
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Unified Category Management Modal -->
<div class="modal fade" id="categoryManagementModal" tabindex="-1" aria-labelledby="categoryManagementModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="categoryManagementModalLabel">Manage Categories & Subcategories</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div class="row">
                    <div class="col-md-6">
                        <h6 class="fw-bold mb-3">Categories</h6>
                        <div class="mb-3">
                            <div class="input-group">
                                <input type="text" class="form-control rounded-pill" id="new-category-name" placeholder="Enter category name">
                                <button class="btn btn-outline-primary rounded-pill" type="button" id="add-category-btn">
                                    <i class="fas fa-plus"></i>
                                </button>
                            </div>
                        </div>
                        <div id="categories-list" class="border rounded-3 p-3" style="max-height: 300px; overflow-y: auto;">
                            <!-- Categories will be loaded here dynamically -->
                        </div>
                    </div>
                    <div class="col-md-6">
                        <h6 class="fw-bold mb-3">Subcategories</h6>
                        <div class="mb-3">
                            <select class="form-select rounded-pill mb-2" id="subcategory-parent-category">
                                <option value="">Select a category first</option>
                                @if(isset($categories))
                                    @foreach($categories as $category)
                                        <option value="{{ $category->id }}">{{ $category->name }}</option>
                                    @endforeach
                                @endif
                            </select>
                            <div class="input-group">
                                <input type="text" class="form-control rounded-pill" id="new-subcategory-name" placeholder="Enter subcategory name">
                                <button class="btn btn-outline-primary rounded-pill" type="button" id="add-subcategory-btn" disabled>
                                    <i class="fas fa-plus"></i>
                                </button>
                            </div>
                        </div>
                        <div id="subcategories-list" class="border rounded-3 p-3" style="max-height: 300px; overflow-y: auto;">
                            <!-- Subcategories will be loaded here dynamically -->
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary rounded-pill" data-bs-dismiss="modal">
                    <i class="fas fa-times me-2"></i>Close
                </button>
                <button type="button" class="btn btn-primary rounded-pill" id="save-category-selections">
                    <i class="fas fa-save me-2"></i>Save Selections
                </button>
            </div>
        </div>
    </div>
</div>

@push('scripts')
<script>
    // All JavaScript functionality has been moved to resources/js/common.js
</script>
@endpush
@endsection
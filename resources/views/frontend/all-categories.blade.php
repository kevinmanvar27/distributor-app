@extends('frontend.layouts.app')

@section('title', 'All Categories - ' . setting('site_title', 'Frontend App'))

@section('content')
<div class="container py-5">
    <!-- Page Header -->
    <div class="row mb-5">
        <div class="col-12 text-center">
            <h1 class="display-4 fw-bold mb-3" style="color: var(--heading-text-color);">
                <i class="fas fa-tags me-3" style="color: var(--theme-color);"></i>All Categories
            </h1>
            <p class="lead text-muted">Browse through all our product categories</p>
        </div>
    </div>
    
    @if($categories->count() > 0)
    <div class="row g-4" id="categories-container">
        @foreach($categories->take(8) as $index => $category)
        <div class="col-sm-6 col-md-4 col-lg-3 fade-in category-item" style="animation-delay: {{ $index * 0.05 }}s;">
            <div class="card h-100 border-0 category-card">
                <div class="position-relative overflow-hidden" style="border-radius: var(--radius-lg) var(--radius-lg) 0 0;">
                    @if($category->image)
                        <img src="{{ $category->image->url }}" class="card-img-top" alt="{{ $category->name }}" style="height: 220px; object-fit: cover;">
                    @else
                        <div class="bg-gradient-theme d-flex align-items-center justify-content-center" style="height: 220px;">
                            <i class="fas fa-image fa-4x text-white opacity-50"></i>
                        </div>
                    @endif
                    @if($category->product_count > 0)
                    <div class="position-absolute top-0 end-0 m-3">
                        <span class="badge bg-success shadow-sm" style="font-size: 0.875rem; padding: 0.5rem 0.875rem;">
                            {{ $category->product_count }} Products
                        </span>
                    </div>
                    @endif
                </div>
                <div class="card-body d-flex flex-column p-4">
                    <h5 class="card-title fw-bold mb-2" style="color: var(--heading-text-color);">{{ $category->name }}</h5>
                    <p class="card-text text-muted flex-grow-1 mb-3" style="font-size: 0.9375rem;">
                        {{ Str::limit($category->description ?? 'Explore our collection', 80) }}
                    </p>
                    <div class="d-flex align-items-center text-muted" style="font-size: 0.875rem;">
                        <i class="fas fa-layer-group me-2 text-theme"></i>
                        <span>{{ $category->subCategories->count() }} Subcategories</span>
                    </div>
                </div>
                <div class="card-footer bg-transparent border-0 p-4 pt-0">
                    <a href="{{ route('frontend.category.show', $category) }}" class="btn btn-theme w-100 btn-ripple hover-lift">
                        <i class="fas fa-arrow-right me-2"></i>Explore Category
                    </a>
                </div>
            </div>
        </div>
        @endforeach
    </div>
    
    @if($totalCategories > 8)
    <div class="row mt-5">
        <div class="col-12 text-center">
            <button id="load-more-btn" class="btn btn-theme btn-lg px-5 py-3 btn-ripple hover-lift" data-offset="8">
                <i class="fas fa-plus-circle me-2"></i>Load More Categories
                <span class="ms-2 badge bg-white text-theme">{{ $totalCategories - 8 }} more</span>
            </button>
        </div>
    </div>
    @endif
    @else
    <div class="row">
        <div class="col-12">
            <div class="alert alert-info d-flex align-items-center justify-content-center" style="border-radius: var(--radius-lg); min-height: 300px;">
                <div class="text-center">
                    <i class="fas fa-info-circle mb-3" style="font-size: 3rem; color: var(--theme-color);"></i>
                    <h4 class="mb-2">No Categories Available</h4>
                    <p class="mb-3">Categories will appear here once they are added.</p>
                    <a href="{{ route('frontend.home') }}" class="btn btn-theme">
                        <i class="fas fa-home me-2"></i>Back to Home
                    </a>
                </div>
            </div>
        </div>
    </div>
    @endif
</div>

<style>
    .category-card {
        transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
        box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    }
    
    .category-card:hover {
        transform: translateY(-8px) scale(1.02);
        box-shadow: 0 8px 24px rgba(0,0,0,0.15);
    }
    
    .fade-in {
        animation: fadeInUp 0.6s ease-out forwards;
        opacity: 0;
    }
    
    @keyframes fadeInUp {
        from {
            opacity: 0;
            transform: translateY(30px);
        }
        to {
            opacity: 1;
            transform: translateY(0);
        }
    }
</style>
@endsection

@section('scripts')
<script>
$(document).ready(function() {
    let isLoading = false;
    let currentOffset = 8;
    let remainingCount = {{ $totalCategories - 8 }};
    
    $('#load-more-btn').on('click', function() {
        if (isLoading) return;
        
        isLoading = true;
        const btn = $(this);
        const originalHtml = btn.html();
        
        // Show loading state
        btn.html('<span class="spinner-border spinner-border-sm me-2" role="status" aria-hidden="true"></span>Loading...');
        btn.prop('disabled', true);
        
        $.ajax({
            url: '{{ route("frontend.categories.all") }}',
            type: 'GET',
            data: {
                offset: currentOffset
            },
            dataType: 'json',
            success: function(response) {
                if (response.html) {
                    // Append new categories
                    $('#categories-container').append(response.html);
                    
                    // Trigger fade-in animation for new items
                    setTimeout(function() {
                        $('.category-item').each(function(index) {
                            $(this).css('animation-delay', (index * 0.05) + 's');
                        });
                    }, 50);
                    
                    // Update offset and remaining count
                    currentOffset = response.newOffset;
                    remainingCount = {{ $totalCategories }} - currentOffset;
                    
                    // Update or hide button
                    if (response.hasMore && remainingCount > 0) {
                        btn.html('<i class="fas fa-plus-circle me-2"></i>Load More Categories<span class="ms-2 badge bg-white text-theme">' + remainingCount + ' more</span>');
                        btn.prop('disabled', false);
                    } else {
                        btn.fadeOut(300, function() {
                            $(this).remove();
                        });
                    }
                }
            },
            error: function(xhr, status, error) {
                console.error('Error loading more categories:', error);
                btn.html(originalHtml);
                btn.prop('disabled', false);
                
                // Show error message
                showToast('Error loading more categories. Please try again.', 'error');
            },
            complete: function() {
                isLoading = false;
            }
        });
    });
});
</script>
@endsection

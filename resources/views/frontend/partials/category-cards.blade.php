@foreach($categories as $index => $category)
<div class="col-sm-6 col-md-4 col-lg-3 fade-in category-item">
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

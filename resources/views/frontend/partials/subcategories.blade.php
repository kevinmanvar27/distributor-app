@if($subCategories->count() > 0)
<div class="row">
    @foreach($subCategories as $subCategory)
    <div class="col-md-6 mb-3">
        <div class="card h-100 shadow-sm border-0 subcategory-card">
            <div class="position-relative">
                @if($subCategory->image)
                    <img src="{{ $subCategory->image->url }}" class="card-img-top" alt="{{ $subCategory->name }}" style="height: 120px; object-fit: cover;">
                @else
                    <div class="bg-light d-flex align-items-center justify-content-center" style="height: 120px;">
                        <i class="fas fa-image fa-2x text-muted"></i>
                    </div>
                @endif
                <div class="position-absolute top-0 end-0 m-2">
                    <span class="badge bg-theme text-white">{{ $subCategory->is_active ? 'Active' : 'Inactive' }}</span>
                </div>
            </div>
            <div class="card-body">
                <h6 class="card-title mb-1">{{ $subCategory->name }}</h6>
                <p class="card-text small text-muted mb-0">{{ Str::limit($subCategory->description ?? 'No description available', 80) }}</p>
            </div>
        </div>
    </div>
    @endforeach
</div>
@else
<div class="alert alert-info text-center">
    <i class="fas fa-info-circle me-2"></i>No subcategories available for this category.
</div>
@endif
@extends('admin.layouts.app')

@section('title', 'Create Attribute')

@section('content')
<div class="container-fluid h-100">
    <div class="row h-100">
        @include('admin.layouts.sidebar')
        
        <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4 main-content">
            @include('admin.layouts.header', ['pageTitle' => 'Create Attribute'])
            
            <div class="pt-4 pb-2 mb-3">
<div class="container-fluid">
    <div class="row mb-4">
        <div class="col-12">
            <div class="d-flex justify-content-between align-items-center">
                <h1 class="h3 mb-0">Create New Attribute</h1>
                <a href="{{ route('admin.attributes.index') }}" class="btn btn-secondary">
                    <i class="fas fa-arrow-left"></i> Back to Attributes
                </a>
            </div>
        </div>
    </div>

    @if($errors->any())
        <div class="alert alert-danger alert-dismissible fade show" role="alert">
            <ul class="mb-0">
                @foreach($errors->all() as $error)
                    <li>{{ $error }}</li>
                @endforeach
            </ul>
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    @endif

    <div class="card">
        <div class="card-body">
            <form action="{{ route('admin.attributes.store') }}" method="POST">
                @csrf

                <div class="row">
                    <div class="col-md-6">
                        <div class="mb-3">
                            <label for="name" class="form-label">Attribute Name <span class="text-danger">*</span></label>
                            <input type="text" class="form-control @error('name') is-invalid @enderror" 
                                   id="name" name="name" value="{{ old('name') }}" required>
                            <small class="text-muted">e.g., Size, Color, Material</small>
                            @error('name')
                                <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                        </div>
                    </div>

                    <div class="col-md-3">
                        <div class="mb-3">
                            <label for="sort_order" class="form-label">Sort Order</label>
                            <input type="number" class="form-control @error('sort_order') is-invalid @enderror" 
                                   id="sort_order" name="sort_order" value="{{ old('sort_order', 0) }}" min="0">
                            @error('sort_order')
                                <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                        </div>
                    </div>

                    <div class="col-md-3">
                        <div class="mb-3">
                            <label for="is_active" class="form-label">Status</label>
                            <select class="form-select @error('is_active') is-invalid @enderror" id="is_active" name="is_active" required>
                                <option value="1" {{ old('is_active', '1') == '1' ? 'selected' : '' }}>Active</option>
                                <option value="0" {{ old('is_active') == '0' ? 'selected' : '' }}>Inactive</option>
                            </select>
                            @error('is_active')
                                <div class="invalid-feedback">{{ $message }}</div>
                            @enderror
                        </div>
                    </div>
                </div>

                <div class="mb-3">
                    <label for="description" class="form-label">Description</label>
                    <textarea class="form-control @error('description') is-invalid @enderror" 
                              id="description" name="description" rows="3">{{ old('description') }}</textarea>
                    @error('description')
                        <div class="invalid-feedback">{{ $message }}</div>
                    @enderror
                </div>

                <!-- Attribute Values Section -->
                <div class="mb-4">
                    <label class="form-label">Attribute Values <span class="text-danger">*</span></label>
                    <small class="text-muted d-block mb-2">Add at least one value for this attribute (e.g., for Size: Small, Medium, Large)</small>
                    
                    <div id="valuesContainer">
                        @if(old('values'))
                            @foreach(old('values') as $index => $value)
                                <div class="input-group mb-2 value-row">
                                    <input type="text" class="form-control @error('values.'.$index) is-invalid @enderror" 
                                           name="values[]" value="{{ $value }}" placeholder="Enter value">
                                    <button type="button" class="btn btn-outline-danger remove-value-btn">
                                        <i class="fas fa-times"></i>
                                    </button>
                                    @error('values.'.$index)
                                        <div class="invalid-feedback">{{ $message }}</div>
                                    @enderror
                                </div>
                            @endforeach
                        @else
                            <div class="input-group mb-2 value-row">
                                <input type="text" class="form-control" name="values[]" placeholder="Enter value">
                                <button type="button" class="btn btn-outline-danger remove-value-btn">
                                    <i class="fas fa-times"></i>
                                </button>
                            </div>
                        @endif
                    </div>
                    
                    <button type="button" class="btn btn-outline-primary btn-sm" id="addValueBtn">
                        <i class="fas fa-plus me-1"></i> Add Another Value
                    </button>
                    
                    @error('values')
                        <div class="text-danger mt-1"><small>{{ $message }}</small></div>
                    @enderror
                </div>

                <div class="d-flex justify-content-end gap-2">
                    <a href="{{ route('admin.attributes.index') }}" class="btn btn-secondary">Cancel</a>
                    <button type="submit" class="btn btn-primary">Create Attribute</button>
                </div>
            </form>
        </div>
    </div>
</div>
            </div>
        </main>
    </div>
</div>
@endsection

@section('scripts')
<script>
document.addEventListener('DOMContentLoaded', function() {
    const valuesContainer = document.getElementById('valuesContainer');
    const addValueBtn = document.getElementById('addValueBtn');
    
    // Add new value row
    addValueBtn.addEventListener('click', function() {
        const newRow = document.createElement('div');
        newRow.className = 'input-group mb-2 value-row';
        newRow.innerHTML = `
            <input type="text" class="form-control" name="values[]" placeholder="Enter value">
            <button type="button" class="btn btn-outline-danger remove-value-btn">
                <i class="fas fa-times"></i>
            </button>
        `;
        valuesContainer.appendChild(newRow);
        
        // Focus on the new input
        newRow.querySelector('input').focus();
    });
    
    // Remove value row (using event delegation)
    valuesContainer.addEventListener('click', function(e) {
        if (e.target.closest('.remove-value-btn')) {
            const rows = valuesContainer.querySelectorAll('.value-row');
            if (rows.length > 1) {
                e.target.closest('.value-row').remove();
            } else {
                // Don't remove the last row, just clear it
                rows[0].querySelector('input').value = '';
            }
        }
    });
});
</script>
@endsection

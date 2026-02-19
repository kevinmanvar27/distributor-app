@extends('admin.layouts.app')

@section('title', 'Import Products')

@section('content')
<div class="container-fluid h-100">
    <div class="row h-100">
        @include('admin.layouts.sidebar')
        
        <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4 main-content">
            @include('admin.layouts.header', ['pageTitle' => 'Import Products'])
            
            <div class="pt-4 pb-2 mb-3">
                <div class="row">
                    <div class="col-12">
                        <div class="card border-0 shadow-sm">
                            <div class="card-header bg-white border-0 py-3">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div>
                                        <h4 class="card-title mb-0 fw-bold h5 h4-md">Import Products</h4>
                                        <p class="mb-0 text-muted small">Upload a CSV file to import products</p>
                                    </div>
                                    <a href="{{ route('admin.products.index') }}" class="btn btn-sm btn-secondary rounded-pill px-3 px-md-4">
                                        <i class="fas fa-arrow-left me-1 me-md-2"></i><span class="d-none d-sm-inline">Back to Products</span><span class="d-sm-none">Back</span>
                                    </a>
                                </div>
                            </div>
                            
                            <div class="card-body">
                                @if(session('success'))
                                    <div class="alert-theme alert-success alert-dismissible fade show rounded-pill px-4 py-3" role="alert">
                                        <i class="fas fa-check-circle me-2"></i>{{ session('success') }}
                                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                                    </div>
                                @endif
                                
                                @if(session('error'))
                                    <div class="alert-theme alert-danger alert-dismissible fade show rounded-pill px-4 py-3" role="alert">
                                        <i class="fas fa-exclamation-circle me-2"></i>{{ session('error') }}
                                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                                    </div>
                                @endif
                                
                                @if($errors->any())
                                    <div class="alert-theme alert-danger alert-dismissible fade show rounded px-4 py-3" role="alert">
                                        <i class="fas fa-exclamation-circle me-2"></i>
                                        <strong>Please fix the following errors:</strong>
                                        <ul class="mb-0 mt-2">
                                            @foreach($errors->all() as $error)
                                                <li>{{ $error }}</li>
                                            @endforeach
                                        </ul>
                                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                                    </div>
                                @endif
                                
                                <!-- Instructions -->
                                <div class="alert-theme alert-info rounded-3 mb-4">
                                    <h5 class="alert-heading"><i class="fas fa-info-circle me-2"></i>Import Instructions</h5>
                                    <hr>
                                    <ol class="mb-0">
                                        <li class="mb-2">Download the CSV template to see the required format</li>
                                        <li class="mb-2">Fill in your product data following the template format</li>
                                        <li class="mb-2">Leave the ID column empty for new products</li>
                                        <li class="mb-2">Include the ID to update existing products (requires "Update Existing" option)</li>
                                        <li class="mb-2">Use "Yes" or "No" for the "In Stock" column</li>
                                        <li class="mb-2">Product Type should be either "simple" or "variable"</li>
                                        <li class="mb-2">Status should be either "draft" or "published"</li>
                                        <li>Upload your completed CSV file below</li>
                                    </ol>
                                </div>
                                
                                <!-- Download Template -->
                                <div class="mb-4 text-center">
                                    <a href="{{ route('admin.products.template') }}" class="btn btn-outline-primary btn-lg rounded-pill px-5">
                                        <i class="fas fa-download me-2"></i>Download CSV Template
                                    </a>
                                </div>
                                
                                <hr class="my-4">
                                
                                <!-- Import Form -->
                                <form action="{{ route('admin.products.import') }}" method="POST" enctype="multipart/form-data" id="importForm">
                                    @csrf
                                    
                                    <div class="row justify-content-center">
                                        <div class="col-lg-8">
                                            <!-- File Upload -->
                                            <div class="mb-4">
                                                <label for="file" class="form-label fw-bold">
                                                    <i class="fas fa-file-csv me-2"></i>Select CSV File
                                                    <span class="text-danger">*</span>
                                                </label>
                                                <input type="file" 
                                                       class="form-control form-control-lg @error('file') is-invalid @enderror" 
                                                       id="file" 
                                                       name="file" 
                                                       accept=".csv,.txt"
                                                       required>
                                                @error('file')
                                                    <div class="invalid-feedback">{{ $message }}</div>
                                                @enderror
                                                <div class="form-text">
                                                    <i class="fas fa-info-circle me-1"></i>
                                                    Accepted formats: CSV, TXT (Max size: 10MB)
                                                </div>
                                            </div>
                                            
                                            <!-- Update Existing Option -->
                                            <div class="mb-4">
                                                <div class="form-check form-switch">
                                                    <input class="form-check-input" 
                                                           type="checkbox" 
                                                           id="update_existing" 
                                                           name="update_existing"
                                                           value="1">
                                                    <label class="form-check-label" for="update_existing">
                                                        <strong>Update Existing Products</strong>
                                                        <div class="form-text">
                                                            If enabled, products with matching IDs or slugs will be updated. 
                                                            Otherwise, they will be skipped.
                                                        </div>
                                                    </label>
                                                </div>
                                            </div>
                                            
                                            <!-- Submit Buttons -->
                                            <div class="d-flex gap-2 justify-content-center">
                                                <button type="submit" class="btn btn-success btn-lg rounded-pill px-5">
                                                    <i class="fas fa-upload me-2"></i>Import Products
                                                </button>
                                                <a href="{{ route('admin.products.index') }}" class="btn btn-secondary btn-lg rounded-pill px-5">
                                                    <i class="fas fa-times me-2"></i>Cancel
                                                </a>
                                            </div>
                                        </div>
                                    </div>
                                </form>
                                
                                <!-- Import Tips -->
                                <div class="mt-5">
                                    <div class="card border-warning">
                                        <div class="card-header bg-warning bg-opacity-10 border-warning">
                                            <h5 class="mb-0"><i class="fas fa-lightbulb me-2"></i>Import Tips</h5>
                                        </div>
                                        <div class="card-body">
                                            <ul class="mb-0">
                                                <li class="mb-2"><strong>Product Gallery IDs:</strong> Separate multiple media IDs with pipe (|) character. Example: 1|2|3</li>
                                                <li class="mb-2"><strong>Product Categories:</strong> Use JSON format. Example: [{"category_id":1,"subcategory_ids":[1,2]}]</li>
                                                <li class="mb-2"><strong>Product Attributes:</strong> Use JSON format for variable products. Example: [{"attribute_id":1,"values":[1,2]}]</li>
                                                <li class="mb-2"><strong>Encoding:</strong> Make sure your CSV file is saved with UTF-8 encoding</li>
                                                <li class="mb-2"><strong>Large Files:</strong> For importing many products, consider splitting into smaller files</li>
                                                <li><strong>Backup:</strong> Always backup your database before importing large datasets</li>
                                            </ul>
                                        </div>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            @include('admin.layouts.footer')
        </main>
    </div>
</div>
@endsection

@section('scripts')
<script>
    $(document).ready(function() {
        // Show file name when selected
        $('#file').on('change', function() {
            const fileName = $(this).val().split('\\').pop();
            if (fileName) {
                $(this).next('.form-text').html('<i class="fas fa-check-circle text-success me-1"></i>Selected: ' + fileName);
            }
        });
        
        // Form validation
        $('#importForm').on('submit', function(e) {
            const fileInput = $('#file')[0];
            if (!fileInput.files.length) {
                e.preventDefault();
                alert('Please select a CSV file to import.');
                return false;
            }
            
            // Show loading indicator
            const submitBtn = $(this).find('button[type="submit"]');
            submitBtn.prop('disabled', true);
            submitBtn.html('<i class="fas fa-spinner fa-spin me-2"></i>Importing...');
        });
    });
</script>
@endsection

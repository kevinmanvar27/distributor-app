@extends('admin.layouts.app')

@section('title', 'Categories')

@section('content')
<div class="container-fluid h-100">
    <div class="row h-100">
        @include('admin.layouts.sidebar')
        
        <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4 main-content">
            @include('admin.layouts.header', ['pageTitle' => 'Category Management'])
            
            <div class="pt-4 pb-2 mb-3">
                <div class="row">
                    <div class="col-12">
                        <div class="card border-0 shadow-sm">
                            <div class="card-header bg-white border-0 py-3 d-flex justify-content-between align-items-center">
                                <div>
                                    <h4 class="card-title mb-0 fw-bold">Category Management</h4>
                                    <p class="mb-0 text-muted">Manage product categories and subcategories</p>
                                </div>
                                <button type="button" class="btn btn-theme rounded-pill px-4" data-bs-toggle="modal" data-bs-target="#categoryModal" onclick="showCategoryModal()">
                                    <i class="fas fa-plus me-2"></i> Add New Category
                                </button>
                            </div>
                            
                            <div class="card-body">
                                @if(session('success'))
                                    <div class="alert alert-success alert-dismissible fade show rounded-pill px-4 py-3" role="alert">
                                        <i class="fas fa-check-circle me-2"></i>{{ session('success') }}
                                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                                    </div>
                                @endif
                                
                                @if(session('error'))
                                    <div class="alert alert-danger alert-dismissible fade show rounded-pill px-4 py-3" role="alert">
                                        <i class="fas fa-exclamation-circle me-2"></i>{{ session('error') }}
                                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                                    </div>
                                @endif
                                
                                <div class="table-responsive">
                                    <table class="table table-hover align-middle" id="categoriesTable">
                                        <thead class="table-light">
                                            <tr>
                                                <th>ID</th>
                                                <th>Category</th>
                                                <th>Description</th>
                                                <th>Status</th>
                                                <th>Created</th>
                                                <th>Actions</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            @forelse($categories as $category)
                                                <tr>
                                                    <td class="fw-bold">{{ $category->id }}</td>
                                                    <td>
                                                        <div class="d-flex align-items-center">
                                                            @if($category->image)
                                                                <img src="{{ $category->image->url }}" 
                                                                     class="rounded me-3" width="40" height="40" alt="{{ $category->name }}" 
                                                                     onerror="this.onerror=null;this.parentElement.innerHTML='<div class=\'bg-light rounded me-3 d-flex align-items-center justify-content-center\' style=\'width: 40px; height: 40px;\'><i class=\'fas fa-image text-muted\'></i></div><div><div class=\'fw-medium\'>{{ $category->name }}</div></div>';"
                                                                     loading="lazy">
                                                            @else
                                                                <div class="bg-light rounded me-3 d-flex align-items-center justify-content-center" style="width: 40px; height: 40px;">
                                                                    <i class="fas fa-image text-muted"></i>
                                                                </div>
                                                            @endif
                                                            <div>
                                                                <div class="fw-medium">{{ $category->name }}</div>
                                                            </div>
                                                        </div>
                                                    </td>
                                                    <td>
                                                        @if($category->description)
                                                            <span class="text-muted">{{ Str::limit($category->description, 50) }}</span>
                                                        @else
                                                            <span class="text-muted">N/A</span>
                                                        @endif
                                                    </td>
                                                    <td>
                                                        @if($category->is_active)
                                                            <span class="badge bg-success-subtle text-success-emphasis rounded-pill px-3 py-2">
                                                                Active
                                                            </span>
                                                        @else
                                                            <span class="badge bg-secondary-subtle text-secondary-emphasis rounded-pill px-3 py-2">
                                                                Inactive
                                                            </span>
                                                        @endif
                                                    </td>
                                                    <td>
                                                        @if($category->created_at)
                                                            <span class="text-muted" data-bs-toggle="tooltip" data-bs-title="{{ $category->created_at->format('F j, Y \a\t g:i A') }}">
                                                                {{ $category->created_at->diffForHumans() }}
                                                            </span>
                                                        @else
                                                            <span class="text-muted">N/A</span>
                                                        @endif
                                                    </td>
                                                    <td>
                                                        <div class="btn-group btn-group-sm" role="group">
                                                            <button type="button" class="btn btn-outline-info rounded-start-pill px-3" onclick="showSubCategories({{ $category->id }})">
                                                                <i class="fas fa-list"></i>
                                                            </button>
                                                            <button type="button" class="btn btn-outline-secondary px-3" data-bs-toggle="modal" data-bs-target="#categoryModal" onclick="editCategory({{ $category->id }})">
                                                                <i class="fas fa-edit"></i>
                                                            </button>
                                                            <button type="button" class="btn btn-outline-danger rounded-end-pill px-3" onclick="deleteCategory({{ $category->id }})">
                                                                <i class="fas fa-trash"></i>
                                                            </button>
                                                        </div>
                                                    </td>
                                                </tr>
                                            @empty
                                                <tr>
                                                    <td colspan="6" class="text-center py-5">
                                                        <div class="text-muted">
                                                            <i class="fas fa-tags fa-2x mb-3"></i>
                                                            <p class="mb-0">No categories found</p>
                                                            <p class="small">Try creating a new category</p>
                                                        </div>
                                                    </td>
                                                </tr>
                                            @endforelse
                                        </tbody>
                                    </table>
                                </div>
                                
                                @if($categories->hasPages())
                                    <div class="d-flex justify-content-center mt-4">
                                        {{ $categories->links() }}
                                    </div>
                                @endif
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            @include('admin.layouts.footer')
        </main>
    </div>
</div>

<!-- Category Modal -->
<div class="modal fade" id="categoryModal" tabindex="-1" aria-labelledby="categoryModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="categoryModalLabel">Add New Category</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form id="categoryForm" enctype="multipart/form-data">
                @csrf
                <input type="hidden" id="categoryId" name="id">
                <div class="modal-body">
                    <div class="mb-3">
                        <label for="categoryName" class="form-label fw-bold">Category Name <span class="text-danger">*</span></label>
                        <input type="text" class="form-control rounded-pill px-4 py-2" id="categoryName" name="name" required>
                    </div>
                    
                    <div class="mb-3">
                        <label for="categoryDescription" class="form-label fw-bold">Description</label>
                        <textarea class="form-control" id="categoryDescription" name="description" rows="3"></textarea>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label fw-bold">Category Image</label>
                        <div class="border rounded-3 p-3 text-center" id="category-image-preview">
                            <div class="py-3">
                                <i class="fas fa-image fa-2x text-muted mb-2"></i>
                                <p class="text-muted mb-2">No image selected</p>
                                <button type="button" class="btn btn-outline-theme btn-sm rounded-pill" onclick="openMediaLibrary('category')">
                                    <i class="fas fa-folder-open me-1"></i> Select Image
                                </button>
                            </div>
                        </div>
                        <input type="hidden" id="categoryImageId" name="image_id">
                    </div>
                    
                    <div class="mb-3">
                        <label for="categoryStatus" class="form-label fw-bold">Status</label>
                        <select class="form-select rounded-pill px-4 py-2" id="categoryStatus" name="is_active" required>
                            <option value="1">Active</option>
                            <option value="0">Inactive</option>
                        </select>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary rounded-pill" data-bs-dismiss="modal">
                        <i class="fas fa-times me-2"></i>Close
                    </button>
                    <button type="submit" class="btn btn-theme rounded-pill">
                        <i class="fas fa-save me-2"></i>Save Category
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Subcategories Modal -->
<div class="modal fade" id="subcategoriesModal" tabindex="-1" aria-labelledby="subcategoriesModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="subcategoriesModalLabel">Subcategories</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div class="d-flex justify-content-between align-items-center mb-3">
                    <h6 id="subcategoryParentName">Subcategories</h6>
                    <button type="button" class="btn btn-theme rounded-pill btn-sm" data-bs-toggle="modal" data-bs-target="#subcategoryModal" onclick="showSubCategoryModal()">
                        <i class="fas fa-plus me-1"></i> Add Subcategory
                    </button>
                </div>
                
                <div class="table-responsive">
                    <table class="table table-hover align-middle" id="subcategoriesTable">
                        <thead class="table-light">
                            <tr>
                                <th>ID</th>
                                <th>Subcategory</th>
                                <th>Description</th>
                                <th>Status</th>
                                <th>Actions</th>
                            </tr>
                        </thead>
                        <tbody id="subcategoriesTableBody">
                            <!-- Subcategories will be loaded here -->
                        </tbody>
                    </table>
                </div>
                
                <div id="subcategoriesPagination" class="d-flex justify-content-center mt-3">
                    <!-- Pagination will be loaded here -->
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary rounded-pill" data-bs-dismiss="modal">
                    <i class="fas fa-times me-2"></i>Close
                </button>
            </div>
        </div>
    </div>
</div>

<!-- Subcategory Modal -->
<div class="modal fade" id="subcategoryModal" tabindex="-1" aria-labelledby="subcategoryModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="subcategoryModalLabel">Add New Subcategory</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <form id="subcategoryForm" enctype="multipart/form-data">
                @csrf
                <input type="hidden" id="subcategoryId" name="id">
                <input type="hidden" id="subcategoryCategoryId" name="category_id">
                <div class="modal-body">
                    <div class="mb-3">
                        <label for="subcategoryName" class="form-label fw-bold">Subcategory Name <span class="text-danger">*</span></label>
                        <input type="text" class="form-control rounded-pill px-4 py-2" id="subcategoryName" name="name" required>
                    </div>
                    
                    <div class="mb-3">
                        <label for="subcategoryDescription" class="form-label fw-bold">Description</label>
                        <textarea class="form-control" id="subcategoryDescription" name="description" rows="3"></textarea>
                    </div>
                    
                    <div class="mb-3">
                        <label class="form-label fw-bold">Subcategory Image</label>
                        <div class="border rounded-3 p-3 text-center" id="subcategory-image-preview">
                            <div class="py-3">
                                <i class="fas fa-image fa-2x text-muted mb-2"></i>
                                <p class="text-muted mb-2">No image selected</p>
                                <button type="button" class="btn btn-outline-primary btn-sm rounded-pill" onclick="openMediaLibrary('subcategory')">
                                    <i class="fas fa-folder-open me-1"></i> Select Image
                                </button>
                            </div>
                        </div>
                        <input type="hidden" id="subcategoryImageId" name="image_id">
                    </div>
                    
                    <div class="mb-3">
                        <label for="subcategoryStatus" class="form-label fw-bold">Status</label>
                        <select class="form-select rounded-pill px-4 py-2" id="subcategoryStatus" name="is_active" required>
                            <option value="1">Active</option>
                            <option value="0">Inactive</option>
                        </select>
                    </div>
                </div>
                <div class="modal-footer">
                    <button type="button" class="btn btn-secondary rounded-pill" data-bs-dismiss="modal">
                        <i class="fas fa-times me-2"></i>Close
                    </button>
                    <button type="submit" class="btn btn-theme rounded-pill">
                        <i class="fas fa-save me-2"></i>Save Subcategory
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- Media Library Modal -->
<div class="modal fade" id="mediaLibraryModal" tabindex="-1" aria-labelledby="mediaLibraryModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-xl">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="mediaLibraryModalLabel">Media Library</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <div class="row">
                    <div class="col-md-3">
                        <div class="border rounded-3 p-3 mb-3">
                            <h6 class="mb-3">Upload New Media</h6>
                            <form id="mediaUploadForm">
                                @csrf
                                <div class="mb-3">
                                    <label for="mediaFile" class="form-label">Select File</label>
                                    <input type="file" class="form-control" id="mediaFile" name="file" accept="image/*">
                                </div>
                                <div class="mb-3">
                                    <label for="mediaName" class="form-label">Name (Optional)</label>
                                    <input type="text" class="form-control" id="mediaName" name="name">
                                </div>
                                <button type="submit" class="btn btn-theme rounded-pill w-100">
                                    <i class="fas fa-upload me-2"></i>Upload
                                </button>
                            </form>
                        </div>
                    </div>
                    <div class="col-md-9">
                        <div class="d-flex justify-content-between align-items-center mb-3">
                            <h6>Existing Media</h6>
                            <div class="d-flex">
                                <input type="text" class="form-control rounded-pill me-2" id="mediaSearch" placeholder="Search media...">
                                <button class="btn btn-theme rounded-pill" onclick="loadMedia()">
                                    <i class="fas fa-search"></i>
                                </button>
                            </div>
                        </div>
                        
                        <div id="mediaLibraryContent" class="row">
                            <!-- Media items will be loaded here -->
                        </div>
                        
                        <div id="mediaLibraryPagination" class="d-flex justify-content-center mt-3">
                            <!-- Pagination will be loaded here -->
                        </div>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary rounded-pill" data-bs-dismiss="modal">
                    <i class="fas fa-times me-2"></i>Close
                </button>
            </div>
        </div>
    </div>
</div>
@endsection

@section('scripts')
<script>
    let currentMediaTarget = null;
    let currentCategoryId = null;
    
    $(document).ready(function() {
        // Initialize DataTable
        $('#categoriesTable').DataTable({
            "pageLength": 10,
            "lengthMenu": [[10, 25, 50, -1], [10, 25, 50, "All"]],
            "ordering": true,
            "searching": true,
            "info": true,
            "paging": true,
            "columnDefs": [
                { "orderable": false, "targets": [5] } // Disable sorting on Actions column
            ],
            "language": {
                "search": "Search:",
                "lengthMenu": "Show _MENU_ entries per page",
                "info": "Showing _START_ to _END_ of _TOTAL_ categories",
                "infoEmpty": "Showing 0 to 0 of 0 categories",
                "infoFiltered": "(filtered from _MAX_ total categories)",
                "paginate": {
                    "first": "First",
                    "last": "Last",
                    "next": "Next",
                    "previous": "Previous"
                }
            },
            "aoColumns": [
                null, // ID
                null, // Category
                null, // Description
                null, // Status
                null, // Created
                null  // Actions
            ],
            "preDrawCallback": function(settings) {
                // Ensure consistent column count
                if ($('#categoriesTable tbody tr').length === 0) {
                    $('#categoriesTable tbody').html('<tr><td colspan="6" class="text-center py-5"><div class="text-muted"><i class="fas fa-tags fa-2x mb-3"></i><p class="mb-0">No categories found</p><p class="small">Try creating a new category</p></div></td></tr>');
                }
            },
            "drawCallback": function(settings) {
                // Reinitialize tooltips after each draw
                $('[data-bs-toggle="tooltip"]').tooltip();
            }
        });
        // Adjust select width after DataTable initializes
        $('.dataTables_length select').css('width', '80px');
        
        // Category form submission
        $('#categoryForm').on('submit', function(e) {
            e.preventDefault();
            saveCategory();
        });
        
        // Subcategory form submission
        $('#subcategoryForm').on('submit', function(e) {
            e.preventDefault();
            saveSubCategory();
        });
        
        // Media upload form submission
        $('#mediaUploadForm').on('submit', function(e) {
            e.preventDefault();
            uploadMedia();
        });
        
        // Media search
        $('#mediaSearch').on('keyup', function() {
            if ($(this).val().length > 2 || $(this).val().length === 0) {
                loadMedia();
            }
        });
    });
    
    // Show category modal for creating new category
    function showCategoryModal() {
        $('#categoryModalLabel').text('Add New Category');
        $('#categoryForm')[0].reset();
        $('#categoryId').val('');
        $('#category-image-preview').html(`
            <div class="py-3">
                <i class="fas fa-image fa-2x text-muted mb-2"></i>
                <p class="text-muted mb-2">No image selected</p>
                <button type="button" class="btn btn-outline-primary btn-sm rounded-pill" onclick="openMediaLibrary('category')">
                    <i class="fas fa-folder-open me-1"></i> Select Image
                </button>
            </div>
        `);
        $('#categoryImageId').val('');
    }
    
    // Edit existing category
    function editCategory(id) {
        $.ajax({
            url: '/admin/categories/' + id,
            type: 'GET',
            success: function(data) {
                $('#categoryModalLabel').text('Edit Category');
                $('#categoryId').val(data.id);
                $('#categoryName').val(data.name);
                $('#categoryDescription').val(data.description);
                $('#categoryStatus').val(data.is_active ? '1' : '0');
                
                if (data.image) {
                    $('#category-image-preview').html(`
                        <div class="position-relative">
                            <img src="${data.image.url}" class="img-fluid rounded" alt="${data.name}" style="max-height: 200px; object-fit: contain;">
                            <button type="button" class="btn btn-danger btn-sm position-absolute top-0 end-0 m-2 rounded-circle" onclick="removeCategoryImage()">
                                <i class="fas fa-times"></i>
                            </button>
                        </div>
                    `);
                    $('#categoryImageId').val(data.image.id);
                } else {
                    $('#category-image-preview').html(`
                        <div class="py-3">
                            <i class="fas fa-image fa-2x text-muted mb-2"></i>
                            <p class="text-muted mb-2">No image selected</p>
                            <button type="button" class="btn btn-outline-primary btn-sm rounded-pill" onclick="openMediaLibrary('category')">
                                <i class="fas fa-folder-open me-1"></i> Select Image
                            </button>
                        </div>
                    `);
                    $('#categoryImageId').val('');
                }
                
                $('#categoryModal').modal('show');
            },
            error: function() {
                alert('Error loading category data.');
            }
        });
    }
    
    // Save category (create or update)
    function saveCategory() {
        const id = $('#categoryId').val();
        const url = id ? '/admin/categories/' + id : '/admin/categories';
        const method = id ? 'PUT' : 'POST';
        
        $.ajax({
            url: url,
            type: method,
            data: $('#categoryForm').serialize(),
            success: function(response) {
                if (response.success) {
                    $('#categoryModal').modal('hide');
                    location.reload();
                }
            },
            error: function(xhr) {
                if (xhr.responseJSON && xhr.responseJSON.errors) {
                    let errors = xhr.responseJSON.errors;
                    let errorMessages = '';
                    for (let field in errors) {
                        errorMessages += errors[field].join(', ') + '\n';
                    }
                    alert('Validation errors:\n' + errorMessages);
                } else {
                    alert('Error saving category.');
                }
            }
        });
    }
    
    // Delete category
    function deleteCategory(id) {
        if (confirm('Are you sure you want to delete this category? This will also delete all subcategories.')) {
            $.ajax({
                url: '/admin/categories/' + id,
                type: 'DELETE',
                data: {
                    _token: $('meta[name="csrf-token"]').attr('content'),
                    _method: 'DELETE'
                },
                success: function(response) {
                    if (response.success) {
                        location.reload();
                    }
                },
                error: function() {
                    alert('Error deleting category.');
                }
            });
        }
    }
    
    // Show subcategories for a category
    function showSubCategories(categoryId) {
        currentCategoryId = categoryId;
        loadSubCategories(categoryId, 1);
        $('#subcategoriesModal').modal('show');
    }
    
    // Load subcategories
    function loadSubCategories(categoryId, page = 1) {
        $.ajax({
            url: '/admin/categories/' + categoryId + '/subcategories?page=' + page,
            type: 'GET',
            success: function(data) {
                // Set parent category name
                $('#subcategoryParentName').text('Subcategories for ' + data.data[0]?.category?.name || 'Category');
                
                // Populate table
                let html = '';
                if (data.data.length > 0) {
                    data.data.forEach(function(subcategory) {
                        html += `
                            <tr>
                                <td>${subcategory.id}</td>
                                <td>
                                    <div class="d-flex align-items-center">
                                        ${subcategory.image ? 
                                            `<img src="${subcategory.image.url}" class="rounded me-3" width="40" height="40" alt="${subcategory.name}" onerror="this.onerror=null;this.parentElement.innerHTML='<div class=\\'bg-light rounded me-3 d-flex align-items-center justify-content-center\\' style=\\'width: 40px; height: 40px;\\'><i class=\\'fas fa-image text-muted\\'></i></div><div><div class=\\'fw-medium\\'>${subcategory.name}</div></div>';" loading="lazy">` :
                                            `<div class="bg-light rounded me-3 d-flex align-items-center justify-content-center" style="width: 40px; height: 40px;">
                                                <i class="fas fa-image text-muted"></i>
                                            </div>`
                                        }
                                        <div>
                                            <div class="fw-medium">${subcategory.name}</div>
                                        </div>
                                    </div>
                                </td>
                                <td>${subcategory.description ? subcategory.description.substring(0, 50) + (subcategory.description.length > 50 ? '...' : '') : 'N/A'}</td>
                                <td>
                                    ${subcategory.is_active ? 
                                        `<span class="badge bg-success-subtle text-success-emphasis rounded-pill px-3 py-2">Active</span>` :
                                        `<span class="badge bg-secondary-subtle text-secondary-emphasis rounded-pill px-3 py-2">Inactive</span>`
                                    }
                                </td>
                                <td>
                                    <div class="btn-group btn-group-sm" role="group">
                                        <button type="button" class="btn btn-outline-primary rounded-start-pill px-3" data-bs-toggle="modal" data-bs-target="#subcategoryModal" onclick="editSubCategory(${subcategory.id})">
                                            <i class="fas fa-edit"></i>
                                        </button>
                                        <button type="button" class="btn btn-outline-danger rounded-end-pill px-3" onclick="deleteSubCategory(${subcategory.id})">
                                            <i class="fas fa-trash"></i>
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        `;
                    });
                } else {
                    html = `
                        <tr>
                            <td colspan="5" class="text-center py-5">
                                <div class="text-muted">
                                    <i class="fas fa-list fa-2x mb-3"></i>
                                    <p class="mb-0">No subcategories found</p>
                                    <p class="small">Try creating a new subcategory</p>
                                </div>
                            </td>
                        </tr>
                    `;
                }
                
                $('#subcategoriesTableBody').html(html);
                
                // Populate pagination
                if (data.last_page > 1) {
                    let paginationHtml = `
                        <nav>
                            <ul class="pagination justify-content-center mb-0">
                                ${data.prev_page_url ? 
                                    `<li class="page-item"><a class="page-link rounded-pill" href="javascript:void(0)" onclick="loadSubCategories(${categoryId}, ${data.current_page - 1})">Previous</a></li>` :
                                    `<li class="page-item disabled"><span class="page-link rounded-pill">Previous</span></li>`
                                }
                    `;
                    
                    for (let i = 1; i <= data.last_page; i++) {
                        paginationHtml += `
                            <li class="page-item ${i === data.current_page ? 'active' : ''}">
                                <a class="page-link rounded-pill" href="javascript:void(0)" onclick="loadSubCategories(${categoryId}, ${i})">${i}</a>
                            </li>
                        `;
                    }
                    
                    paginationHtml += `
                                ${data.next_page_url ? 
                                    `<li class="page-item"><a class="page-link rounded-pill" href="javascript:void(0)" onclick="loadSubCategories(${categoryId}, ${data.current_page + 1})">Next</a></li>` :
                                    `<li class="page-item disabled"><span class="page-link rounded-pill">Next</span></li>`
                                }
                            </ul>
                        </nav>
                    `;
                    
                    $('#subcategoriesPagination').html(paginationHtml);
                } else {
                    $('#subcategoriesPagination').html('');
                }
            },
            error: function() {
                alert('Error loading subcategories.');
            }
        });
    }
    
    // Show subcategory modal for creating new subcategory
    function showSubCategoryModal() {
        $('#subcategoryModalLabel').text('Add New Subcategory');
        $('#subcategoryForm')[0].reset();
        $('#subcategoryId').val('');
        $('#subcategoryCategoryId').val(currentCategoryId);
        $('#subcategory-image-preview').html(`
            <div class="py-3">
                <i class="fas fa-image fa-2x text-muted mb-2"></i>
                <p class="text-muted mb-2">No image selected</p>
                <button type="button" class="btn btn-outline-primary btn-sm rounded-pill" onclick="openMediaLibrary('subcategory')">
                    <i class="fas fa-folder-open me-1"></i> Select Image
                </button>
            </div>
        `);
        $('#subcategoryImageId').val('');
    }
    
    // Edit existing subcategory
    function editSubCategory(id) {
        $.ajax({
            url: '/admin/subcategories/' + id,
            type: 'GET',
            success: function(data) {
                $('#subcategoryModalLabel').text('Edit Subcategory');
                $('#subcategoryId').val(data.id);
                $('#subcategoryCategoryId').val(data.category_id);
                $('#subcategoryName').val(data.name);
                $('#subcategoryDescription').val(data.description);
                $('#subcategoryStatus').val(data.is_active ? '1' : '0');
                
                if (data.image) {
                    $('#subcategory-image-preview').html(`
                        <div class="position-relative">
                            <img src="${data.image.url}" class="img-fluid rounded" alt="${data.name}" style="max-height: 200px; object-fit: contain;">
                            <button type="button" class="btn btn-danger btn-sm position-absolute top-0 end-0 m-2 rounded-circle" onclick="removeSubcategoryImage()">
                                <i class="fas fa-times"></i>
                            </button>
                        </div>
                    `);
                    $('#subcategoryImageId').val(data.image.id);
                } else {
                    $('#subcategory-image-preview').html(`
                        <div class="py-3">
                            <i class="fas fa-image fa-2x text-muted mb-2"></i>
                            <p class="text-muted mb-2">No image selected</p>
                            <button type="button" class="btn btn-outline-primary btn-sm rounded-pill" onclick="openMediaLibrary('subcategory')">
                                <i class="fas fa-folder-open me-1"></i> Select Image
                            </button>
                        </div>
                    `);
                    $('#subcategoryImageId').val('');
                }
                
                // Show the modal
                $('#subcategoryModal').modal('show');
            },
            error: function() {
                alert('Error loading subcategory data.');
            }
        });
    }
    
    // Save subcategory (create or update)
    function saveSubCategory() {
        const id = $('#subcategoryId').val();
        const url = id ? '/admin/subcategories/' + id : '/admin/subcategories';
        const method = id ? 'PUT' : 'POST';
        
        $.ajax({
            url: url,
            type: method,
            data: $('#subcategoryForm').serialize(),
            success: function(response) {
                if (response.success) {
                    $('#subcategoryModal').modal('hide');
                    loadSubCategories(currentCategoryId);
                }
            },
            error: function(xhr) {
                if (xhr.responseJSON && xhr.responseJSON.errors) {
                    let errors = xhr.responseJSON.errors;
                    let errorMessages = '';
                    for (let field in errors) {
                        errorMessages += errors[field].join(', ') + '\n';
                    }
                    alert('Validation errors:\n' + errorMessages);
                } else {
                    alert('Error saving subcategory.');
                }
            }
        });
    }
    
    // Delete subcategory
    function deleteSubCategory(id) {
        if (confirm('Are you sure you want to delete this subcategory?')) {
            $.ajax({
                url: '/admin/subcategories/' + id,
                type: 'DELETE',
                data: {
                    _token: $('meta[name="csrf-token"]').attr('content'),
                    _method: 'DELETE'
                },
                success: function(response) {
                    if (response.success) {
                        loadSubCategories(currentCategoryId);
                    }
                },
                error: function() {
                    alert('Error deleting subcategory.');
                }
            });
        }
    }
    
    // Open media library
    function openMediaLibrary(target) {
        currentMediaTarget = target;
        loadMedia();
        $('#mediaLibraryModal').modal('show');
    }
    
    // Load media items
    function loadMedia(page = 1) {
        const search = $('#mediaSearch').val();
        const params = new URLSearchParams();
        if (search) params.append('search', search);
        params.append('page', page);
        
        $.ajax({
            url: '/admin/media?' + params.toString(),
            type: 'GET',
            success: function(data) {
                let html = '';
                if (data.data.length > 0) {
                    data.data.forEach(function(media) {
                        html += `
                            <div class="col-md-3 mb-3">
                                <div class="border rounded-3 p-2 media-item" onclick="selectMedia(${media.id}, '${media.url}', '${currentMediaTarget}')">
                                    ${media.mime_type.startsWith('image/') ? 
                                        `<img src="${media.url}" class="img-fluid rounded" alt="${media.name}" style="height: 120px; object-fit: cover;">` :
                                        `<div class="d-flex align-items-center justify-content-center" style="height: 120px;">
                                            <i class="fas fa-file fa-2x text-muted"></i>
                                        </div>`
                                    }
                                    <div class="mt-2 text-truncate small">${media.name}</div>
                                </div>
                            </div>
                        `;
                    });
                } else {
                    html = `
                        <div class="col-12 text-center py-5">
                            <i class="fas fa-image fa-2x text-muted mb-3"></i>
                            <p class="text-muted">No media found</p>
                        </div>
                    `;
                }
                
                $('#mediaLibraryContent').html(html);
                
                // Populate pagination
                if (data.last_page > 1) {
                    let paginationHtml = `
                        <nav>
                            <ul class="pagination justify-content-center mb-0">
                                ${data.prev_page_url ? 
                                    `<li class="page-item"><a class="page-link rounded-pill" href="javascript:void(0)" onclick="loadMedia(${data.current_page - 1})">Previous</a></li>` :
                                    `<li class="page-item disabled"><span class="page-link rounded-pill">Previous</span></li>`
                                }
                    `;
                    
                    for (let i = 1; i <= data.last_page; i++) {
                        paginationHtml += `
                            <li class="page-item ${i === data.current_page ? 'active' : ''}">
                                <a class="page-link rounded-pill" href="javascript:void(0)" onclick="loadMedia(${i})">${i}</a>
                            </li>
                        `;
                    }
                    
                    paginationHtml += `
                                ${data.next_page_url ? 
                                    `<li class="page-item"><a class="page-link rounded-pill" href="javascript:void(0)" onclick="loadMedia(${data.current_page + 1})">Next</a></li>` :
                                    `<li class="page-item disabled"><span class="page-link rounded-pill">Next</span></li>`
                                }
                            </ul>
                        </nav>
                    `;
                    
                    $('#mediaLibraryPagination').html(paginationHtml);
                } else {
                    $('#mediaLibraryPagination').html('');
                }
            },
            error: function() {
                alert('Error loading media.');
            }
        });
    }
    
    // Select media
    function selectMedia(id, url, target) {
        if (target === 'category') {
            $('#category-image-preview').html(`
                <div class="position-relative">
                    <img src="${url}" class="img-fluid rounded" alt="Selected image" style="max-height: 200px; object-fit: contain;">
                    <button type="button" class="btn btn-danger btn-sm position-absolute top-0 end-0 m-2 rounded-circle" onclick="removeCategoryImage()">
                        <i class="fas fa-times"></i>
                    </button>
                </div>
            `);
            $('#categoryImageId').val(id);
        } else if (target === 'subcategory') {
            $('#subcategory-image-preview').html(`
                <div class="position-relative">
                    <img src="${url}" class="img-fluid rounded" alt="Selected image" style="max-height: 200px; object-fit: contain;">
                    <button type="button" class="btn btn-danger btn-sm position-absolute top-0 end-0 m-2 rounded-circle" onclick="removeSubcategoryImage()">
                        <i class="fas fa-times"></i>
                    </button>
                </div>
            `);
            $('#subcategoryImageId').val(id);
        }
        
        $('#mediaLibraryModal').modal('hide');
    }
    
    // Remove category image
    function removeCategoryImage() {
        $('#category-image-preview').html(`
            <div class="py-3">
                <i class="fas fa-image fa-2x text-muted mb-2"></i>
                <p class="text-muted mb-2">No image selected</p>
                <button type="button" class="btn btn-outline-theme btn-sm rounded-pill" onclick="openMediaLibrary('category')">
                    <i class="fas fa-folder-open me-1"></i> Select Image
                </button>
            </div>
        `);
        $('#categoryImageId').val('');
    }
    
    // Remove subcategory image
    function removeSubcategoryImage() {
        $('#subcategory-image-preview').html(`
            <div class="py-3">
                <i class="fas fa-image fa-2x text-muted mb-2"></i>
                <p class="text-muted mb-2">No image selected</p>
                <button type="button" class="btn btn-outline-theme btn-sm rounded-pill" onclick="openMediaLibrary('subcategory')">
                    <i class="fas fa-folder-open me-1"></i> Select Image
                </button>
            </div>
        `);
        $('#subcategoryImageId').val('');
    }
    
    // Upload media
    function uploadMedia() {
        const formData = new FormData($('#mediaUploadForm')[0]);
        
        $.ajax({
            url: '/admin/media',
            type: 'POST',
            data: formData,
            processData: false,
            contentType: false,
            success: function(response) {
                if (response.success) {
                    loadMedia();
                    $('#mediaUploadForm')[0].reset();
                }
            },
            error: function(xhr) {
                if (xhr.responseJSON && xhr.responseJSON.errors) {
                    let errors = xhr.responseJSON.errors;
                    let errorMessages = '';
                    for (let field in errors) {
                        errorMessages += errors[field].join(', ') + '\n';
                    }
                    alert('Validation errors:\n' + errorMessages);
                } else {
                    alert('Error uploading media.');
                }
            }
        });
    }
</script>
@endsection

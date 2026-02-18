@extends('admin.layouts.app')

@section('title', 'Product Attributes')

@section('styles')
<style>
    /* DataTables Custom Styling */
    #attributesTable_wrapper .dataTables_filter {
        float: right;
        text-align: right;
    }
    
    #attributesTable_wrapper .dataTables_filter input {
        margin-left: 0.5em;
        border: 1px solid #dee2e6;
        border-radius: 0.25rem;
        padding: 0.375rem 0.75rem;
    }
    
    #attributesTable_wrapper .dataTables_length select {
        border: 1px solid #dee2e6;
        border-radius: 0.25rem;
        padding: 0.375rem 2rem 0.375rem 0.75rem;
        margin: 0 0.5em;
    }
    
    #attributesTable_wrapper .dataTables_info {
        padding-top: 0.85em;
    }
    
    #attributesTable_wrapper .dataTables_paginate {
        padding-top: 0.5em;
    }
    
    #attributesTable thead th {
        background-color: #f8f9fa;
        font-weight: 600;
        border-bottom: 2px solid #dee2e6;
    }
    
    #attributesTable tbody tr:hover {
        background-color: #f8f9fa;
    }
    
    .btn-group-sm > .btn {
        padding: 0.25rem 0.5rem;
        font-size: 0.875rem;
    }
    
    .table-responsive {
        border-radius: 0.25rem;
    }
    
    /* Filter section styling */
    .form-label.small {
        font-weight: 600;
        color: #495057;
        margin-bottom: 0.25rem;
    }
</style>
@endsection

@section('content')
<div class="container-fluid h-100">
    <div class="row h-100">
        @include('admin.layouts.sidebar')
        
        <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4 main-content">
            @include('admin.layouts.header', ['pageTitle' => 'Product Attributes'])
            
            <div class="pt-4 pb-2 mb-3">
<div class="container-fluid">
    <div class="row mb-4">
        <div class="col-12">
            <div class="d-flex flex-column flex-md-row justify-content-between align-items-start align-items-md-center gap-2 gap-md-0">
                <h1 class="h4 h3-md mb-2 mb-md-0">Product Attributes</h1>
                <a href="{{ route('admin.attributes.create') }}" class="btn btn-sm btn-md-normal btn-primary">
                    <i class="fas fa-plus me-1"></i><span class="d-none d-sm-inline">Add New Attribute</span><span class="d-sm-none">Add</span>
                </a>
            </div>
        </div>
    </div>

    @if(session('success'))
        <div class="alert alert-success alert-dismissible fade show" role="alert">
            {{ session('success') }}
            <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
        </div>
    @endif

    <div class="card">
        <div class="card-body">
            <!-- Filters Section -->
            <div class="row mb-3 g-3">
                <div class="col-md-3">
                    <label class="form-label small">Status Filter</label>
                    <select id="statusFilter" class="form-select form-select-sm">
                        <option value="">All Status</option>
                        <option value="Active">Active</option>
                        <option value="Inactive">Inactive</option>
                    </select>
                </div>
                <div class="col-md-3">
                    <label class="form-label small">Values Count</label>
                    <select id="valuesFilter" class="form-select form-select-sm">
                        <option value="">All</option>
                        <option value="0">0 values</option>
                        <option value="1-5">1-5 values</option>
                        <option value="6-10">6-10 values</option>
                        <option value="11+">11+ values</option>
                    </select>
                </div>
                <div class="col-md-6 d-flex align-items-end">
                    <button type="button" id="resetFilters" class="btn btn-sm btn-outline-secondary">
                        <i class="fas fa-redo me-1"></i> Reset Filters
                    </button>
                </div>
            </div>

            <div class="table-responsive">
                <table id="attributesTable" class="table table-hover table-striped">
                    <thead>
                        <tr>
                            <th style="width: 60px;">Sr. No</th>
                            <th>Name</th>
                            <th>Slug</th>
                            <th>Values</th>
                            <th>Sort Order</th>
                            <th>Status</th>
                            <th style="width: 180px;">Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        @foreach($attributes as $index => $attribute)
                            <tr>
                                <td>{{ $loop->iteration }}</td>
                                <td><strong>{{ $attribute->name }}</strong></td>
                                <td><code>{{ $attribute->slug }}</code></td>
                                <td data-order="{{ $attribute->values->count() }}">
                                    <span class="badge bg-info-subtle text-info-emphasis rounded-pill px-3 py-2">{{ $attribute->values->count() }} values</span>
                                </td>
                                <td>{{ $attribute->sort_order }}</td>
                                <td>
                                    @if($attribute->is_active)
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
                                    <div class="btn-group btn-group-sm" role="group">
                                        <a href="{{ route('admin.attributes.edit', $attribute) }}" 
                                           class="btn btn-outline-primary rounded-start-pill px-3" 
                                           title="Edit">
                                            <i class="fas fa-edit"></i>
                                        </a>
                                        <button type="button" 
                                                class="btn btn-outline-danger rounded-end-pill px-3 delete-attribute" 
                                                data-id="{{ $attribute->id }}"
                                                data-name="{{ $attribute->name }}"
                                                title="Delete">
                                            <i class="fas fa-trash"></i>
                                        </button>
                                    </div>
                                </td>
                            </tr>
                        @endforeach
                    </tbody>
                </table>
            </div>
        </div>
    </div>
</div>

<!-- Delete Confirmation Modal -->
<div class="modal fade" id="deleteModal" tabindex="-1" aria-labelledby="deleteModalLabel" aria-hidden="true">
    <div class="modal-dialog">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="deleteModalLabel">Confirm Delete</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body">
                <p>Are you sure you want to delete the attribute <strong id="deleteAttributeName"></strong>?</p>
                <p class="text-danger mb-0"><small><i class="fas fa-exclamation-triangle me-1"></i>This action cannot be undone.</small></p>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Cancel</button>
                <form id="deleteForm" method="POST" style="display: inline;">
                    @csrf
                    @method('DELETE')
                    <button type="submit" class="btn btn-danger">Delete</button>
                </form>
            </div>
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
$(document).ready(function() {
    // Initialize DataTable
    var table = $('#attributesTable').DataTable({
        "pageLength": 25,
        "lengthMenu": [[10, 25, 50, 100, -1], [10, 25, 50, 100, "All"]],
        "order": [[4, "asc"]], // Default sort by Sort Order column
        "columnDefs": [
            {
                "targets": 0, // Sr. No column
                "orderable": false,
                "searchable": false
            },
            {
                "targets": 6, // Actions column
                "orderable": false,
                "searchable": false
            }
        ],
        "language": {
            "search": "Search:",
            "lengthMenu": "Show _MENU_ entries",
            "info": "Showing _START_ to _END_ of _TOTAL_ attributes",
            "infoEmpty": "Showing 0 to 0 of 0 attributes",
            "infoFiltered": "(filtered from _MAX_ total attributes)",
            "zeroRecords": "No matching attributes found",
            "emptyTable": "No attributes available"
        },
        "drawCallback": function(settings) {
            // Update serial numbers after each draw
            var api = this.api();
            var startIndex = api.context[0]._iDisplayStart;
            api.column(0, {page: 'current'}).nodes().each(function(cell, i) {
                cell.innerHTML = startIndex + i + 1;
            });
        }
    });

    // Status Filter
    $('#statusFilter').on('change', function() {
        var value = $(this).val();
        if (value === '') {
            table.column(5).search('').draw();
        } else {
            table.column(5).search('^' + value + '$', true, false).draw();
        }
    });

    // Values Count Filter
    $('#valuesFilter').on('change', function() {
        var value = $(this).val();
        table.column(3).search('').draw(); // Clear first
        
        if (value !== '') {
            $.fn.dataTable.ext.search.push(
                function(settings, data, dataIndex) {
                    var valuesCount = parseInt($(table.row(dataIndex).node()).find('td:eq(3)').data('order'));
                    
                    if (value === '0') {
                        return valuesCount === 0;
                    } else if (value === '1-5') {
                        return valuesCount >= 1 && valuesCount <= 5;
                    } else if (value === '6-10') {
                        return valuesCount >= 6 && valuesCount <= 10;
                    } else if (value === '11+') {
                        return valuesCount >= 11;
                    }
                    return true;
                }
            );
        } else {
            $.fn.dataTable.ext.search.pop();
        }
        table.draw();
    });

    // Reset Filters
    $('#resetFilters').on('click', function() {
        $('#statusFilter').val('').trigger('change');
        $('#valuesFilter').val('');
        $.fn.dataTable.ext.search.pop();
        table.search('').columns().search('').draw();
    });

    // Delete Attribute Handler
    $('.delete-attribute').on('click', function() {
        var attributeId = $(this).data('id');
        var attributeName = $(this).data('name');
        
        $('#deleteAttributeName').text(attributeName);
        $('#deleteForm').attr('action', '{{ route("admin.attributes.index") }}/' + attributeId);
        
        var deleteModal = new bootstrap.Modal(document.getElementById('deleteModal'));
        deleteModal.show();
    });

    // Handle delete form submission
    $('#deleteForm').on('submit', function(e) {
        e.preventDefault();
        
        var form = $(this);
        var url = form.attr('action');
        
        $.ajax({
            url: url,
            type: 'POST',
            data: form.serialize(),
            success: function(response) {
                // Close modal
                bootstrap.Modal.getInstance(document.getElementById('deleteModal')).hide();
                
                // Show success message
                var alertHtml = '<div class="alert alert-success alert-dismissible fade show" role="alert">' +
                    'Attribute deleted successfully.' +
                    '<button type="button" class="btn-close" data-bs-dismiss="alert"></button>' +
                    '</div>';
                
                $('.container-fluid > .row').after(alertHtml);
                
                // Reload page after short delay
                setTimeout(function() {
                    window.location.reload();
                }, 1000);
            },
            error: function(xhr) {
                // Close modal
                bootstrap.Modal.getInstance(document.getElementById('deleteModal')).hide();
                
                // Show error message
                var errorMsg = xhr.responseJSON && xhr.responseJSON.message 
                    ? xhr.responseJSON.message 
                    : 'Error deleting attribute.';
                
                var alertHtml = '<div class="alert alert-danger alert-dismissible fade show" role="alert">' +
                    errorMsg +
                    '<button type="button" class="btn-close" data-bs-dismiss="alert"></button>' +
                    '</div>';
                
                $('.container-fluid > .row').after(alertHtml);
            }
        });
    });
});
</script>
@endsection

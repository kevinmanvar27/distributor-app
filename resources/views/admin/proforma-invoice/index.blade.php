@extends('admin.layouts.app')

@section('title', 'Proforma Invoices - ' . setting('site_title', 'Admin Panel'))

@push('styles')
<style>
    /* Summary Cards Animation */
    .summary-card-enter {
        opacity: 0;
        transform: translateY(20px);
    }
    
    /* Filter Section Styling */
    .filter-section {
        background: linear-gradient(135deg, #f8f9fa 0%, #e9ecef 100%);
        border-radius: 10px;
    }
    
    /* Active Filter Badges */
    .filter-badge {
        font-size: 0.875rem;
        padding: 0.5rem 0.75rem;
        border-radius: 20px;
        transition: all 0.3s ease;
    }
    
    .filter-badge:hover {
        transform: scale(1.05);
    }
    
    .filter-badge a {
        font-weight: bold;
        font-size: 1.2rem;
        line-height: 1;
    }
    
    /* Summary Cards Hover Effect */
    .summary-card {
        transition: transform 0.3s ease, box-shadow 0.3s ease;
    }
    
    .summary-card:hover {
        transform: translateY(-5px);
        box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.15) !important;
    }
    
    /* User Summary Table Styling */
    #userSummaryTable tbody tr {
        transition: background-color 0.2s ease;
    }
    
    #userSummaryTable tbody tr:hover {
        background-color: rgba(0, 123, 255, 0.05);
    }
</style>
@endpush

@section('content')
<div class="container-fluid h-100">
    <div class="row h-100">
        @include('admin.layouts.sidebar')
        
        <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4 main-content">
            @include('admin.layouts.header', ['pageTitle' => 'Proforma Invoices'])
            
            <div class="pt-4 pb-2 mb-3">
                <!-- Summary Cards -->
                <div class="row g-3 mb-4">
                    <div class="col-xl-3 col-md-6">
                        <div class="card border-0 shadow-sm h-100 summary-card">
                            <div class="card-body">
                                <div class="d-flex align-items-center">
                                    <div class="flex-shrink-0">
                                        <div class="bg-primary rounded-circle p-3" style="background-color: rgba(13, 110, 253, 0.2) !important;">
                                            <i class="fas fa-file-invoice text-primary fa-2x"></i>
                                        </div>
                                    </div>
                                    <div class="flex-grow-1 ms-3">
                                        <h6 class="text-muted mb-1 small">Total Invoices</h6>
                                        <h3 class="mb-0 fw-bold">{{ $summary['total_invoices'] }}</h3>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-md-6">
                        <div class="card border-0 shadow-sm h-100 summary-card">
                            <div class="card-body">
                                <div class="d-flex align-items-center">
                                    <div class="flex-shrink-0">
                                        <div class="bg-success rounded-circle p-3" style="background-color: rgba(25, 135, 84, 0.2) !important;">
                                            <i class="fas fa-rupee-sign text-success fa-2x"></i>
                                        </div>
                                    </div>
                                    <div class="flex-grow-1 ms-3">
                                        <h6 class="text-muted mb-1 small">Total Amount</h6>
                                        <h3 class="mb-0 fw-bold">₹{{ number_format($summary['total_amount'], 2) }}</h3>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-md-6">
                        <div class="card border-0 shadow-sm h-100 summary-card">
                            <div class="card-body">
                                <div class="d-flex align-items-center">
                                    <div class="flex-shrink-0">
                                        <div class="bg-info rounded-circle p-3" style="background-color: rgba(13, 202, 240, 0.2) !important;">
                                            <i class="fas fa-check-circle text-info fa-2x"></i>
                                        </div>
                                    </div>
                                    <div class="flex-grow-1 ms-3">
                                        <h6 class="text-muted mb-1 small">Approved</h6>
                                        <h3 class="mb-0 fw-bold">{{ $summary['approved_count'] }}</h3>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                    <div class="col-xl-3 col-md-6">
                        <div class="card border-0 shadow-sm h-100 summary-card">
                            <div class="card-body">
                                <div class="d-flex align-items-center">
                                    <div class="flex-shrink-0">
                                        <div class="bg-warning rounded-circle p-3" style="background-color: rgba(255, 193, 7, 0.2) !important;">
                                            <i class="fas fa-truck text-warning fa-2x"></i>
                                        </div>
                                    </div>
                                    <div class="flex-grow-1 ms-3">
                                        <h6 class="text-muted mb-1 small">Delivered</h6>
                                        <h3 class="mb-0 fw-bold">{{ $summary['delivered_count'] }}</h3>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="row">
                    <div class="col-12">
                        <div class="card border-0 shadow-sm">
                            <div class="card-header bg-white border-0 py-3">
                                <div class="d-flex flex-column flex-md-row justify-content-between align-items-start align-items-md-center gap-2 gap-md-0">
                                    <div class="mb-2 mb-md-0">
                                        <h4 class="card-title mb-0 fw-bold h5 h4-md">Invoices</h4>
                                        <p class="mb-0 text-muted small">Manage user invoices</p>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="card-body">
                                <!-- Filters -->
                                <div class="card bg-light border-0 mb-4 filter-section">
                                    <div class="card-body">
                                        <form method="GET" action="{{ route('admin.proforma-invoice.index') }}" id="filterForm">
                                            <div class="row g-3">
                                                <div class="col-md-3">
                                                    <label for="client_id" class="form-label small fw-semibold">Client</label>
                                                    <select name="client_id" id="client_id" class="form-select">
                                                        <option value="">All Clients</option>
                                                        @foreach($clients as $client)
                                                            <option value="{{ $client->id }}" {{ request('client_id') == $client->id ? 'selected' : '' }}>
                                                                {{ $client->name }}
                                                            </option>
                                                        @endforeach
                                                    </select>
                                                </div>
                                                <div class="col-md-2">
                                                    <label for="status" class="form-label small fw-semibold">Status</label>
                                                    <select name="status" id="status" class="form-select">
                                                        <option value="">All Status</option>
                                                        @foreach($statusOptions as $statusOption)
                                                            <option value="{{ $statusOption }}" {{ request('status') == $statusOption ? 'selected' : '' }}>
                                                                {{ $statusOption }}
                                                            </option>
                                                        @endforeach
                                                    </select>
                                                </div>
                                                <div class="col-md-2">
                                                    <label for="date_from" class="form-label small fw-semibold">Date From</label>
                                                    <input type="date" name="date_from" id="date_from" class="form-control" value="{{ request('date_from') }}">
                                                </div>
                                                <div class="col-md-2">
                                                    <label for="date_to" class="form-label small fw-semibold">Date To</label>
                                                    <input type="date" name="date_to" id="date_to" class="form-control" value="{{ request('date_to') }}">
                                                </div>
                                                <div class="col-md-3">
                                                    <label class="form-label small fw-semibold d-block">&nbsp;</label>
                                                    <button type="submit" class="btn btn-primary me-2">
                                                        <i class="fas fa-filter me-1"></i> Filter
                                                    </button>
                                                    <a href="{{ route('admin.proforma-invoice.index') }}" class="btn btn-outline-secondary">
                                                        <i class="fas fa-redo me-1"></i> Reset
                                                    </a>
                                                </div>
                                            </div>
                                        </form>
                                    </div>
                                </div>
                                
                                <!-- Active Filters Display -->
                                @if(request()->hasAny(['client_id', 'status', 'date_from', 'date_to']))
                                    <div class="mb-3">
                                        <div class="d-flex flex-wrap gap-2 align-items-center">
                                            <span class="text-muted small fw-semibold">Active Filters:</span>
                                            @if(request('client_id'))
                                                @php
                                                    $selectedClient = $clients->firstWhere('id', request('client_id'));
                                                @endphp
                                                @if($selectedClient)
                                                    <span class="badge bg-primary filter-badge">
                                                        Client: {{ $selectedClient->name }}
                                                        <a href="{{ route('admin.proforma-invoice.index', array_filter(request()->except('client_id'))) }}" class="text-white ms-1" style="text-decoration: none;">×</a>
                                                    </span>
                                                @endif
                                            @endif
                                            @if(request('status'))
                                                <span class="badge bg-primary filter-badge">
                                                    Status: {{ request('status') }}
                                                    <a href="{{ route('admin.proforma-invoice.index', array_filter(request()->except('status'))) }}" class="text-white ms-1" style="text-decoration: none;">×</a>
                                                </span>
                                            @endif
                                            @if(request('date_from'))
                                                <span class="badge bg-primary filter-badge">
                                                    From: {{ request('date_from') }}
                                                    <a href="{{ route('admin.proforma-invoice.index', array_filter(request()->except('date_from'))) }}" class="text-white ms-1" style="text-decoration: none;">×</a>
                                                </span>
                                            @endif
                                            @if(request('date_to'))
                                                <span class="badge bg-primary filter-badge">
                                                    To: {{ request('date_to') }}
                                                    <a href="{{ route('admin.proforma-invoice.index', array_filter(request()->except('date_to'))) }}" class="text-white ms-1" style="text-decoration: none;">×</a>
                                                </span>
                                            @endif
                                            <a href="{{ route('admin.proforma-invoice.index') }}" class="badge bg-danger text-decoration-none filter-badge">
                                                Clear All
                                            </a>
                                        </div>
                                    </div>
                                @endif
                                @if(session('success'))
                                    <div class="alert alert-success alert-dismissible fade show rounded-pill px-4 py-3" role="alert">
                                        <i class="fas fa-check-circle me-2"></i>{{ session('success') }}
                                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                                    </div>
                                @endif
                                
                                @if($proformaInvoices->count() > 0)
                                    <div class="table-responsive">
                                        <table class="table table-hover" id="proformaInvoicesTable">
                                            <thead class="table-light">
                                                <tr>
                                                    <th>#</th>
                                                    <th>Invoice #</th>
                                                    <th>Customer</th>
                                                    <th>Date</th>
                                                    <th>Amount</th>
                                                    <th>Status</th>
                                                    <th>Actions</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                @foreach($proformaInvoices as $index => $invoice)
                                                <tr>
                                                    <td>{{ $index + 1 }}</td>
                                                    <td>{{ $invoice->invoice_number }}</td>
                                                    <td>
                                                        @if($invoice->user)
                                                            <div class="d-flex align-items-center gap-1">
                                                                {{ $invoice->user->name }}
                                                                @if($invoice->user->trashed())
                                                                    <span class="badge bg-danger" style="font-size: 0.65rem;">Deleted</span>
                                                                @endif
                                                            </div>
                                                        @else
                                                            <span class="text-muted">Unknown User</span>
                                                        @endif
                                                    </td>
                                                    <td>{{ $invoice->created_at->format('Y-m-d') }}</td>
                                                    <td>₹{{ number_format($invoice->total_amount, 2) }}</td>
                                                    <td>
                                                        @switch($invoice->status)
                                                            @case('Draft')
                                                                <span class="badge bg-secondary">Draft</span>
                                                                @break
                                                            @case('Approved')
                                                                <span class="badge bg-success">Approved</span>
                                                                @break
                                                            @case('Dispatch')
                                                                <span class="badge bg-info">Dispatch</span>
                                                                @break
                                                            @case('Out for Delivery')
                                                                <span class="badge bg-primary">Out for Delivery</span>
                                                                @break
                                                            @case('Delivered')
                                                                <span class="badge bg-success">Delivered</span>
                                                                @break
                                                            @case('Return')
                                                                <span class="badge bg-danger">Return</span>
                                                                @break
                                                        @endswitch
                                                    </td>
                                                    <td>
                                                        <div class="btn-group btn-group-sm" role="group">
                                                            <a href="{{ route('admin.proforma-invoice.show', $invoice->id) }}" class="btn btn-outline-primary rounded-start-pill px-3">
                                                                <i class="fas fa-edit"></i>
                                                            </a>
                                                            <form action="{{ route('admin.proforma-invoice.destroy', $invoice->id) }}" method="POST" class="d-inline">
                                                                @csrf
                                                                @method('DELETE')
                                                                <button type="submit" class="btn btn-outline-danger rounded-end-pill px-3" onclick="return confirm('Are you sure you want to delete this invoice?')">
                                                                    <i class="fas fa-trash"></i>
                                                                </button>
                                                            </form>
                                                        </div>
                                                    </td>
                                                </tr>
                                                @endforeach
                                            </tbody>
                                        </table>
                                    </div>
                                @else
                                    <div class="text-center py-5">
                                        <i class="fas fa-file-invoice fa-3x text-muted mb-3"></i>
                                        <h5 class="mb-2">No proforma invoices found</h5>
                                        <p class="mb-0 text-muted">Proforma invoices will appear here once generated by users.</p>
                                    </div>
                                @endif
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- User Summary Section -->
                @if($userSummary->count() > 0)
                <div class="row mt-4">
                    <div class="col-12">
                        <div class="card border-0 shadow-sm">
                            <div class="card-header bg-white border-0 py-3">
                                <h5 class="card-title mb-0 fw-bold">Top Clients Summary</h5>
                                <p class="mb-0 text-muted small">Top 10 clients by invoice count</p>
                            </div>
                            <div class="card-body">
                                <div class="table-responsive">
                                    <table class="table table-hover" id="userSummaryTable">
                                        <thead class="table-light">
                                            <tr>
                                                <th>#</th>
                                                <th>Client Name</th>
                                                <th>Email</th>
                                                <th>Total Invoices</th>
                                                <th>Total Amount</th>
                                                <th>Average Amount</th>
                                                <th>Draft</th>
                                                <th>Approved</th>
                                                <th>Delivered</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            @foreach($userSummary as $index => $user)
                                            <tr>
                                                <td>{{ $index + 1 }}</td>
                                                <td>
                                                    <strong>{{ $user['user_name'] }}</strong>
                                                </td>
                                                <td>{{ $user['user_email'] }}</td>
                                                <td>
                                                    <span class="badge bg-primary">{{ $user['invoice_count'] }}</span>
                                                </td>
                                                <td>₹{{ number_format($user['total_amount'], 2) }}</td>
                                                <td>₹{{ number_format($user['average_amount'], 2) }}</td>
                                                <td>
                                                    @if($user['draft_count'] > 0)
                                                        <span class="badge bg-secondary">{{ $user['draft_count'] }}</span>
                                                    @else
                                                        <span class="text-muted">-</span>
                                                    @endif
                                                </td>
                                                <td>
                                                    @if($user['approved_count'] > 0)
                                                        <span class="badge bg-success">{{ $user['approved_count'] }}</span>
                                                    @else
                                                        <span class="text-muted">-</span>
                                                    @endif
                                                </td>
                                                <td>
                                                    @if($user['delivered_count'] > 0)
                                                        <span class="badge bg-info">{{ $user['delivered_count'] }}</span>
                                                    @else
                                                        <span class="text-muted">-</span>
                                                    @endif
                                                </td>
                                            </tr>
                                            @endforeach
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                @endif
            </div>
            
            @include('admin.layouts.footer')
        </main>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    // Handle status form submission
    document.querySelectorAll('.status-form').forEach(form => {
        form.addEventListener('submit', function(e) {
            e.preventDefault();
            
            const select = form.querySelector('.status-select');
            const selectedStatus = select.value;
            const currentStatus = select.options[select.selectedIndex].text;
            
            this.submit();
        });
        
        // Auto-submit when status changes
        const select = form.querySelector('.status-select');
        select.addEventListener('change', function() {
            form.dispatchEvent(new Event('submit'));
        });
    });
    
    // Initialize DataTable
    $('#proformaInvoicesTable').DataTable({
        "pageLength": 25,
        "ordering": true,
        "info": true,
        "responsive": true,
        "order": [[3, 'desc']], // Sort by date column (index 3) in descending order
        "columnDefs": [
            { "orderable": false, "targets": [6] } // Disable ordering on Actions column
        ],
        "language": {
            "search": "Search:",
            "lengthMenu": "Show _MENU_ entries per page",
            "info": "Showing _START_ to _END_ of _TOTAL_ entries",
            "infoEmpty": "Showing 0 to 0 of 0 entries",
            "infoFiltered": "(filtered from _MAX_ total entries)",
            "paginate": {
                "first": "First",
                "last": "Last",
                "next": "Next",
                "previous": "Previous"
            }
        }
    });
    
    // Adjust select width after DataTable initializes
    $('.dataTables_length select').css('width', '80px');
    
    // Initialize User Summary Table if it exists
    if ($('#userSummaryTable').length) {
        $('#userSummaryTable').DataTable({
            "pageLength": 10,
            "ordering": true,
            "info": true,
            "responsive": true,
            "searching": false,
            "paging": false,
            "order": [[3, 'desc']], // Sort by Total Invoices column
            "columnDefs": [
                { "orderable": false, "targets": [0] } // Disable ordering on # column
            ]
        });
    }
    
    // Add animation to summary cards on page load
    const summaryCards = document.querySelectorAll('.row.g-3.mb-4 .card');
    summaryCards.forEach((card, index) => {
        setTimeout(() => {
            card.style.opacity = '0';
            card.style.transform = 'translateY(20px)';
            card.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
            
            setTimeout(() => {
                card.style.opacity = '1';
                card.style.transform = 'translateY(0)';
            }, 50);
        }, index * 100);
    });
});
</script>
@endsection
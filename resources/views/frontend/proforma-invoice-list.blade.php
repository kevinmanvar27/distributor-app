@extends('frontend.layouts.app')

@section('title', 'My Proforma Invoices - ' . setting('site_title', 'Frontend App'))

@section('content')
<div class="container">
    <nav aria-label="breadcrumb" class="my-4">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="{{ route('frontend.home') }}">Home</a></li>
            <li class="breadcrumb-item active" aria-current="page">My Proforma Invoices</li>
        </ol>
    </nav>
    
    <div class="row justify-content-center">
        <div class="col-lg-12">
            <div class="card shadow-sm border-0 mb-4">
                <div class="card-header bg-white border-0">
                    <div class="d-flex justify-content-between align-items-center">
                        <h1 class="mb-0 heading-text">My Proforma Invoices</h1>
                    </div>
                </div>
                
                <div class="card-body">
                    @if($proformaInvoices->count() > 0)
                        <div class="table-responsive">
                            <table class="table table-hover">
                                <thead class="table-light">
                                    <tr>
                                        <th>#</th>
                                        <th>Invoice #</th>
                                        <th>Date</th>
                                        <th>Amount</th>
                                        <th>Status</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    @foreach($proformaInvoices as $invoice)
                                    <tr>
                                        <td>{{ $loop->iteration }}</td>
                                        <td>{{ $invoice->invoice_number }}</td>
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
                                                @default
                                                    <span class="badge bg-secondary">{{ $invoice->status }}</span>
                                            @endswitch
                                        </td>
                                        <td>
                                            <button class="btn btn-sm btn-outline-primary view-invoice" data-invoice-id="{{ $invoice->id }}">
                                                <i class="fas fa-eye me-1"></i>View
                                            </button>
                                            
                                            @if($invoice->status === 'Draft')
                                                <form action="{{ route('frontend.cart.proforma.invoice.add-to-cart', $invoice->id) }}" method="POST" class="d-inline">
                                                    @csrf
                                                    <button type="submit" class="btn btn-sm btn-outline-success" onclick="return confirm('Are you sure you want to add all products from this invoice to your cart and remove this invoice?')">
                                                        <i class="fas fa-cart-plus me-1"></i>Add to Cart
                                                    </button>
                                                </form>
                                                <form action="{{ route('frontend.cart.proforma.invoice.delete', $invoice->id) }}" method="POST" class="d-inline">
                                                    @csrf
                                                    @method('DELETE')
                                                    <button type="submit" class="btn btn-sm btn-outline-danger" onclick="return confirm('Are you sure you want to delete this proforma invoice?')">
                                                        <i class="fas fa-trash me-1"></i>Delete
                                                    </button>
                                                </form>
                                            @else
                                                <a href="{{ route('frontend.cart.proforma.invoice.download-pdf', $invoice->id) }}" class="btn btn-sm btn-outline-danger">
                                                    <i class="fas fa-file-pdf me-1"></i>PDF
                                                </a>
                                            @endif
                                            
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
                            <p class="mb-0 text-muted">You haven't generated any proforma invoices yet.</p>
                            <a href="{{ route('frontend.cart.index') }}" class="btn btn-theme mt-3">
                                <i class="fas fa-shopping-cart me-2"></i>Go to Cart
                            </a>
                        </div>
                    @endif
                </div>
            </div>
        </div>
    </div>
</div>

<!-- Invoice Details Modal -->
<div class="modal fade" id="invoiceModal" tabindex="-1" aria-labelledby="invoiceModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-xl">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="invoiceModalLabel">Proforma Invoice Details</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body" id="invoiceModalBody">
                <!-- Invoice details will be loaded here -->
                <div class="text-center py-5">
                    <div class="spinner-border" role="status">
                        <span class="visually-hidden">Loading...</span>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                <button type="button" class="btn btn-theme" id="downloadPdfBtn">
                    <i class="fas fa-file-pdf me-2"></i>Download PDF
                </button>
            </div>
        </div>
    </div>
</div>

<style>
    .btn-theme {
        background-color: <?php echo e(setting('theme_color', '#007bff')); ?> !important;
        border-color: <?php echo e(setting('theme_color', '#007bff')); ?> !important;
        color: white !important;
    }
    
    .btn-theme:hover {
        background-color: <?php echo e(setting('link_hover_color', '#0056b3')); ?> !important;
        border-color: <?php echo e(setting('link_hover_color', '#0056b3')); ?> !important;
    }
    
    .btn-outline-theme {
        border-color: <?php echo e(setting('theme_color', '#007bff')); ?> !important;
        color: <?php echo e(setting('theme_color', '#007bff')); ?> !important;
    }
    
    .btn-outline-theme:hover {
        background-color: <?php echo e(setting('theme_color', '#007bff')); ?> !important;
        border-color: <?php echo e(setting('theme_color', '#007bff')); ?> !important;
        color: white !important;
    }
    
    @media print {
        .modal-content {
            box-shadow: none !important;
            border: none !important;
        }
        
        .btn {
            display: none !important;
        }
        
        .breadcrumb {
            display: none !important;
        }
    }
</style>

<script>
document.addEventListener('DOMContentLoaded', function() {
    // View invoice button click handler
    document.querySelectorAll('.view-invoice').forEach(button => {
        button.addEventListener('click', function() {
            // Remove active class from all buttons
            document.querySelectorAll('.view-invoice').forEach(btn => {
                btn.classList.remove('active');
            });
            
            // Add active class to clicked button
            this.classList.add('active');
            
            const invoiceId = this.getAttribute('data-invoice-id');
            loadInvoiceDetails(invoiceId);
        });
    });
    
    // Download PDF button handler
    document.getElementById('downloadPdfBtn').addEventListener('click', function() {
        // Get the currently loaded invoice ID from the active button
        const activeButton = document.querySelector('.view-invoice.active');
        if (activeButton) {
            const invoiceId = activeButton.getAttribute('data-invoice-id');
            if (invoiceId) {
                // Redirect to the PDF download route
                window.location.href = `/cart/proforma-invoice/${invoiceId}/download-pdf`;
            }
        }
    });
    
    // Load invoice details via AJAX
    function loadInvoiceDetails(invoiceId) {
        // Show the modal
        const modal = new bootstrap.Modal(document.getElementById('invoiceModal'));
        modal.show();
        
        // Fetch invoice details
        fetch(`/cart/proforma-invoice/${invoiceId}`)
            .then(response => response.json())
            .then(data => {
                if (data.error) {
                    document.getElementById('invoiceModalBody').innerHTML = `
                        <div class="alert alert-danger">
                            ${data.error}
                        </div>
                    `;
                    return;
                }
                
                // Update notification count if provided
                if (data.unread_count !== undefined) {
                    updateNotificationCount(data.unread_count);
                }
                
                // Render invoice details
                renderInvoiceDetails(data);
            })
            .catch(error => {
                console.error('Error:', error);
                document.getElementById('invoiceModalBody').innerHTML = `
                    <div class="alert alert-danger">
                        Failed to load invoice details. Please try again.
                    </div>
                `;
            });
    }
    
    // Function to update notification count in header
    function updateNotificationCount(count) {
        const countElement = document.querySelector('#notificationsDropdown .notification-count');
        if (count > 0) {
            if (countElement) {
                countElement.textContent = count;
            } else {
                // Create count element if it doesn't exist
                const badge = document.createElement('span');
                badge.className = 'position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger notification-count';
                badge.textContent = count;
                document.querySelector('#notificationsDropdown').appendChild(badge);
            }
        } else {
            if (countElement) {
                countElement.remove();
            }
        }
    }
    
    // Get status badge HTML based on status
    function getStatusBadge(status) {
        switch(status) {
            case 'Draft':
                return '<span class="badge bg-secondary">Draft</span>';
            case 'Approved':
                return '<span class="badge bg-success">Approved</span>';
            case 'Dispatch':
                return '<span class="badge bg-info">Dispatch</span>';
            case 'Out for Delivery':
                return '<span class="badge bg-primary">Out for Delivery</span>';
            case 'Delivered':
                return '<span class="badge bg-success">Delivered</span>';
            case 'Return':
                return '<span class="badge bg-danger">Return</span>';
            default:
                return '<span class="badge bg-secondary">' + status + '</span>';
        }
    }
    
    // Render invoice details in the modal
    function renderInvoiceDetails(data) {
        const invoice = data.invoice;
        const invoiceData = data.data;
        
        // Get site settings from meta tags or use defaults
        const siteTitle = document.querySelector('meta[name="site-title"]')?.getAttribute('content') || 'Frontend App';
        const companyAddress = document.querySelector('meta[name="company-address"]')?.getAttribute('content') || 'Company Address';
        const companyEmail = document.querySelector('meta[name="company-email"]')?.getAttribute('content') || 'company@example.com';
        const companyPhone = document.querySelector('meta[name="company-phone"]')?.getAttribute('content') || '+1 (555) 123-4567';
        
        let customerHtml = '';
        if (invoiceData.customer) {
            customerHtml = `
                <p class="mb-1">${invoiceData.customer.name || 'N/A'}</p>
                <p class="mb-1">${invoiceData.customer.email || 'N/A'}</p>
                ${invoiceData.customer.address ? `<p class="mb-1">${invoiceData.customer.address}</p>` : ''}
                ${invoiceData.customer.mobile_number ? `<p class="mb-1">${invoiceData.customer.mobile_number}</p>` : ''}
            `;
        } else {
            customerHtml = `
                <p class="mb-1">Guest Customer</p>
                <p class="mb-1">N/A</p>
            `;
        }
        
        let cartItemsHtml = '';
        if (invoiceData.cart_items && invoiceData.cart_items.length > 0) {
            let index = 1;
            invoiceData.cart_items.forEach(item => {
                // Ensure price and total are valid numbers
                const price = parseFloat(item.price) || 0;
                const total = parseFloat(item.total) || 0;
                const quantity = parseInt(item.quantity) || 0;
                
                cartItemsHtml += `
                    <tr>
                        <td>${index++}</td>
                        <td>
                            <div>
                                <h6 class="mb-0">${item.product_name || 'Product'}</h6>
                                ${item.product_description ? `<small class="text-muted">${item.product_description.substring(0, 50)}${item.product_description.length > 50 ? '...' : ''}</small>` : ''}
                            </div>
                        </td>
                        <td>₹${price.toFixed(2)}</td>
                        <td>${quantity}</td>
                        <td>₹${total.toFixed(2)}</td>
                    </tr>
                `;
            });
        }
        
        // Ensure all financial values are valid numbers
        const subtotal = parseFloat(invoiceData.subtotal) || 0;
        const taxPercentage = parseFloat(invoiceData.tax_percentage) || 0;
        const taxAmount = parseFloat(invoiceData.tax_amount) || 0;
        const shipping = parseFloat(invoiceData.shipping) || 0;
        const discountAmount = parseFloat(invoiceData.discount_amount) || 0;
        const invoiceTotal = parseFloat(invoiceData.total) || 0;
        
        if (invoice.status === 'Draft') {
            // Always show the download button
            $('#downloadPdfBtn').addClass('d-none');
        } else {
            // Hide the download button for other statuses
            $('#downloadPdfBtn').removeClass('d-none');
        }
        
        document.getElementById('invoiceModalBody').innerHTML = `
            <div class="container-fluid">
                <div class="row mb-4">
                    <div class="col-md-6">
                        <h5 class="fw-bold mb-3">From:</h5>
                        <p class="mb-1">${siteTitle}</p>
                        <p class="mb-1">${companyAddress}</p>
                        <p class="mb-1">${companyEmail}</p>
                        <p class="mb-1">${companyPhone}</p>
                    </div>
                    
                    <div class="col-md-6">
                        <h5 class="fw-bold mb-3">To:</h5>
                        ${customerHtml}
                    </div>
                </div>
                
                <div class="row mb-4">
                    <div class="col-md-6">
                        <p class="mb-1"><strong>Invoice #:</strong> ${invoice.invoice_number}</p>
                        <p class="mb-1"><strong>Date:</strong> ${invoiceData.invoice_date || new Date(invoice.created_at).toLocaleDateString()}</p>
                    </div>
                    <div class="col-md-6">
                        <p class="mb-1"><strong>Status:</strong> 
                            ${getStatusBadge(invoice.status)}
                        </p>
                    </div>
                </div>
                
                <div class="table-responsive">
                    <table class="table table-bordered">
                        <thead class="table-light">
                            <tr>
                                <th>#</th>
                                <th>Product</th>
                                <th>Price</th>
                                <th>Quantity</th>
                                <th>Total</th>
                            </tr>
                        </thead>
                        <tbody>
                            ${cartItemsHtml}
                        </tbody>
                    </table>
                </div>
                
                <div class="row">
                    <div class="col-md-6">
                        <div class="card border-0 bg-light">
                            <div class="card-body">
                                <h5 class="card-title">Notes</h5>
                                <p class="mb-0">${invoiceData.notes || 'This is a proforma invoice and not a tax invoice. Payment is due upon receipt.'}</p>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-md-6">
                        <div class="table-responsive">
                            <table class="table table-borderless">
                                <tbody>
                                    ${subtotal > 0 ? `<tr>
                                        <td class="fw-bold">Subtotal:</td>
                                        <td class="text-end">₹${subtotal.toFixed(2)}</td>
                                    </tr>` : ''}
                                    ${taxPercentage > 0 ? `<tr>
                                        <td class="fw-bold">GST (${taxPercentage.toFixed(2)}%):</td>
                                        <td class="text-end">₹${taxAmount.toFixed(2)}</td>
                                    </tr>` : ''}
                                    ${shipping > 0 ? `<tr>
                                        <td class="fw-bold">Shipping:</td>
                                        <td class="text-end">₹${shipping.toFixed(2)}</td>
                                    </tr>` : ''}
                                    ${discountAmount > 0 ? `<tr>
                                        <td class="fw-bold">Discount Amount:</td>
                                        <td class="text-end">₹${discountAmount.toFixed(2)}</td>
                                    </tr>` : ''}
                                    <tr class="border-top">
                                        <td class="fw-bold">Total:</td>
                                        <td class="text-end fw-bold">₹${invoiceTotal.toFixed(2)}</td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
        `;
    }
});
</script>
@endsection
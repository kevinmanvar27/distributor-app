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
                                        <td class="action-buttons">
                                            <!-- View Button - Theme colored -->
                                            <button class="btn btn-sm btn-view-theme view-invoice" data-invoice-id="{{ $invoice->id }}">
                                                <i class="fas fa-eye me-1"></i>View
                                            </button>
                                            
                                            @if($invoice->status === 'Draft')
                                                <!-- Add to Cart Button -->
                                                <form action="{{ route('frontend.cart.proforma.invoice.add-to-cart', $invoice->id) }}" method="POST" class="d-inline">
                                                    @csrf
                                                    <button type="submit" class="btn btn-sm btn-cart-theme" onclick="return confirm('Are you sure you want to add all products from this invoice to your cart and remove this invoice?')">
                                                        <i class="fas fa-cart-plus me-1"></i>Add to Cart
                                                    </button>
                                                </form>
                                                <!-- Delete Button -->
                                                <form action="{{ route('frontend.cart.proforma.invoice.delete', $invoice->id) }}" method="POST" class="d-inline">
                                                    @csrf
                                                    @method('DELETE')
                                                    <button type="submit" class="btn btn-sm btn-delete-theme" onclick="return confirm('Are you sure you want to delete this proforma invoice?')">
                                                        <i class="fas fa-trash me-1"></i>Delete
                                                    </button>
                                                </form>
                                            @else
                                                <!-- PDF Download Button -->
                                                <a href="{{ route('frontend.cart.proforma.invoice.download-pdf', $invoice->id) }}" class="btn btn-sm btn-pdf-theme">
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
    
    /* View Button - Theme Primary Color */
    .btn-view-theme {
        background-color: <?php echo e(setting('theme_color', '#007bff')); ?> !important;
        border-color: <?php echo e(setting('theme_color', '#007bff')); ?> !important;
        color: white !important;
        transition: all 0.3s ease;
    }
    
    .btn-view-theme:hover {
        background-color: <?php echo e(setting('link_hover_color', '#0056b3')); ?> !important;
        border-color: <?php echo e(setting('link_hover_color', '#0056b3')); ?> !important;
        color: white !important;
        transform: translateY(-1px);
        box-shadow: 0 2px 5px rgba(0,0,0,0.2);
    }
    
    /* Add to Cart Button - Green Success */
    .btn-cart-theme {
        background-color: #28a745 !important;
        border-color: #28a745 !important;
        color: white !important;
        transition: all 0.3s ease;
    }
    
    .btn-cart-theme:hover {
        background-color: #218838 !important;
        border-color: #1e7e34 !important;
        color: white !important;
        transform: translateY(-1px);
        box-shadow: 0 2px 5px rgba(40, 167, 69, 0.3);
    }
    
    /* Delete Button - Red Danger */
    .btn-delete-theme {
        background-color: #dc3545 !important;
        border-color: #dc3545 !important;
        color: white !important;
        transition: all 0.3s ease;
    }
    
    .btn-delete-theme:hover {
        background-color: #c82333 !important;
        border-color: #bd2130 !important;
        color: white !important;
        transform: translateY(-1px);
        box-shadow: 0 2px 5px rgba(220, 53, 69, 0.3);
    }
    
    /* PDF Button - Dark Red */
    .btn-pdf-theme {
        background-color: #b71c1c !important;
        border-color: #b71c1c !important;
        color: white !important;
        transition: all 0.3s ease;
    }
    
    .btn-pdf-theme:hover {
        background-color: #8b0000 !important;
        border-color: #8b0000 !important;
        color: white !important;
        transform: translateY(-1px);
        box-shadow: 0 2px 5px rgba(183, 28, 28, 0.3);
    }
    
    /* Action buttons container */
    .action-buttons {
        white-space: nowrap;
    }
    
    .action-buttons .btn {
        margin-right: 5px;
        margin-bottom: 3px;
    }
    
    .action-buttons .btn:last-child {
        margin-right: 0;
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
    
    /* Responsive adjustments for action buttons */
    @media (max-width: 768px) {
        .action-buttons {
            white-space: normal;
        }
        
        .action-buttons .btn {
            margin-bottom: 5px;
            display: inline-block;
        }
    }
    
    /* Product link styles in invoice modal */
    .product-link {
        color: <?php echo e(setting('theme_color', '#007bff')); ?>;
        font-weight: 600;
        transition: all 0.2s ease;
    }
    
    .product-link:hover {
        color: <?php echo e(setting('link_hover_color', '#0056b3')); ?>;
        text-decoration: underline !important;
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
        // Show the modal with loading spinner
        const modal = new bootstrap.Modal(document.getElementById('invoiceModal'));
        
        // Reset modal body to show loading spinner
        document.getElementById('invoiceModalBody').innerHTML = `
            <div class="text-center py-5">
                <div class="spinner-border text-primary" role="status">
                    <span class="visually-hidden">Loading...</span>
                </div>
                <p class="mt-2 text-muted">Loading invoice details...</p>
            </div>
        `;
        
        modal.show();
        
        // Fetch invoice details
        fetch(`/cart/proforma-invoice/${invoiceId}`, {
            method: 'GET',
            headers: {
                'Accept': 'application/json',
                'X-Requested-With': 'XMLHttpRequest'
            }
        })
            .then(response => {
                if (!response.ok) {
                    throw new Error(`HTTP error! status: ${response.status}`);
                }
                return response.json();
            })
            .then(data => {
                console.log('Invoice data received:', data); // Debug log
                
                if (data.error) {
                    document.getElementById('invoiceModalBody').innerHTML = `
                        <div class="alert alert-danger">
                            <i class="fas fa-exclamation-circle me-2"></i>${data.error}
                        </div>
                    `;
                    return;
                }
                
                // Validate data structure
                if (!data.invoice || !data.data) {
                    document.getElementById('invoiceModalBody').innerHTML = `
                        <div class="alert alert-warning">
                            <i class="fas fa-exclamation-triangle me-2"></i>Invalid invoice data received.
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
                console.error('Error loading invoice:', error);
                document.getElementById('invoiceModalBody').innerHTML = `
                    <div class="alert alert-danger">
                        <i class="fas fa-exclamation-circle me-2"></i>
                        Failed to load invoice details. Please try again.
                        <br><small class="text-muted">Error: ${error.message}</small>
                    </div>
                `;
            });
    }
    
    // Function to update notification count in header
    function updateNotificationCount(count) {
        const notificationsDropdown = document.querySelector('#notificationsDropdown');
        
        // Exit early if notifications dropdown doesn't exist on this page
        if (!notificationsDropdown) {
            return;
        }
        
        const countElement = notificationsDropdown.querySelector('.notification-count');
        if (count > 0) {
            if (countElement) {
                countElement.textContent = count;
            } else {
                // Create count element if it doesn't exist
                const badge = document.createElement('span');
                badge.className = 'position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger notification-count';
                badge.textContent = count;
                notificationsDropdown.appendChild(badge);
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
        const invoiceData = data.data || {};
        
        console.log('Rendering invoice:', invoice); // Debug log
        console.log('Invoice data:', invoiceData); // Debug log
        
        // Get site settings from meta tags or use defaults
        const siteTitle = document.querySelector('meta[name="site-title"]')?.getAttribute('content') || '{{ setting("site_title", "Frontend App") }}';
        const companyAddress = document.querySelector('meta[name="company-address"]')?.getAttribute('content') || '{{ setting("company_address", "Company Address") }}';
        const companyEmail = document.querySelector('meta[name="company-email"]')?.getAttribute('content') || '{{ setting("company_email", "company@example.com") }}';
        const companyPhone = document.querySelector('meta[name="company-phone"]')?.getAttribute('content') || '{{ setting("company_phone", "+1 (555) 123-4567") }}';
        
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
        // Handle different possible data structures for cart items
        const cartItems = invoiceData.cart_items || invoiceData.items || invoiceData.products || [];
        
        console.log('Cart items:', cartItems); // Debug log
        
        if (cartItems && cartItems.length > 0) {
            let index = 1;
            cartItems.forEach(item => {
                // Ensure price and total are valid numbers
                const price = parseFloat(item.price) || parseFloat(item.unit_price) || 0;
                const total = parseFloat(item.total) || parseFloat(item.line_total) || (price * (parseInt(item.quantity) || 0));
                const quantity = parseInt(item.quantity) || parseInt(item.qty) || 0;
                const productName = item.product_name || item.name || item.title || 'Product';
                const productSlug = item.product_slug || item.slug || '';
                const productDesc = item.product_description || item.description || '';
                
                // Create product link if slug is available
                const productLink = productSlug ? `/product/${productSlug}` : '#';
                const productNameHtml = productSlug 
                    ? `<a href="${productLink}" class="product-link text-decoration-none">${productName}</a>`
                    : productName;
                
                cartItemsHtml += `
                    <tr>
                        <td>${index++}</td>
                        <td>
                            <div>
                                <h6 class="mb-0">${productNameHtml}</h6>
                                ${productDesc ? `<small class="text-muted">${productDesc.substring(0, 50)}${productDesc.length > 50 ? '...' : ''}</small>` : ''}
                            </div>
                        </td>
                        <td>₹${price.toFixed(2)}</td>
                        <td>${quantity}</td>
                        <td>₹${total.toFixed(2)}</td>
                    </tr>
                `;
            });
        } else {
            cartItemsHtml = `
                <tr>
                    <td colspan="5" class="text-center text-muted py-3">
                        <i class="fas fa-inbox me-2"></i>No items found in this invoice
                    </td>
                </tr>
            `;
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
@extends('admin.layouts.app')

@section('title', 'Proforma Invoice - ' . setting('site_title', 'Admin Panel'))

@section('content')
<div class="container-fluid h-100">
    <div class="row h-100">
        @include('admin.layouts.sidebar')
        
        <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4 main-content">
            @include('admin.layouts.header', ['pageTitle' => 'Proforma Invoice Details'])
            
            <div class="pt-4 pb-2 mb-3">
                <div class="row justify-content-center">
                    <div class="col-lg-10">
                        <div class="card border-0 shadow-sm mb-4">
                            <div class="card-header bg-white border-0 py-3">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div>
                                        <h4 class="card-title mb-0 fw-bold">Invoice Details</h4>
                                        <p class="mb-0 text-muted">Invoice #{{ $invoiceNumber }}</p>
                                    </div>
                                    <div>
                                        <a href="{{ route('admin.proforma-invoice.index') }}" class="btn btn-outline-secondary rounded-pill">
                                            <i class="fas fa-arrow-left me-2"></i>Back to Invoices
                                        </a>
                                        @if(!$proformaInvoice->isDraft())
                                        <a href="{{ route('admin.proforma-invoice.download-pdf', $proformaInvoice->id) }}" class="btn btn-theme rounded-pill ms-2">
                                            <i class="fas fa-file-pdf me-2"></i>Download PDF
                                        </a>
                                        @endif
                                    </div>
                                </div>
                            </div>
                            
                            <div class="card-body">
                                @if(session('success'))
                                    <div class="alert alert-success alert-dismissible fade show rounded-pill px-4 py-3 mb-4" role="alert">
                                        <i class="fas fa-check-circle me-2"></i>{{ session('success') }}
                                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                                    </div>
                                @endif
                                
                                <div class="row mb-4">
                                    <div class="col-md-6">
                                        <h5 class="fw-bold mb-3">From:</h5>
                                        <p class="mb-1">{{ setting('site_title', 'Frontend App') }}</p>
                                        <p class="mb-1">{{ setting('address', 'Company Address') }}</p>
                                        <p class="mb-1">{{ setting('company_email', 'company@example.com') }}</p>
                                        <p class="mb-1">{{ setting('company_phone', '+1 (555) 123-4567') }}</p>
                                    </div>
                                    
                                    <div class="col-md-6">
                                        <h5 class="fw-bold mb-3">To:</h5>
                                        @if($customer)
                                            <p class="mb-1">{{ $customer['name'] ?? 'N/A' }}</p>
                                            <p class="mb-1">{{ $customer['email'] ?? 'N/A' }}</p>
                                            @if(!empty($customer['address']))
                                                <p class="mb-1">{{ $customer['address'] }}</p>
                                            @endif
                                            @if(!empty($customer['mobile_number']))
                                                <p class="mb-1">{{ $customer['mobile_number'] }}</p>
                                            @endif
                                        @else
                                            <p class="mb-1">Guest Customer</p>
                                            <p class="mb-1">N/A</p>
                                        @endif
                                    </div>
                                </div>
                                
                                <!-- Editable Invoice Form -->
                                <form id="invoiceForm" action="{{ route('admin.proforma-invoice.update', $proformaInvoice->id) }}" method="POST">
                                    @csrf
                                    @method('PUT')
                            
                                    <div class="row mb-4">
                                        <div class="col-md-6">
                                            <p class="mb-1"><strong>Invoice #:</strong> {{ $invoiceNumber }}</p>
                                            <p class="mb-1"><strong>Date:</strong> {{ $invoiceDate }}</p>
                                        </div>
                                        <div class="col-md-6">
                                            <p class="mb-1">
                                                <strong>Status:</strong> 
                                                @switch($proformaInvoice->status)
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
                                            </p>
                                            
                                            <!-- Status selection moved inside main form -->
                                            <div class="mt-2">
                                                <label for="status" class="form-label">Update Status:</label>
                                                <select name="status" class="form-select form-select-sm status-select" id="status">
                                                    @foreach(\App\Models\ProformaInvoice::STATUS_OPTIONS as $statusOption)
                                                        <option value="{{ $statusOption }}" {{ $proformaInvoice->status == $statusOption ? 'selected' : '' }}>{{ $statusOption }}</option>
                                                    @endforeach
                                                </select>
                                            </div>
                                        </div>
                                    </div>
                                    
                                    <div class="table-responsive mb-4">
                                        <table class="table table-bordered">
                                            <thead class="table-light">
                                                <tr>
                                                    <th>Product</th>
                                                    <th>Price</th>
                                                    <th>Quantity</th>
                                                    <th>Total</th>
                                                    <th>Actions</th>
                                                </tr>
                                            </thead>
                                            <tbody>
                                                @foreach($cartItems as $index => $item)
                                                <tr>
                                                    <td>
                                                        <div>
                                                            <strong>{{ $item['product_name'] ?? 'Product' }}</strong>
                                                            @if(!empty($item['product_description']))
                                                                <small class="text-muted">{{ Str::limit($item['product_description'], 50) }}</small>
                                                            @endif
                                                        </div>
                                                    </td>
                                                    <td>
                                                        <div class="input-group">
                                                            <span class="input-group-text">₹</span>
                                                            <input type="number" name="items[{{ $index }}][price]" 
                                                                   class="form-control item-price" 
                                                                   value="{{ $item['price'] }}" 
                                                                   step="0.01" min="0">
                                                        </div>
                                                    </td>
                                                    <td>
                                                        <input type="number" name="items[{{ $index }}][quantity]" 
                                                               class="form-control item-quantity" 
                                                               value="{{ $item['quantity'] }}" 
                                                               min="1">
                                                    </td>
                                                    <td>
                                                        <div class="input-group">
                                                            <span class="input-group-text">₹</span>
                                                            <input type="number" name="items[{{ $index }}][total]" 
                                                                   class="form-control item-total" 
                                                                   value="{{ $item['total'] ?? ($item['price'] * $item['quantity']) }}" 
                                                                   step="0.01" min="0" readonly>
                                                        </div>
                                                    </td>
                                                    <td>
                                                        <!-- Changed from form to button with JavaScript handling -->
                                                        <button type="button" class="btn btn-danger btn-sm remove-item-btn" data-index="{{ $index }}">
                                                            <i class="fas fa-trash"></i> Remove
                                                        </button>
                                                    </td>
                                                </tr>
                                                @endforeach
                                            </tbody>
                                        </table>
                                    </div>
                                    
                                    <div class="row">
                                        <div class="col-md-6">
                                            <div class="card border-0 bg-light">
                                                <div class="card-body">
                                                    <h5 class="card-title">Notes</h5>
                                                    <textarea name="notes" class="form-control" rows="3">{{ $invoiceData['notes'] ?? 'This is a proforma invoice and not a tax invoice. Payment is due upon receipt.' }}</textarea>
                                                </div>
                                            </div>
                                        </div>
                                        
                                        <div class="col-md-6">
                                            <div class="table-responsive">
                                                <table class="table table-borderless">
                                                    <tbody>
                                                        <tr>
                                                            <td class="fw-bold">Subtotal:</td>
                                                            <td class="text-end">
                                                                <div class="input-group">
                                                                    <span class="input-group-text">₹</span>
                                                                    <input type="number" name="subtotal" class="form-control subtotal" value="{{ number_format($invoiceData['subtotal'] ?? $total, 2, '.', '') }}" step="0.01" min="0" readonly>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td class="fw-bold">GST (%):</td>
                                                            <td class="text-end">
                                                                <div class="input-group">
                                                                    <input type="number" name="tax_percentage" class="form-control tax-percentage" value="{{ $invoiceData['tax_percentage'] ?? 18 }}" step="0.01" min="0" max="100">
                                                                    <span class="input-group-text">%</span>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td class="fw-bold">Tax Amount:</td>
                                                            <td class="text-end">
                                                                <div class="input-group">
                                                                    <span class="input-group-text">₹</span>
                                                                    <input type="number" name="tax_amount" class="form-control tax-amount" value="{{ $invoiceData['tax_amount'] ?? 0 }}" step="0.01" min="0" readonly>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td class="fw-bold">Shipping:</td>
                                                            <td class="text-end">
                                                                <div class="input-group">
                                                                    <span class="input-group-text">₹</span>
                                                                    <input type="number" name="shipping" class="form-control shipping" value="{{ $invoiceData['shipping'] ?? 0 }}" step="0.01" min="0">
                                                                </div>
                                                            </td>
                                                        </tr>
                                                        <tr>
                                                            <td class="fw-bold">Discount Amount:</td>
                                                            <td class="text-end">
                                                                <div class="input-group">
                                                                    <span class="input-group-text">₹</span>
                                                                    <input type="number" name="discount_amount" class="form-control discount-amount" value="{{ $invoiceData['discount_amount'] ?? 0 }}" step="0.01" min="0">
                                                                </div>
                                                            </td>
                                                        </tr>
                                                        <tr class="border-top">
                                                            <td class="fw-bold">Total:</td>
                                                            <td class="text-end fw-bold">
                                                                <div class="input-group">
                                                                    <span class="input-group-text">₹</span>
                                                                    <input type="number" name="total" class="form-control total" value="{{ number_format($invoiceData['total'] ?? $total, 2, '.', '') }}" step="0.01" min="0" readonly>
                                                                </div>
                                                            </td>
                                                        </tr>
                                                    </tbody>
                                                </table>
                                            </div>
                                        </div>
                                    </div>
                                    
                                    <div class="d-flex justify-content-end mt-3">
                                        <button type="submit" class="btn btn-theme rounded-pill">
                                            <i class="fas fa-save me-1"></i>Save Invoice
                                        </button>
                                    </div>
                                </form>
                                
                                <!-- Hidden form for removing items -->
                                <form id="removeItemForm" action="{{ route('admin.proforma-invoice.remove-item', $proformaInvoice->id) }}" method="POST" style="display: none;">
                                    @csrf
                                    @method('DELETE')
                                    <input type="hidden" name="item_index" id="itemIndexInput">
                                </form>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            @include('admin.layouts.footer')
        </main>
    </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
    // Calculate item totals and overall invoice totals
    function calculateItemTotal(row) {
        const priceInput = row.querySelector('.item-price');
        const quantityInput = row.querySelector('.item-quantity');
        const totalInput = row.querySelector('.item-total');
        
        if (priceInput && quantityInput && totalInput) {
            const price = parseFloat(priceInput.value) || 0;
            const quantity = parseInt(quantityInput.value) || 0;
            const total = price * quantity;
            totalInput.value = total.toFixed(2);
        }
    }
    
    // Calculate overall invoice totals
    function calculateInvoiceTotals() {
        // Calculate subtotal from invoice data or from item totals
        let subtotal = 0;
        if (typeof invoiceData !== 'undefined' && invoiceData.subtotal) {
            subtotal = parseFloat(invoiceData.subtotal);
        } else {
            // Fallback to calculating from item totals
            document.querySelectorAll('.item-total').forEach(input => {
                subtotal += parseFloat(input.value) || 0;
            });
        }
        document.querySelector('.subtotal').value = subtotal.toFixed(2);
        
        // Get tax percentage
        const taxPercentage = parseFloat(document.querySelector('.tax-percentage').value) || 0;
        
        // Get shipping
        const shipping = parseFloat(document.querySelector('.shipping').value) || 0;
        
        // Get discount amount
        let discountAmount = parseFloat(document.querySelector('.discount-amount').value) || 0;
        
        // Calculate tax amount (tax on subtotal only, not including shipping)
        const taxAmount = (subtotal * taxPercentage / 100);
        document.querySelector('.tax-amount').value = taxAmount.toFixed(2);
        
        // Calculate final total
        // Total = (Subtotal + Shipping + Tax) - Discount
        const finalTotal = (subtotal + shipping + taxAmount) - discountAmount;
        document.querySelector('.total').value = finalTotal.toFixed(2);
    }
    
    // Add event listeners to item inputs
    document.querySelectorAll('.item-price, .item-quantity').forEach(input => {
        input.addEventListener('input', function() {
            const row = this.closest('tr');
            calculateItemTotal(row);
            calculateInvoiceTotals();
        });
    });
    
    // Add event listeners to discount, shipping, and tax inputs
    document.querySelector('.discount-amount').addEventListener('input', calculateInvoiceTotals);
    document.querySelector('.shipping').addEventListener('input', calculateInvoiceTotals);
    document.querySelector('.tax-percentage').addEventListener('input', calculateInvoiceTotals);
    
    // Handle item removal
    document.querySelectorAll('.remove-item-btn').forEach(button => {
        button.addEventListener('click', function() {
            const index = this.getAttribute('data-index');
            if (confirm('Are you sure you want to remove this item?')) {
                document.getElementById('itemIndexInput').value = index;
                document.getElementById('removeItemForm').submit();
            }
        });
    });
    
    // Initial calculation
    document.querySelectorAll('tbody tr').forEach(row => {
        calculateItemTotal(row);
    });
    calculateInvoiceTotals();
});
</script>
@endsection
<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\ProformaInvoice;
use App\Models\Setting;
use App\Models\Notification;
use Illuminate\Support\Facades\Auth;
use Barryvdh\DomPDF\Facade\Pdf;

class ProformaInvoiceController extends Controller
{
    /**
     * Display a listing of proforma invoices.
     *
     * @return \Illuminate\View\View
     */
    public function index()
    {
        // Get all proforma invoices with user information
        $proformaInvoices = ProformaInvoice::with('user')->orderBy('created_at', 'desc')->get();
        
        return view('admin.proforma-invoice.index', compact('proformaInvoices'));
    }
    
    /**
     * Display the specified proforma invoice.
     *
     * @param  int  $id
     * @return \Illuminate\View\View
     */
    public function show($id)
    {
        $proformaInvoice = ProformaInvoice::with('user')->findOrFail($id);
        
        // Get invoice data (already decoded by model casting)
        $invoiceData = $proformaInvoice->invoice_data;
        
        // Extract cart items and customer info
        $cartItems = $invoiceData['cart_items'] ?? [];
        $total = $invoiceData['total'] ?? 0;
        $invoiceDate = $invoiceData['invoice_date'] ?? $proformaInvoice->created_at->format('Y-m-d');
        $customer = $invoiceData['customer'] ?? null;
        
        // Generate invoice number (for display consistency)
        $invoiceNumber = $proformaInvoice->invoice_number;
        
        // Automatically remove all notifications for this invoice when viewing directly
        if (Auth::check()) {
            // Get all unread notifications for the current user that are related to this invoice
            $notifications = Notification::where('user_id', Auth::id())
                ->where('read', false)
                ->where('type', 'proforma_invoice')
                ->where('data', 'like', '%"invoice_id":' . $id . '%')
                ->get();
            
            // Delete all matching notifications
            foreach ($notifications as $notification) {
                $notification->delete();
            }
        }
        
        return view('admin.proforma-invoice.show', compact('proformaInvoice', 'cartItems', 'total', 'invoiceNumber', 'invoiceDate', 'customer', 'invoiceData'));
    }
    
    /**
     * Update the proforma invoice.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  int  $id
     * @return \Illuminate\Http\RedirectResponse
     */
    public function update(Request $request, $id)
    {
        $proformaInvoice = ProformaInvoice::findOrFail($id);
        
        // Get the existing invoice data
        $invoiceData = json_decode($proformaInvoice->invoice_data, true);
        
        // Update status if provided
        if ($request->has('status')) {
            // Validate the status input
            $request->validate([
                'status' => 'required|in:' . implode(',', ProformaInvoice::STATUS_OPTIONS)
            ]);
            
            // Update the status
            $proformaInvoice->status = $request->input('status');
        }
        
        // Update cart items if provided
        if ($request->has('items')) {
            $items = $request->input('items');
            $cartItems = [];
            
            foreach ($items as $index => $item) {
                // Get the original item data
                $originalItem = $invoiceData['cart_items'][$index] ?? [];
                
                $cartItems[] = [
                    'product_name' => $originalItem['product_name'] ?? 'Product',
                    'product_description' => $originalItem['product_description'] ?? '',
                    'price' => (float) $item['price'],
                    'quantity' => (int) $item['quantity'],
                    'total' => (float) $item['total'],
                ];
            }
            
            $invoiceData['cart_items'] = $cartItems;
        }
        
        // Update invoice details
        $invoiceData['subtotal'] = (float) $request->input('subtotal', $invoiceData['subtotal'] ?? 0);
        $invoiceData['discount_percentage'] = (float) $request->input('discount_percentage', $invoiceData['discount_percentage'] ?? 0);
        $invoiceData['discount_amount'] = (float) $request->input('discount_amount', $invoiceData['discount_amount'] ?? 0);
        $invoiceData['shipping'] = (float) $request->input('shipping', $invoiceData['shipping'] ?? 0);
        $invoiceData['tax_percentage'] = (float) $request->input('tax_percentage', $invoiceData['tax_percentage'] ?? 0);
        $invoiceData['tax_amount'] = (float) $request->input('tax_amount', $invoiceData['tax_amount'] ?? 0);
        $invoiceData['total'] = (float) $request->input('total', $invoiceData['total'] ?? 0);
        $invoiceData['notes'] = $request->input('notes', $invoiceData['notes'] ?? 'This is a proforma invoice and not a tax invoice. Payment is due upon receipt.');
        
        // Update the proforma invoice
        $proformaInvoice->total_amount = (float) $request->input('total', $proformaInvoice->total_amount);
        $proformaInvoice->invoice_data = json_encode($invoiceData);
        $proformaInvoice->save();
        
        return redirect()->back()->with('success', 'Proforma invoice updated successfully.');
    }
    
    /**
     * Update the status of the proforma invoice.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  int  $id
     * @return \Illuminate\Http\RedirectResponse
     */
    public function updateStatus(Request $request, $id)
    {
        $proformaInvoice = ProformaInvoice::findOrFail($id);
        
        // Validate the status input
        $request->validate([
            'status' => 'required|in:' . implode(',', ProformaInvoice::STATUS_OPTIONS)
        ]);
        
        // Update the status
        $proformaInvoice->status = $request->input('status');
        $proformaInvoice->save();
        
        return redirect()->back()->with('success', "Proforma invoice status updated to {$proformaInvoice->status} successfully.");
    }
    
    /**
     * Remove an item from the proforma invoice.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  int  $id
     * @return \Illuminate\Http\RedirectResponse
     */
    public function removeItem(Request $request, $id)
    {
        $proformaInvoice = ProformaInvoice::findOrFail($id);
        
        // Get invoice data (already decoded by model casting)
        $invoiceData = $proformaInvoice->invoice_data;
        
        // Get the item index to remove
        $itemIndex = $request->input('item_index');
        
        // Validate item index
        if (!isset($invoiceData['cart_items'][$itemIndex])) {
            return redirect()->back()->with('error', 'Invalid item selection.');
        }
        
        // Remove the item
        $removedItem = $invoiceData['cart_items'][$itemIndex];
        unset($invoiceData['cart_items'][$itemIndex]);
        
        // Re-index array to ensure sequential keys
        $invoiceData['cart_items'] = array_values($invoiceData['cart_items']);
        
        // Recalculate total
        $newTotal = 0;
        foreach ($invoiceData['cart_items'] as $item) {
            $newTotal += $item['total'];
        }
        
        $invoiceData['total'] = $newTotal;
        
        // Update the proforma invoice
        $proformaInvoice->total_amount = $newTotal;
        $proformaInvoice->invoice_data = json_encode($invoiceData);
        $proformaInvoice->save();
        
        return redirect()->back()->with('success', 'Item removed successfully. Total updated.');
    }
    
    /**
     * Generate and download PDF for a proforma invoice.
     *
     * @param  int  $id
     * @return \Illuminate\Http\Response
     */
    public function downloadPDF($id)
    {
        $proformaInvoice = ProformaInvoice::with('user')->findOrFail($id);
        
        // Get invoice data (already decoded by model casting)
        $invoiceData = $proformaInvoice->invoice_data;
        
        // Extract cart items and customer info
        $cartItems = $invoiceData['cart_items'] ?? [];
        $total = $invoiceData['total'] ?? 0;
        $invoiceDate = $invoiceData['invoice_date'] ?? $proformaInvoice->created_at->format('Y-m-d');
        $customer = $invoiceData['customer'] ?? null;
        
        // Generate invoice number (for display consistency)
        $invoiceNumber = $proformaInvoice->invoice_number;
        
        // Get settings
        $settings = Setting::first();
        
        // Prepare data for the PDF view
        $data = [
            'proformaInvoice' => $proformaInvoice,
            'cartItems' => $cartItems,
            'total' => $total,
            'invoiceNumber' => $invoiceNumber,
            'invoiceDate' => $invoiceDate,
            'customer' => $customer,
            'invoiceData' => $invoiceData,
            'siteTitle' => setting('site_title', 'Admin Panel'),
            'companyAddress' => setting('address', 'Company Address'),
            'companyEmail' => setting('email', 'company@example.com'),
            'companyPhone' => setting('phone', '+1 (555) 123-4567'),
            'headerLogo' => setting('header_logo', null),
            'settings' => $settings
        ];
        
        // Load the PDF view
        $pdf = Pdf::loadView('admin.proforma-invoice-pdf', $data);
        
        // Set paper size and orientation
        $pdf->setPaper('A4', 'portrait');
        
        // Download the PDF with a meaningful filename
        return $pdf->download('proforma-invoice-' . $proformaInvoice->invoice_number . '.pdf');
    }
    
    /**
     * Remove the specified proforma invoice from storage.
     *
     * @param  int  $id
     * @return \Illuminate\Http\RedirectResponse
     */
    public function destroy($id)
    {
        $proformaInvoice = ProformaInvoice::findOrFail($id);
        $proformaInvoice->delete();
        
        return redirect()->route('admin.proforma-invoice.index')->with('success', 'Proforma invoice deleted successfully.');
    }
}
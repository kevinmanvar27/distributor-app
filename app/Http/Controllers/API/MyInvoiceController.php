<?php

namespace App\Http\Controllers\API;

use App\Models\ProformaInvoice;
use App\Models\ShoppingCartItem;
use App\Models\Product;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Barryvdh\DomPDF\Facade\Pdf;

/**
 * @OA\Tag(
 *     name="My Invoices",
 *     description="API Endpoints for User's Proforma Invoices"
 * )
 */
class MyInvoiceController extends ApiController
{
    /**
     * Get authenticated user's proforma invoices
     * 
     * @OA\Get(
     *      path="/api/v1/my-invoices",
     *      operationId="getMyInvoices",
     *      tags={"My Invoices"},
     *      summary="Get user's invoices",
     *      description="Returns the authenticated user's proforma invoices",
     *      security={{"sanctum": {}}},
     *      @OA\Parameter(
     *          name="page",
     *          description="Page number",
     *          required=false,
     *          in="query",
     *          @OA\Schema(type="integer")
     *      ),
     *      @OA\Parameter(
     *          name="status",
     *          description="Filter by status (draft, sent, paid, cancelled)",
     *          required=false,
     *          in="query",
     *          @OA\Schema(type="string")
     *      ),
     *      @OA\Response(
     *          response=200,
     *          description="Successful operation",
     *       ),
     *      @OA\Response(
     *          response=401,
     *          description="Unauthenticated"
     *      )
     * )
     * 
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function index(Request $request)
    {
        $user = $request->user();
        
        $query = ProformaInvoice::where('user_id', $user->id)
            ->orderBy('created_at', 'desc');
        
        // Filter by status if provided
        if ($request->has('status') && $request->status) {
            $query->where('status', $request->status);
        }
        
        $invoices = $query->paginate(15);
        
        // Decode invoice_data for each invoice
        $invoices->getCollection()->transform(function ($invoice) {
            $invoice->invoice_data_decoded = json_decode($invoice->invoice_data, true);
            return $invoice;
        });
        
        return $this->sendResponse($invoices, 'Invoices retrieved successfully.');
    }

    /**
     * Get specific invoice details
     * 
     * @OA\Get(
     *      path="/api/v1/my-invoices/{id}",
     *      operationId="getMyInvoiceById",
     *      tags={"My Invoices"},
     *      summary="Get invoice details",
     *      description="Returns the details of a specific proforma invoice",
     *      security={{"sanctum": {}}},
     *      @OA\Parameter(
     *          name="id",
     *          description="Invoice id",
     *          required=true,
     *          in="path",
     *          @OA\Schema(type="integer")
     *      ),
     *      @OA\Response(
     *          response=200,
     *          description="Successful operation",
     *       ),
     *      @OA\Response(
     *          response=401,
     *          description="Unauthenticated"
     *      ),
     *      @OA\Response(
     *          response=404,
     *          description="Not Found"
     *      )
     * )
     * 
     * @param Request $request
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function show(Request $request, $id)
    {
        $user = $request->user();
        
        $invoice = ProformaInvoice::where('id', $id)
            ->where('user_id', $user->id)
            ->first();

        if (!$invoice) {
            return $this->sendError('Invoice not found.', [], 404);
        }

        $invoiceData = json_decode($invoice->invoice_data, true);

        return $this->sendResponse([
            'invoice' => $invoice,
            'data' => $invoiceData,
        ], 'Invoice retrieved successfully.');
    }

    /**
     * Download invoice PDF
     * 
     * @OA\Get(
     *      path="/api/v1/my-invoices/{id}/download-pdf",
     *      operationId="downloadMyInvoicePdf",
     *      tags={"My Invoices"},
     *      summary="Download invoice PDF",
     *      description="Download the proforma invoice as PDF",
     *      security={{"sanctum": {}}},
     *      @OA\Parameter(
     *          name="id",
     *          description="Invoice id",
     *          required=true,
     *          in="path",
     *          @OA\Schema(type="integer")
     *      ),
     *      @OA\Response(
     *          response=200,
     *          description="PDF file",
     *          @OA\MediaType(
     *              mediaType="application/pdf"
     *          )
     *       ),
     *      @OA\Response(
     *          response=401,
     *          description="Unauthenticated"
     *      ),
     *      @OA\Response(
     *          response=404,
     *          description="Not Found"
     *      )
     * )
     * 
     * @param Request $request
     * @param int $id
     * @return \Illuminate\Http\Response
     */
    public function downloadPdf(Request $request, $id)
    {
        $user = $request->user();
        
        $invoice = ProformaInvoice::where('id', $id)
            ->where('user_id', $user->id)
            ->first();

        if (!$invoice) {
            return $this->sendError('Invoice not found.', [], 404);
        }

        $invoiceData = json_decode($invoice->invoice_data, true);

        // Prepare data for the PDF view
        $data = [
            'invoice' => $invoice,
            'invoiceData' => $invoiceData,
            'siteTitle' => function_exists('setting') ? setting('site_title', 'Frontend App') : 'Frontend App',
            'companyAddress' => function_exists('setting') ? setting('address', 'Company Address') : 'Company Address',
            'companyEmail' => function_exists('setting') ? setting('email', 'company@example.com') : 'company@example.com',
            'companyPhone' => function_exists('setting') ? setting('phone', '+1 (555) 123-4567') : '+1 (555) 123-4567',
        ];

        // Load the PDF view
        $pdf = Pdf::loadView('frontend.proforma-invoice-pdf', $data);
        $pdf->setPaper('A4', 'portrait');

        return $pdf->download('proforma-invoice-' . $invoice->invoice_number . '.pdf');
    }

    /**
     * Add invoice items back to cart
     * 
     * @OA\Post(
     *      path="/api/v1/my-invoices/{id}/add-to-cart",
     *      operationId="addInvoiceToCart",
     *      tags={"My Invoices"},
     *      summary="Add invoice to cart",
     *      description="Add all items from a proforma invoice back to the cart",
     *      security={{"sanctum": {}}},
     *      @OA\Parameter(
     *          name="id",
     *          description="Invoice id",
     *          required=true,
     *          in="path",
     *          @OA\Schema(type="integer")
     *      ),
     *      @OA\Response(
     *          response=200,
     *          description="Successful operation",
     *       ),
     *      @OA\Response(
     *          response=400,
     *          description="Bad Request"
     *      ),
     *      @OA\Response(
     *          response=401,
     *          description="Unauthenticated"
     *      ),
     *      @OA\Response(
     *          response=404,
     *          description="Not Found"
     *      )
     * )
     * 
     * @param Request $request
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function addToCart(Request $request, $id)
    {
        $user = $request->user();
        
        $invoice = ProformaInvoice::where('id', $id)
            ->where('user_id', $user->id)
            ->first();

        if (!$invoice) {
            return $this->sendError('Invoice not found.', [], 404);
        }

        // Check if invoice is in draft status
        $draftStatus = defined('App\Models\ProformaInvoice::STATUS_DRAFT') 
            ? ProformaInvoice::STATUS_DRAFT 
            : 'draft';
            
        if ($invoice->status !== $draftStatus) {
            return $this->sendError('Only draft invoices can be added to cart.', [], 400);
        }

        $invoiceData = json_decode($invoice->invoice_data, true);
        $addedItems = [];
        $skippedItems = [];

        if (isset($invoiceData['cart_items']) && is_array($invoiceData['cart_items'])) {
            foreach ($invoiceData['cart_items'] as $item) {
                // Check if product still exists and is in stock
                $product = Product::find($item['product_id']);
                
                if (!$product || !$product->in_stock || $product->stock_quantity < $item['quantity']) {
                    $skippedItems[] = $item['product_name'] ?? 'Unknown Product';
                    continue;
                }

                // Add or update cart item
                ShoppingCartItem::updateOrCreate(
                    [
                        'user_id' => $user->id,
                        'product_id' => $item['product_id'],
                    ],
                    [
                        'quantity' => $item['quantity'],
                        'price' => $item['price'],
                    ]
                );
                
                $addedItems[] = $item['product_name'];
            }
        }

        // Delete the invoice after adding items to cart
        $invoice->delete();

        $message = 'Products from invoice added to cart successfully.';
        if (!empty($skippedItems)) {
            $message .= ' Some items were skipped (out of stock or unavailable): ' . implode(', ', $skippedItems);
        }

        return $this->sendResponse([
            'added_items' => $addedItems,
            'skipped_items' => $skippedItems,
            'cart_count' => ShoppingCartItem::where('user_id', $user->id)->count(),
        ], $message);
    }

    /**
     * Delete a proforma invoice
     * 
     * @OA\Delete(
     *      path="/api/v1/my-invoices/{id}",
     *      operationId="deleteMyInvoice",
     *      tags={"My Invoices"},
     *      summary="Delete invoice",
     *      description="Delete a proforma invoice",
     *      security={{"sanctum": {}}},
     *      @OA\Parameter(
     *          name="id",
     *          description="Invoice id",
     *          required=true,
     *          in="path",
     *          @OA\Schema(type="integer")
     *      ),
     *      @OA\Response(
     *          response=200,
     *          description="Successful operation",
     *       ),
     *      @OA\Response(
     *          response=401,
     *          description="Unauthenticated"
     *      ),
     *      @OA\Response(
     *          response=404,
     *          description="Not Found"
     *      )
     * )
     * 
     * @param Request $request
     * @param int $id
     * @return \Illuminate\Http\JsonResponse
     */
    public function destroy(Request $request, $id)
    {
        $user = $request->user();
        
        $invoice = ProformaInvoice::where('id', $id)
            ->where('user_id', $user->id)
            ->first();

        if (!$invoice) {
            return $this->sendError('Invoice not found.', [], 404);
        }

        $invoice->delete();

        return $this->sendResponse(null, 'Invoice deleted successfully.');
    }
}

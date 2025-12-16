<?php

namespace App\Http\Controllers\API;

use App\Models\ProformaInvoice;
use Illuminate\Http\Request;

/**
 * @OA\Tag(
 *     name="Proforma Invoices",
 *     description="API Endpoints for Proforma Invoice Management"
 * )
 */
class ProformaInvoiceController extends ApiController
{
    /**
     * Display a listing of the resource.
     *
     * @OA\Get(
     *      path="/api/v1/proforma-invoices",
     *      operationId="getProformaInvoicesList",
     *      tags={"Proforma Invoices"},
     *      summary="Get list of proforma invoices",
     *      description="Returns list of proforma invoices with pagination",
     *      security={{"sanctum": {}}},
     *      @OA\Parameter(
     *          name="page",
     *          description="Page number",
     *          required=false,
     *          in="query",
     *          @OA\Schema(
     *              type="integer"
     *          )
     *      ),
     *      @OA\Parameter(
     *          name="per_page",
     *          description="Items per page",
     *          required=false,
     *          in="query",
     *          @OA\Schema(
     *              type="integer",
     *              default=15
     *          )
     *      ),
     *      @OA\Parameter(
     *          name="status",
     *          description="Filter by status",
     *          required=false,
     *          in="query",
     *          @OA\Schema(
     *              type="string",
     *              enum={"Draft", "Approved", "Dispatch", "Out for Delivery", "Delivered", "Return"}
     *          )
     *      ),
     *      @OA\Parameter(
     *          name="user_id",
     *          description="Filter by user ID",
     *          required=false,
     *          in="query",
     *          @OA\Schema(
     *              type="integer"
     *          )
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
     *          response=403,
     *          description="Forbidden"
     *      )
     *     )
     */
    public function index(Request $request)
    {
        $query = ProformaInvoice::with('user');
        
        // Filter by status if provided
        if ($request->has('status') && in_array($request->status, ProformaInvoice::STATUS_OPTIONS)) {
            $query->where('status', $request->status);
        }
        
        // Filter by user_id if provided
        if ($request->has('user_id')) {
            $query->where('user_id', $request->user_id);
        }
        
        // Search by invoice number
        if ($request->has('search')) {
            $query->where('invoice_number', 'like', '%' . $request->search . '%');
        }
        
        // Order by latest first
        $query->orderBy('created_at', 'desc');
        
        $perPage = $request->get('per_page', 15);
        $invoices = $query->paginate($perPage);
        
        return $this->sendResponse($invoices, 'Proforma invoices retrieved successfully.');
    }

    /**
     * Store a newly created resource in storage.
     *
     * @OA\Post(
     *      path="/api/v1/proforma-invoices",
     *      operationId="storeProformaInvoice",
     *      tags={"Proforma Invoices"},
     *      summary="Store new proforma invoice",
     *      description="Returns proforma invoice data",
     *      security={{"sanctum": {}}},
     *      @OA\RequestBody(
     *          required=true,
     *          @OA\JsonContent(
     *              required={"invoice_number","total_amount","invoice_data"},
     *              @OA\Property(property="user_id", type="integer", example=1, nullable=true),
     *              @OA\Property(property="session_id", type="string", example="abc123", nullable=true),
     *              @OA\Property(property="invoice_number", type="string", example="PI-2025-001"),
     *              @OA\Property(property="total_amount", type="number", format="float", example=199.99),
     *              @OA\Property(property="status", type="string", example="Draft", enum={"Draft", "Approved", "Dispatch", "Out for Delivery", "Delivered", "Return"}),
     *              @OA\Property(property="invoice_data", type="object", example={"cart_items": [], "subtotal": 100, "total": 199.99}),
     *          ),
     *      ),
     *      @OA\Response(
     *          response=201,
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
     *          response=403,
     *          description="Forbidden"
     *      )
     * )
     */
    public function store(Request $request)
    {
        $request->validate([
            'user_id' => 'nullable|integer|exists:users,id',
            'session_id' => 'nullable|string|max:255',
            'invoice_number' => 'required|string|max:255|unique:proforma_invoices',
            'total_amount' => 'required|numeric|min:0',
            'status' => 'nullable|in:' . implode(',', ProformaInvoice::STATUS_OPTIONS),
            'invoice_data' => 'required|array',
        ]);

        $data = $request->only(['user_id', 'session_id', 'invoice_number', 'total_amount', 'invoice_data']);
        $data['status'] = $request->get('status', ProformaInvoice::STATUS_DRAFT);
        
        $invoice = ProformaInvoice::create($data);

        return $this->sendResponse($invoice->load('user'), 'Proforma invoice created successfully.', 201);
    }

    /**
     * Display the specified resource.
     *
     * @OA\Get(
     *      path="/api/v1/proforma-invoices/{id}",
     *      operationId="getProformaInvoiceById",
     *      tags={"Proforma Invoices"},
     *      summary="Get proforma invoice information",
     *      description="Returns proforma invoice data",
     *      security={{"sanctum": {}}},
     *      @OA\Parameter(
     *          name="id",
     *          description="Proforma invoice id",
     *          required=true,
     *          in="path",
     *          @OA\Schema(
     *              type="integer"
     *          )
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
     *          response=404,
     *          description="Not Found"
     *      )
     * )
     */
    public function show($id)
    {
        $invoice = ProformaInvoice::with('user')->find($id);

        if (is_null($invoice)) {
            return $this->sendError('Proforma invoice not found.');
        }

        return $this->sendResponse($invoice, 'Proforma invoice retrieved successfully.');
    }

    /**
     * Update the specified resource in storage.
     *
     * @OA\Put(
     *      path="/api/v1/proforma-invoices/{id}",
     *      operationId="updateProformaInvoice",
     *      tags={"Proforma Invoices"},
     *      summary="Update existing proforma invoice",
     *      description="Returns updated proforma invoice data",
     *      security={{"sanctum": {}}},
     *      @OA\Parameter(
     *          name="id",
     *          description="Proforma invoice id",
     *          required=true,
     *          in="path",
     *          @OA\Schema(
     *              type="integer"
     *          )
     *      ),
     *      @OA\RequestBody(
     *          required=false,
     *          @OA\JsonContent(
     *              @OA\Property(property="user_id", type="integer", example=1, nullable=true),
     *              @OA\Property(property="invoice_number", type="string", example="PI-2025-001"),
     *              @OA\Property(property="total_amount", type="number", format="float", example=199.99),
     *              @OA\Property(property="status", type="string", example="Approved", enum={"Draft", "Approved", "Dispatch", "Out for Delivery", "Delivered", "Return"}),
     *              @OA\Property(property="invoice_data", type="object", example={"cart_items": [], "subtotal": 100, "total": 199.99}),
     *          ),
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
     *          response=403,
     *          description="Forbidden"
     *      ),
     *      @OA\Response(
     *          response=404,
     *          description="Not Found"
     *      )
     * )
     */
    public function update(Request $request, $id)
    {
        $invoice = ProformaInvoice::find($id);

        if (is_null($invoice)) {
            return $this->sendError('Proforma invoice not found.');
        }

        $request->validate([
            'user_id' => 'nullable|integer|exists:users,id',
            'session_id' => 'nullable|string|max:255',
            'invoice_number' => 'sometimes|string|max:255|unique:proforma_invoices,invoice_number,' . $id,
            'total_amount' => 'sometimes|numeric|min:0',
            'status' => 'sometimes|in:' . implode(',', ProformaInvoice::STATUS_OPTIONS),
            'invoice_data' => 'sometimes|array',
        ]);

        $data = $request->only(['user_id', 'session_id', 'invoice_number', 'total_amount', 'status', 'invoice_data']);
        $invoice->update(array_filter($data, fn($value) => !is_null($value)));

        return $this->sendResponse($invoice->load('user'), 'Proforma invoice updated successfully.');
    }

    /**
     * Update the status of a proforma invoice.
     *
     * @OA\Patch(
     *      path="/api/v1/proforma-invoices/{id}/status",
     *      operationId="updateProformaInvoiceStatus",
     *      tags={"Proforma Invoices"},
     *      summary="Update proforma invoice status",
     *      description="Updates only the status of a proforma invoice",
     *      security={{"sanctum": {}}},
     *      @OA\Parameter(
     *          name="id",
     *          description="Proforma invoice id",
     *          required=true,
     *          in="path",
     *          @OA\Schema(
     *              type="integer"
     *          )
     *      ),
     *      @OA\RequestBody(
     *          required=true,
     *          @OA\JsonContent(
     *              required={"status"},
     *              @OA\Property(property="status", type="string", example="Approved", enum={"Draft", "Approved", "Dispatch", "Out for Delivery", "Delivered", "Return"}),
     *          ),
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
     *          response=404,
     *          description="Not Found"
     *      )
     * )
     */
    public function updateStatus(Request $request, $id)
    {
        $invoice = ProformaInvoice::find($id);

        if (is_null($invoice)) {
            return $this->sendError('Proforma invoice not found.');
        }

        $request->validate([
            'status' => 'required|in:' . implode(',', ProformaInvoice::STATUS_OPTIONS),
        ]);

        $invoice->update(['status' => $request->status]);

        return $this->sendResponse($invoice->load('user'), 'Proforma invoice status updated successfully.');
    }

    /**
     * Remove the specified resource from storage.
     *
     * @OA\Delete(
     *      path="/api/v1/proforma-invoices/{id}",
     *      operationId="deleteProformaInvoice",
     *      tags={"Proforma Invoices"},
     *      summary="Delete proforma invoice",
     *      description="Deletes a proforma invoice",
     *      security={{"sanctum": {}}},
     *      @OA\Parameter(
     *          name="id",
     *          description="Proforma invoice id",
     *          required=true,
     *          in="path",
     *          @OA\Schema(
     *              type="integer"
     *          )
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
     *          response=403,
     *          description="Forbidden"
     *      ),
     *      @OA\Response(
     *          response=404,
     *          description="Not Found"
     *      )
     * )
     */
    public function destroy($id)
    {
        $invoice = ProformaInvoice::find($id);

        if (is_null($invoice)) {
            return $this->sendError('Proforma invoice not found.');
        }

        $invoice->delete();

        return $this->sendResponse(null, 'Proforma invoice deleted successfully.');
    }
}
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
    public function index()
    {
        $invoices = ProformaInvoice::with(['user', 'items.product'])->paginate(15);
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
     *              required={"user_id","invoice_number","total_amount","status"},
     *              @OA\Property(property="user_id", type="integer", example=1),
     *              @OA\Property(property="invoice_number", type="string", example="INV-001"),
     *              @OA\Property(property="total_amount", type="number", format="float", example=199.99),
     *              @OA\Property(property="status", type="string", example="draft"),
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
            'user_id' => 'required|integer|exists:users,id',
            'invoice_number' => 'required|string|max:255|unique:proforma_invoices',
            'total_amount' => 'required|numeric|min:0',
            'status' => 'required|in:draft,sent,paid,cancelled',
        ]);

        $invoice = ProformaInvoice::create($request->all());

        return $this->sendResponse($invoice, 'Proforma invoice created successfully.', 201);
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
        $invoice = ProformaInvoice::with(['user', 'items.product'])->find($id);

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
     *          required=true,
     *          @OA\JsonContent(
     *              required={"user_id","invoice_number","total_amount","status"},
     *              @OA\Property(property="user_id", type="integer", example=1),
     *              @OA\Property(property="invoice_number", type="string", example="INV-001"),
     *              @OA\Property(property="total_amount", type="number", format="float", example=199.99),
     *              @OA\Property(property="status", type="string", example="sent"),
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
            'user_id' => 'required|integer|exists:users,id',
            'invoice_number' => 'required|string|max:255|unique:proforma_invoices,invoice_number,'.$id,
            'total_amount' => 'required|numeric|min:0',
            'status' => 'required|in:draft,sent,paid,cancelled',
        ]);

        $invoice->update($request->all());

        return $this->sendResponse($invoice, 'Proforma invoice updated successfully.');
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
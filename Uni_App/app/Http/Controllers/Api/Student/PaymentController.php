<?php

namespace App\Http\Controllers\Api\Student;

use App\Http\Controllers\Controller;
use App\Http\Resources\PaymentResource;
use App\Models\Semester;
use App\Services\Financial\PaymentService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PaymentController extends Controller
{
    public function __construct(
        private PaymentService $paymentService
    ) {}

    /**
     * Submit a payment receipt.
     * semester_id is optional — defaults to the latest active semester.
     */
    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'amount'        => 'required|numeric|min:0',
            'purpose'       => 'required|string|max:255',
            'receipt_image' => 'required|file|max:5120',
            'semester_id'   => 'nullable|exists:semesters,id',
            'ref_number'    => 'nullable|string|max:100',
        ]);

        try {
            // Auto-resolve semester_id to the latest semester if not provided
            $semesterId = $request->input('semester_id');
            if (!$semesterId) {
                $latestSemester = Semester::orderBy('created_at', 'desc')->first();
                if (!$latestSemester) {
                    return response()->json(['error' => 'لا يوجد فصل دراسي نشط في النظام.'], 422);
                }
                $semesterId = $latestSemester->id;
            }

            $data = $request->only(['amount', 'purpose']);
            $data['semester_id'] = $semesterId;

            // Include optional ref_number in purpose if provided
            if ($request->filled('ref_number')) {
                $data['purpose'] .= ' (مرجع: ' . $request->input('ref_number') . ')';
            }

            $payment = $this->paymentService->submitPayment(
                auth()->user()->student->id,
                $data,
                $request->file('receipt_image')
            );

            return response()->json([
                'message' => 'تم إرسال إيصال الدفع بنجاح',
                'data'    => new PaymentResource($payment),
            ], 201);

        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 400);
        }
    }

    /**
     * Get student's payment history.
     */
    public function index(): JsonResponse
    {
        $payments = $this->paymentService->getStudentPayments(auth()->user()->student->id);
        return response()->json([
            'data' => PaymentResource::collection($payments),
        ]);
    }
}

<?php

namespace App\Http\Controllers\Api\Staff;

use App\Http\Controllers\Controller;
use App\Services\Financial\PaymentVerificationService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PaymentVerificationController extends Controller
{
    public function __construct(
        private PaymentVerificationService $paymentVerificationService
    ) {}

    /**
     * Get pending payments for verification.
     */
    public function index(): JsonResponse
    {
        $payments = $this->paymentVerificationService->getPendingPayments();

        return response()->json(['data' => $payments]);
    }

    /**
     * Verify a payment.
     */
    public function verify(Request $request, int $id): JsonResponse
    {
        $request->validate([
            'notes' => 'nullable|string',
        ]);

        try {
            $this->paymentVerificationService->verifyPayment($id);

            return response()->json([
                'message' => 'Payment verified successfully'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'error' => $e->getMessage()
            ], 400);
        }
    }

    /**
     * Reject a payment.
     */
    public function reject(Request $request, int $id): JsonResponse
    {
        $request->validate([
            'notes' => 'required|string',
        ]);

        try {
            $this->paymentVerificationService->rejectPayment(
                $id,
                $request->notes
            );

            return response()->json([
                'message' => 'Payment rejected'
            ]);
        } catch (\Exception $e) {
            return response()->json([
                'error' => $e->getMessage()
            ], 400);
        }
    }
}

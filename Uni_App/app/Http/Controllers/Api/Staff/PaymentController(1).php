<?php

namespace App\Http\Controllers\Api\Staff;

use App\Http\Controllers\Controller;
use App\Http\Resources\PaymentResource;
use App\Services\Financial\PaymentVerificationService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use App\Filters\PaymentFilter;

class PaymentController extends Controller
{
    public function __construct(
        private PaymentVerificationService $paymentVerificationService
    ) {}

    /**
     * List all payments.
     */
    public function index(Request $request): JsonResponse
    {
        $payments = \App\Models\Payment::with(['student.user', 'semester'])
            ->filter(new PaymentFilter($request))
            ->latest()
            ->get();

        return response()->json([
            'data' => PaymentResource::collection($payments)
        ]);
    }

    /**
     * Verify a payment.
     */
    public function verify(int $id): JsonResponse
    {
        try {
            $this->paymentVerificationService->verifyPayment($id);
            return response()->json(['message' => 'Payment verified successfully']);
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 400);
        }
    }

    /**
     * Reject a payment.
     */
    public function reject(Request $request, int $id): JsonResponse
    {
        $request->validate([
            'reason' => 'nullable|string|max:255',
            'notes' => 'nullable|string|max:255',
        ]);

        $rejectionReason = $request->input('notes') ?? $request->input('reason');
        
        if (!$rejectionReason) {
            return response()->json(['error' => 'A rejection reason is required.'], 422);
        }

        try {
            $this->paymentVerificationService->rejectPayment($id, $rejectionReason);
            return response()->json(['message' => 'Payment rejected successfully']);
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 400);
        }
    }
}

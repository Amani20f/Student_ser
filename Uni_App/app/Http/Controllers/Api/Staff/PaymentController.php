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

        $status = $request->input('status');
        $search = $request->input('search');
        $programId = $request->input('program_id');
        $currentLevel = $request->input('current_level');
        $fromDate = $request->input('from_date');
        $toDate = $request->input('to_date');

        // Check if we should include admissions
        $includeAdmissions = true;
        if ($status && $status !== 'pending') {
            $includeAdmissions = false;
        }

        $apps = collect();
        if ($includeAdmissions) {
            $appQuery = \App\Models\StudentApplication::with('desiredProgram')
                ->where('application_status', 'pending')
                ->whereNotNull('payment_receipt_path');

            if ($search) {
                $appQuery->where(function ($q) use ($search) {
                    $q->where('full_name', 'like', "%{$search}%")
                      ->orWhere('application_number', 'like', "%{$search}%");
                });
            }

            if ($programId) {
                $appQuery->where('desired_program_id', $programId);
            }

            if ($currentLevel) {
                $appQuery->where('desired_academic_level', $currentLevel);
            }

            if ($fromDate) {
                $appQuery->where('created_at', '>=', $fromDate . ' 00:00:00');
            }
            if ($toDate) {
                $appQuery->where('created_at', '<=', $toDate . ' 23:59:59');
            }

            $apps = $appQuery->latest()->get();
        }

        $mappedApps = $apps->map(function ($app) {
            return [
                'id'               => -$app->id,
                'student'          => [
                    'id'   => null,
                    'name' => $app->full_name,
                ],
                'semester'         => [
                    'id'            => null,
                    'academic_year' => null,
                    'term'          => null,
                ],
                'amount'           => 100.0,
                'purpose'          => 'رسوم طلب قبول - ' . ($app->desiredProgram->name ?? 'جديد'),
                'receipt_image'    => $app->payment_receipt_path ? url('storage/' . $app->payment_receipt_path) : null,
                'status'           => 'pending',
                'rejection_reason' => $app->rejection_reason,
                'appeal_id'        => null,
                'request_id'       => null,
                'created_at'       => $app->created_at->toDateTimeString(),
                'updated_at'       => $app->updated_at->toDateTimeString(),
            ];
        });

        $paymentsData = PaymentResource::collection($payments)->resolve();
        $merged = collect($paymentsData)->concat($mappedApps);

        return response()->json([
            'data' => $merged
        ]);
    }

    /**
     * Verify a payment.
     */
    public function verify(int $id): JsonResponse
    {
        if ($id < 0) {
            $appId = abs($id);
            $app = \App\Models\StudentApplication::findOrFail($appId);
            if ($app->application_status !== 'pending') {
                return response()->json([
                    'error' => 'لا يمكن التحقق من الدفع لأن حالة الطلب ليست قيد الانتظار.',
                ], 400);
            }
            $app->update([
                'application_status' => 'payment_verified',
            ]);
            return response()->json(['message' => 'Application payment verified successfully']);
        }

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

        if ($id < 0) {
            $appId = abs($id);
            $app = \App\Models\StudentApplication::findOrFail($appId);
            $app->update([
                'application_status' => 'rejected',
                'rejection_reason'   => $rejectionReason,
            ]);
            return response()->json(['message' => 'Application payment rejected successfully']);
        }

        try {
            $this->paymentVerificationService->rejectPayment($id, $rejectionReason);
            return response()->json(['message' => 'Payment rejected successfully']);
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 400);
        }
    }
}

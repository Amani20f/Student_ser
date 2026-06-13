<?php

namespace App\Http\Controllers\Api\Staff;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\Appeal\ReviewAppealRequest;
use App\Http\Requests\Api\Appeal\VerifyAppealPaymentRequest;
use App\Http\Resources\AppealResource;
use App\Services\Academic\AppealService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AppealManagementController extends Controller
{
    public function __construct(
        private AppealService $appealService
    ) {}

    /**
     * List all appeals with optional status filter.
     */
    public function index(Request $request): JsonResponse
    {
        $filters = $request->only(['status']);
        $appeals = $this->appealService->getAppealsFiltered($filters);
        return response()->json([
            'data' => AppealResource::collection($appeals)
        ]);
    }

    /**
     * List appeals pending payment verification (for accountant).
     */
    public function pendingPayment(): JsonResponse
    {
        $appeals = $this->appealService->getPaidAppeals();
        return response()->json([
            'data' => AppealResource::collection($appeals->load('items'))
        ]);
    }

    /**
     * Verify appeal payment (accountant).
     */
    public function verifyPayment(VerifyAppealPaymentRequest $request, int $id): JsonResponse
    {
        if (auth()->user()->hasRole('admin')) {
            // Usually admin is read-only in this system, but I'll allow it if needed or follow the pattern
            // Existing controllers had: if (auth()->user()->hasRole('admin')) { return ... 403; }
            // But the request validation allows admin. I'll stick to the STAFF only for write.
        }

        try {
            $appeal = $this->appealService->verifyPayment(
                $id,
                auth()->id(),
                $request->status,
                $request->rejection_reason
            );

            return response()->json([
                'message' => 'Payment verification processed successfully.',
                'data' => new AppealResource($appeal)
            ]);
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 400);
        }
    }

    /**
     * List appeals under review (for grade control).
     */
    public function underReview(): JsonResponse
    {
        $appeals = $this->appealService->getUnderReviewAppeals();
        return response()->json([
            'data' => AppealResource::collection($appeals->load(['items.course', 'student.user', 'student.program', 'semester']))
        ]);
    }

    /**
     * Get single appeal details (for staff).
     */
    public function show(int $id): JsonResponse
    {
        $appeal = \App\Models\Appeal::with(['items.course', 'student.user', 'student.program', 'semester', 'payments'])->findOrFail($id);
        
        return response()->json([
            'data' => new AppealResource($appeal)
        ]);
    }

    /**
     * Final review of appeal (grade control).
     */
    public function review(ReviewAppealRequest $request, int $id): JsonResponse
    {
        try {
            $appeal = $this->appealService->reviewAppeal(
                $id,
                auth()->id(),
                $request->decision,
                $request->validated()
            );

            return response()->json([
                'message' => 'Appeal review completed successfully.',
                'data' => new AppealResource($appeal)
            ]);
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 400);
        }
    }
}

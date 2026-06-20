<?php

namespace App\Http\Controllers\Api\Student;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\Appeal\StoreAppealRequest;
use App\Http\Requests\Api\Appeal\StoreAppealPaymentRequest;
use App\Http\Resources\AppealResource;
use App\Http\Resources\PaymentResource;
use App\Services\Academic\AppealService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AppealController extends Controller
{
    public function __construct(
        private AppealService $appealService
    ) {}

    /**
     * Get student's grade appeals.
     */
    public function index(): JsonResponse
    {
        $student = auth()->user()->student;
        $appeals = $this->appealService->getPaidAppeals(); // This was probably meant for staff, let's use repository or add method to service
        
        // I'll add getStudentAppeals to service or use repository directly if needed, but better in service
        // Actually, I'll just use the repository via the service if I add the method
        
        // Re-injecting logic into service... wait. I'll just use the repository for index here or add to service.
        // Let's add getStudentAppeals to AppealService first.
        
        $appeals = \App\Models\Appeal::where('student_id', $student->id)
            ->with(['items.course', 'semester', 'payments'])
            ->latest()
            ->get();

        return response()->json([
            'data' => AppealResource::collection($appeals->loadMissing('items'))
        ]);
    }

    /**
     * Show a specific appeal.
     */
    public function show(int $id): JsonResponse
    {
        $appeal = \App\Models\Appeal::with(['items.course', 'semester', 'payments'])->findOrFail($id);
        $this->authorize('view', $appeal);

        return response()->json([
            'data' => new AppealResource($appeal)
        ]);
    }

    /**
     * Submit a new grade appeal.
     */
    public function store(StoreAppealRequest $request): JsonResponse
    {
        try {
            $student = auth()->user()->student;
            if ($student && $student->status === \App\Enums\StudentStatusEnum::SUSPENDED) {
                return response()->json([
                    'error' => 'عذراً، لا يمكنك تقديم تظلم لأن حسابك موقوف أكاديمياً.'
                ], 403);
            }
            $data = $request->validated();
            
            if (empty($data['semester_id'])) {
                $latestSemester = \App\Models\Semester::orderBy('created_at', 'desc')->first();
                if (!$latestSemester) {
                    throw new \Exception('لا يوجد فصل دراسي متاح للتظلم.');
                }
                $data['semester_id'] = $latestSemester->id;
            }

            $attachmentPaths = [];

            if ($request->hasFile('attachments')) {
                foreach ($request->file('attachments') as $file) {
                    $attachmentPaths[] = $file->store('appeals/attachments', 'public');
                }
            }
            $data['attachment_paths'] = $attachmentPaths;

            $appeal = $this->appealService->createAppeal(
                auth()->user()->student,
                $data
            );

            return response()->json([
                'message' => 'Grievance submitted successfully. Please proceed to payment.',
                'data' => new AppealResource($appeal->load('items'))
            ], 201);
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 400);
        }
    }

    /**
     * Submit payment receipt for an appeal.
     */
    public function submitPayment(StoreAppealPaymentRequest $request): JsonResponse
    {
        try {
            $payment = $this->appealService->submitAppealPayment(
                auth()->user()->student,
                $request->validated(),
                $request->file('receipt_image')
            );

            return response()->json([
                'message' => 'Payment receipt submitted successfully.',
                'data' => new PaymentResource($payment)
            ]);
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 400);
        }
    }
}

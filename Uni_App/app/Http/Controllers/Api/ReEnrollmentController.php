<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Http\Requests\Request\StoreReEnrollmentRequest;
use App\Http\Requests\Request\RatifyReEnrollmentRequest;
use App\Http\Resources\RequestResource;
use App\Models\Request;
use App\Services\Request\ReEnrollmentService;
use Illuminate\Http\JsonResponse;
use Exception;

class ReEnrollmentController extends Controller
{
    public function __construct(
        private ReEnrollmentService $reEnrollmentService
    ) {}

    /**
     * Student submits re-enrollment request with two file uploads.
     * 
     * POST /api/student/re-enrollment
     */
    public function store(StoreReEnrollmentRequest $request): JsonResponse
    {
        try {
            $student = auth()->user()->student;
            
            if (!$student) {
                return response()->json([
                    'error' => 'لم يتم العثور على بيانات الطالب.'
                ], 404);
            }

            $reEnrollmentRequest = $this->reEnrollmentService->submitReEnrollment(
                data: $request->only(['request_type_id', 'description']),
                student: $student,
                suspensionForm: $request->file('suspension_form'),
                universityId: $request->file('university_id')
            );

            return response()->json([
                'message' => 'تم تقديم طلب إعادة القيد بنجاح.',
                'data' => new RequestResource($reEnrollmentRequest)
            ], 201);
        } catch (Exception $e) {
            return response()->json([
                'error' => $e->getMessage()
            ], 422);
        }
    }

    /**
     * Staff ratifies re-enrollment request by adding data to form_data.
     * Can be called by Student Affairs or Accountant.
     * 
     * PUT /api/staff/re-enrollment/{id}/ratify
     */
    public function ratify(RatifyReEnrollmentRequest $request, int $id): JsonResponse
    {
        try {
            $reEnrollmentRequest = Request::findOrFail($id);
            $user = auth()->user();

            // Check if user has student_affairs or accountant role
            $hasStudentAffairsRole = $user->hasRole(['student_affairs', 'admin']);
            $hasAccountantRole = $user->hasRole(['accountant', 'admin']);

            // Determine which fields to update based on role
            $data = $request->validated();

            if ($hasStudentAffairsRole && array_intersect_key($data, array_flip(['major', 'level', 'batch', 'academic_year']))) {
                // Student Affairs ratification
                $this->reEnrollmentService->ratifyByStudentAffairs(
                    $reEnrollmentRequest,
                    $data,
                    $user
                );
                $message = 'تم التصديق من قبل شؤون الطلاب بنجاح.';
            } elseif ($hasAccountantRole && array_intersect_key($data, array_flip(['university_fees', 'other_fees']))) {
                // Accountant ratification
                $this->reEnrollmentService->ratifyByAccountant(
                    $reEnrollmentRequest,
                    $data,
                    $user
                );
                $message = 'تم التصديق من قبل المحاسب بنجاح.';
            } else {
                return response()->json([
                    'error' => 'يجب توفير بيانات صالحة للتصديق.'
                ], 422);
            }

            return response()->json([
                'message' => $message,
                'data' => new RequestResource($reEnrollmentRequest->fresh())
            ]);
        } catch (Exception $e) {
            return response()->json([
                'error' => $e->getMessage()
            ], 422);
        }
    }

    /**
     * Approve re-enrollment request - triggers automatic status restoration.
     * 
     * PUT /api/staff/re-enrollment/{id}/approve
     */
    public function approve(int $id): JsonResponse
    {
        try {
            $request = Request::findOrFail($id);
            $user = auth()->user();

            $this->reEnrollmentService->approveReEnrollment($request, $user);

            return response()->json([
                'message' => 'تمت الموافقة على طلب إعادة القيد. تم تحديث حالة الطالب تلقائياً.',
                'data' => new RequestResource($request->fresh())
            ]);
        } catch (Exception $e) {
            return response()->json([
                'error' => $e->getMessage()
            ], 422);
        }
    }

    /**
     * Get re-enrollment details for a specific request.
     * 
     * GET /api/staff/re-enrollment/{id}
     */
    public function show(int $id): JsonResponse
    {
        try {
            $request = Request::with(['student.user', 'requestType', 'processedBy', 'reEnrollmentDetail'])->findOrFail($id);
            
            $details = $this->reEnrollmentService->getReEnrollmentDetails($request);

            return response()->json([
                'data' => new RequestResource($request),
                'details' => $details
            ]);
        } catch (Exception $e) {
            return response()->json([
                'error' => $e->getMessage()
            ], 404);
        }
    }
}

<?php

namespace App\Http\Controllers\Api\Student;

use App\Http\Controllers\Controller;
use App\Http\Resources\RequestResource;
use App\Services\Support\ServiceRequestService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class RequestController extends Controller
{
    public function __construct(
        private ServiceRequestService $serviceRequestService
    ) {}

    /**
     * Submit a new service request.
     */
    public function store(Request $request): JsonResponse
    {
        $request->validate([
            'request_type_id' => 'required|exists:request_types,id',
            'description' => 'nullable|string', // Description might be null if reason is used
            'attachment' => 'nullable|file|max:5120', // 5MB Max
            
            // Absence Excuse fields
            'academic_year' => 'nullable|string',
            'semester' => 'nullable|in:fall,spring,summer',
            'reason' => 'nullable|string',
            'items' => 'nullable|array',
            'items.*.course_name' => 'required_with:items|string',
            'items.*.absence_date' => 'required_with:items|date',
            'items.*.day' => 'required_with:items|string',
        ]);

        try {
            // Check if this is an absence excuse request
            // For now, we rely on the presence of 'items' or we could check the request type slug if available.
            // As per instructions, "The student submits... array of courses".
            
            if ($request->has('items') && is_array($request->items)) {
                $serviceRequest = $this->serviceRequestService->submitAbsenceExcuse(
                    auth()->user()->student->id,
                    $request->only(['request_type_id', 'description', 'academic_year', 'semester', 'reason']),
                    $request->file('attachment'),
                    $request->input('items')
                );
            } else {
                $serviceRequest = $this->serviceRequestService->submitRequest(
                    auth()->user()->student->id,
                    $request->only(['request_type_id', 'description']),
                    $request->file('attachment')
                );
            }

            return response()->json([
                'message' => 'Service request submitted successfully',
                'data' => new RequestResource($serviceRequest)
            ], 201);
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 400);
        }
    }

    /**
     * Get student's request history.
     */
    public function index(): JsonResponse
    {
        $requests = $this->serviceRequestService->getStudentRequests(auth()->user()->student->id);
        return response()->json([
            'data' => RequestResource::collection($requests)
        ]);
    }
}

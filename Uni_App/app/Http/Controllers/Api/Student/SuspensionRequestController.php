<?php

namespace App\Http\Controllers\Api\Student;

use App\Enums\RequestStatusEnum;
use App\Http\Controllers\Controller;
use App\Http\Requests\Request\StoreSuspensionRequest;
use App\Models\RequestType;
use App\Services\Request\SuspensionRequestService;
use Illuminate\Http\JsonResponse;

class SuspensionRequestController extends Controller
{
    public function __construct(
        private SuspensionRequestService $suspensionService
    ) {}

    /**
     * Submit an academic suspension request.
     */
    public function store(StoreSuspensionRequest $request): JsonResponse
    {
        try {
            $student = $request->user()->student;
            $requestType = RequestType::where('slug', 'suspension_of_enrollment')->first();

            if (!$requestType || !$requestType->is_active) {
                return response()->json(['message' => 'Academic suspension service is currently unavailable.'], 403);
            }

            // Manually add the request_type_id to the data
            $data = $request->validated();
            $data['request_type_id'] = $requestType->id;

            // Handle file upload if any
            if ($request->hasFile('attachment')) {
                $path = $request->file('attachment')->store('requests', 'public');
                $data['attachment'] = ['attachment' => $path]; // Keep it consistent with existing attachment array
            }

            $serviceRequest = $this->suspensionService->createSuspensionRequest($data, $student);

            return response()->json([
                'message' => 'Academic suspension request submitted successfully',
                'data' => [
                    'id' => $serviceRequest->id,
                    'status' => 'pending',
                ]
            ], 201);

        } catch (\Exception $e) {
            return response()->json(['message' => $e->getMessage()], 400);
        }
    }

    /**
     * Get all suspension requests for the student.
     */
    public function index(): JsonResponse
    {
        $student = request()->user()->student;

        $requests = \App\Models\Request::with(['requestType', 'processedBy'])
            ->where('student_id', $student->id)
            ->whereHas('requestType', function ($q) {
                $q->where('slug', 'suspension_of_enrollment');
            })
            ->latest()
            ->paginate(10);

        $mappedData = $requests->map(function ($req) {
            return $this->formatRequest($req);
        });

        return response()->json([
            'data' => $mappedData,
            'meta' => [
                'current_page' => $requests->currentPage(),
                'last_page'    => $requests->lastPage(),
                'per_page'     => $requests->perPage(),
                'total'        => $requests->total(),
            ]
        ]);
    }

    /**
     * Get a specific suspension request.
     */
    public function show($id): JsonResponse
    {
        $student = request()->user()->student;

        try {
            $req = \App\Models\Request::with(['requestType', 'processedBy'])
                ->where('student_id', $student->id)
                ->whereHas('requestType', function ($q) {
                    $q->where('slug', 'suspension_of_enrollment');
                })
                ->findOrFail($id);

            return response()->json([
                'data' => $this->formatRequest($req)
            ]);
        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            return response()->json(['message' => 'Suspension request not found.'], 404);
        }
    }

    /**
     * Format the request data for API response.
     */
    private function formatRequest(\App\Models\Request $req): array
    {
        $processedByData = null;
        if ($req->processedBy) {
            $processedByData = [
                'name' => $req->processedBy->name,
                'role' => $req->processedBy->role ?? 'staff',
            ];
        }

        $details = $this->suspensionService->getSuspensionDetails($req);

        return [
            'id'                       => $req->id,
            'request_type'             => $req->requestType->name ?? 'Unknown',
            'suspension_reason'        => $details['suspension_reason'] ?? null,
            'start_semester_id'        => $details['start_semester_id'] ?? null,
            'duration_semesters'       => $details['duration_semesters'] ?? null,
            'expected_end_semester_id' => $details['expected_end_semester_id'] ?? null,
            'notes'                    => $details['notes'] ?? null,
            'attachment'               => $req->attachment,
            'status'                   => $req->status instanceof RequestStatusEnum 
                                            ? $req->status->value 
                                            : (string) $req->status,
            'created_at'               => $req->created_at->toDateTimeString(),
            'updated_at'               => $req->updated_at->toDateTimeString(),
            'processed_by'             => $processedByData,
            'processed_at'             => $processedByData ? $req->updated_at->toDateTimeString() : null,
            'response'                 => $req->admin_notes,
        ];
    }
}

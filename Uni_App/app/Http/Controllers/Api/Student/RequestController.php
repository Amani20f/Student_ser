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
            $requestType = \App\Models\RequestType::find($request->input('request_type_id'));
            if ($requestType && !$requestType->is_active) {
                return response()->json(['error' => 'This service is currently unavailable.'], 403);
            }

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
     * Get student's request history with pagination.
     */
    public function index(): JsonResponse
    {
        $requests = \App\Models\Request::with('requestType')
            ->where('student_id', auth()->user()->student->id)
            ->latest()
            ->paginate(10);

        $mappedData = $requests->map(function ($req) {
            return [
                'id'           => $req->id,
                'request_type' => $req->requestType->name ?? 'Unknown',
                'status'       => $req->status instanceof \App\Enums\RequestStatusEnum 
                                    ? $req->status->value 
                                    : (string) $req->status,
                'created_at'   => $req->created_at->toDateTimeString(),
                'updated_at'   => $req->updated_at->toDateTimeString(),
            ];
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
     * Get details of a specific request.
     */
    public function show($id): JsonResponse
    {
        try {
            $req = \App\Models\Request::with(['requestType', 'processedBy'])
                ->where('student_id', auth()->user()->student->id)
                ->findOrFail($id);

            $processedByData = null;
            if ($req->processedBy) {
                $processedByData = [
                    'name' => $req->processedBy->name,
                    'role' => $req->processedBy->role ?? 'staff',
                ];
            }

            return response()->json([
                'data' => [
                    'id'           => $req->id,
                    'request_type' => $req->requestType->name ?? 'Unknown',
                    'description'  => $req->description,
                    'attachment'   => $req->attachment,
                    'status'       => $req->status instanceof \App\Enums\RequestStatusEnum 
                                        ? $req->status->value 
                                        : (string) $req->status,
                    'created_at'   => $req->created_at->toDateTimeString(),
                    'updated_at'   => $req->updated_at->toDateTimeString(),
                    'processed_by' => $processedByData,
                    'processed_at' => $processedByData ? $req->updated_at->toDateTimeString() : null,
                    'response'     => $req->admin_notes,
                ]
            ]);
        } catch (\Illuminate\Database\Eloquent\ModelNotFoundException $e) {
            return response()->json(['message' => 'Request not found.'], 404);
        }
    }
}

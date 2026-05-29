<?php

namespace App\Http\Controllers\Api\Staff;

use App\Enums\RequestStatusEnum;
use App\Http\Controllers\Controller;
use App\Http\Resources\RequestResource;
use App\Services\Support\ServiceRequestService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use App\Filters\RequestFilter;

class RequestController extends Controller
{
    public function __construct(
        private ServiceRequestService $serviceRequestService
    ) {}
    public function index(Request $request): JsonResponse
    {
        $user = auth()->user();

        $query = \App\Models\Request::with([
            'student.user', 
            'student.program',
            'requestType', 
            'processedBy',
            'absenceExcuse.items.course'
        ])
            ->filter(new RequestFilter($request));

        if (!$user->hasRole('admin')) {
            $userRoles = $user->getRoleNames();
            $query->whereHas('requestType', function ($q) use ($userRoles) {
                $q->whereIn('target_role', $userRoles);
            });
        }

        return response()->json([
            'data' => RequestResource::collection(
                $query->latest()->get()
            )
        ]);
    }

    /**
     * Update request status.
     */
    /**
     * Update request status.
     */
    public function updateStatus(Request $request, int $id): JsonResponse
    {
        if (auth()->user()->hasRole('admin')) {
            return response()->json(['message' => 'Admin is read-only'], 403);
        }

        $request->validate([
            'status' => 'required|in:approved,rejected',
            'response_message' => 'nullable|string',
        ]);

        try {
            $status = RequestStatusEnum::from($request->status);
            $this->serviceRequestService->updateStatus(
                $id, 
                $status, 
                auth()->id(),
                $request->input('response_message')
            );
            
            $serviceRequest = \App\Models\Request::with('student.user')->find($id);
            if ($serviceRequest && $serviceRequest->student && $serviceRequest->student->user) {
                $user = $serviceRequest->student->user;
                $message = '';
                
                if ($request->status === 'approved') {
                    $message = "تمت الموافقة على طلبك ✅";
                } elseif ($request->status === 'rejected') {
                    $message = "تم رفض طلبك ❌";
                }

                if ($message !== '') {
                    $notification = \App\Models\Notification::create([
                        'title' => 'تحديث حالة الطلب',
                        'message' => $message,
                        'target_type' => 'student',
                        'related_type' => \App\Models\Request::class,
                        'related_id' => $serviceRequest->id,
                    ]);

                    $notification->users()->attach($user->id);
                }
            }
            
            return response()->json(['message' => 'Request status updated successfully']);
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 400);
        }
    }

    /**
     * Ratify an absence excuse request.
     */
    public function ratify(Request $request, int $id): JsonResponse
    {
        if (auth()->user()->hasRole('admin')) {
            return response()->json(['message' => 'Admin is read-only'], 403);
        }

        $request->validate([
            'items' => 'required|array',
            'items.*.id' => 'required|exists:absence_excuse_items,id',
            'items.*.prev_excused_count' => 'nullable|integer|min:0',
            'items.*.prev_unexcused_count' => 'nullable|integer|min:0',
            'response_message' => 'nullable|string',
        ]);

        try {
            $this->serviceRequestService->ratifyAbsenceExcuse(
                $id,
                $request->input('items'),
                auth()->id(),
                $request->input('response_message')
            );

            return response()->json(['message' => 'Absence excuse ratified successfully']);
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 400);
        }
    }
}

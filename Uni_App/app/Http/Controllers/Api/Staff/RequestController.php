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
            $userRoles = $user->getRoleNames()->toArray();
            
            $query->where(function ($q) use ($userRoles) {
                if (in_array('student_affairs', $userRoles)) {
                    $q->whereHas('requestType', function ($q2) {
                        $q2->where('target_role', 'student_affairs');
                    })->where(function ($q3) {
                        $q3->whereDoesntHave('requestType', function ($q4) {
                            $q4->whereIn('slug', ['suspension_of_enrollment', 'tagyl-dras', 're_enrollment']);
                        })->orWhere('status', '!=', \App\Enums\RequestStatusEnum::PENDING);
                    });
                }

                if (in_array('accountant', $userRoles)) {
                    $method = in_array('student_affairs', $userRoles) ? 'orWhere' : 'where';
                    $q->$method(function ($q3) {
                        $q3->whereHas('requestType', function ($q4) {
                            $q4->whereIn('slug', ['suspension_of_enrollment', 'tagyl-dras', 're_enrollment']);
                        })->where('status', \App\Enums\RequestStatusEnum::PENDING);
                    });
                }
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
            $reqModel = \App\Models\Request::with('requestType')->findOrFail($id);
            $user = auth()->user();

            // Block Student Affairs from approving if payment status != approved (verified)
            if ($request->status === 'approved' && $user->hasRole('student_affairs')) {
                $linkedPayment = $reqModel->payment()->first();
                if ($linkedPayment && $linkedPayment->status->value !== 'verified') {
                    throw new \Exception('لا يمكن قبول الطلب قبل اعتماد عملية الدفع من المحاسب.');
                }
            }
            
            // Suspension interception
            if ($reqModel->requestType && ($reqModel->requestType->slug === 'suspension_of_enrollment' || $reqModel->requestType->slug === 'tagyl-dras')) {
                $suspensionService = app(\App\Services\Request\SuspensionRequestService::class);
                
                if ($user->hasRole(['accountant', 'admin']) && $request->status === 'approved') {
                    // Accountant ratification
                    $suspensionService->ratifySuspension($reqModel, $user, true, $request->input('response_message'));
                    return response()->json(['message' => 'تم التصديق على طلب الإيقاف مالياً.']);
                }
                
                if ($user->hasRole(['student_affairs', 'admin'])) {
                    if ($request->status === 'approved') {
                        if ($reqModel->status !== RequestStatusEnum::RATIFIED && $reqModel->status->value !== 'ratified') {
                            throw new \Exception('لا يمكن الموافقة النهائية قبل تصديق المحاسب.');
                        }
                        $suspensionService->approveSuspension($reqModel, $user, $request->input('response_message'));
                        return response()->json(['message' => 'تمت الموافقة النهائية على طلب الإيقاف.']);
                    }
                }
            }

            $status = RequestStatusEnum::from($request->status);
            $this->serviceRequestService->updateStatus(
                $id, 
                $status, 
                auth()->id(),
                $request->input('response_message')
            );
            
            // Notification is now handled exclusively by ServiceRequestService

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

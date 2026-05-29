<?php

namespace App\Http\Controllers\Api\Admin;

use App\Enums\PaymentStatusEnum;
use App\Enums\RequestStatusEnum;
use App\Http\Controllers\Controller;
use App\Models\Payment;
use App\Models\Request;
use App\Models\Student;
use App\Repositories\Contracts\ActivityLogRepositoryInterface;
use Illuminate\Http\JsonResponse;

class AdminController extends Controller
{
    public function __construct(
        private ActivityLogRepositoryInterface $activityLogRepository
    ) {}

    /**
     * Get system-wide dashboard statistics.
     */
    public function getStats(): JsonResponse
    {
        return response()->json([
            'pending_payments' => Payment::where('status', PaymentStatusEnum::PENDING)->count(),
            'pending_requests' => Request::where('status', RequestStatusEnum::PENDING)->count(),
            'total_students' => Student::count(),
            'total_revenue' => Payment::where('status', PaymentStatusEnum::VERIFIED)->sum('amount'),
        ]);
    }

    /**
     * Get global activity logs with optional date-range and action filters.
     */
    public function getLogs(\Illuminate\Http\Request $request): JsonResponse
    {
        $filters = [];
        if ($request->filled('from')) {
            $filters['from'] = \Carbon\Carbon::parse($request->from)->startOfDay();
        }
        if ($request->filled('to')) {
            $filters['to'] = \Carbon\Carbon::parse($request->to)->endOfDay();
        }
        if ($request->filled('action')) {
            $filters['action'] = $request->action;
        }

        $logs = $this->activityLogRepository->getRecentActions(1000, $filters);

        $formattedLogs = $logs->map(fn($log) => [
            'id'          => $log->id,
            'causer'      => $log->causer->name ?? 'System',
            'action'      => $log->action,
            'subjectType' => class_basename($log->model_type),
            'subjectId'   => $log->subject_id,
            'oldValues'   => $log->old_values,
            'newValues'   => $log->new_values,
            'createdAt'   => $log->created_at,
        ]);

        return response()->json(['data' => $formattedLogs]);
    }
}

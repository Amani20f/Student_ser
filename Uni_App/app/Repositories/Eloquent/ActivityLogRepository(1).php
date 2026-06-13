<?php

namespace App\Repositories\Eloquent;

use App\Models\ActivityLog;
use App\Repositories\Contracts\ActivityLogRepositoryInterface;
use Illuminate\Database\Eloquent\Collection;

class ActivityLogRepository implements ActivityLogRepositoryInterface
{
    public function create(array $data): ActivityLog
    {
        return ActivityLog::create($data);
    }

    public function getByCauser(int $causerId, int $limit = 50): Collection
    {
        return ActivityLog::where('causer_id', $causerId)
            ->orderBy('created_at', 'desc')
            ->limit($limit)
            ->get();
    }

    public function getBySubject(string $modelType, int $subjectId): Collection
    {
        return ActivityLog::where('model_type', $modelType)
            ->where('subject_id', $subjectId)
            ->with('causer')
            ->orderBy('created_at', 'desc')
            ->get();
    }

    public function getRecentActions(int $limit = 100, array $filters = []): Collection
    {
        $query = ActivityLog::with('causer');

        if (isset($filters['from'])) {
            $query->where('created_at', '>=', $filters['from']);
        }
        if (isset($filters['to'])) {
            $query->where('created_at', '<=', $filters['to']);
        }
        if (isset($filters['action'])) {
            $query->where('action', $filters['action']);
        }

        return $query->orderBy('created_at', 'desc')
            ->limit($limit)
            ->get();
    }

    public function detectSuspiciousActivity(int $causerId, string $modelType, int $timeWindowMinutes = 10): Collection
    {
        return ActivityLog::where('causer_id', $causerId)
            ->where('model_type', $modelType)
            ->where('created_at', '>=', now()->subMinutes($timeWindowMinutes))
            ->orderBy('created_at', 'desc')
            ->get();
    }
}

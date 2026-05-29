<?php

namespace App\Repositories\Contracts;

use App\Models\ActivityLog;
use Illuminate\Database\Eloquent\Collection;

interface ActivityLogRepositoryInterface
{
    public function create(array $data): ActivityLog;
    
    public function getByCauser(int $causerId, int $limit = 50): Collection;
    
    public function getBySubject(string $modelType, int $subjectId): Collection;
    
    public function getRecentActions(int $limit = 100, array $filters = []): Collection;
    
    public function detectSuspiciousActivity(int $causerId, string $modelType, int $timeWindowMinutes = 10): Collection;
}

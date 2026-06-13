<?php

namespace App\Observers;

use App\Models\Grade;
use App\Repositories\Contracts\ActivityLogRepositoryInterface;

class GradeObserver
{
    public function __construct(
        private ActivityLogRepositoryInterface $activityLogRepository
    ) {}

    /**
     * Handle the Grade "created" event.
     */
    public function created(Grade $grade): void
    {
        $this->activityLogRepository->create([
            'causer_id' => auth()->id(),
            'model_type' => Grade::class,
            'subject_id' => $grade->id,
            'action' => 'created',
            'old_values' => null,
            'new_values' => $grade->toArray(),
        ]);
    }

    /**
     * Handle the Grade "updated" event.
     */
    public function updated(Grade $grade): void
    {
        $this->activityLogRepository->create([
            'causer_id' => auth()->id(),
            'model_type' => Grade::class,
            'subject_id' => $grade->id,
            'action' => 'updated',
            'old_values' => $grade->getOriginal(),
            'new_values' => $grade->getChanges(),
        ]);
    }

    /**
     * Handle the Grade "deleted" event.
     */
    public function deleted(Grade $grade): void
    {
        $this->activityLogRepository->create([
            'causer_id' => auth()->id(),
            'model_type' => Grade::class,
            'subject_id' => $grade->id,
            'action' => 'deleted',
            'old_values' => $grade->toArray(),
            'new_values' => null,
        ]);
    }
}

<?php

namespace App\Observers;

use App\Models\Student;
use App\Repositories\Contracts\ActivityLogRepositoryInterface;

class StudentObserver
{
    public function __construct(
        private ActivityLogRepositoryInterface $activityLogRepository
    ) {}

    /**
     * Handle the Student "updated" event.
     */
    public function updated(Student $student): void
    {
        $changes = $student->getChanges();
        
        // Log status changes
        if (isset($changes['status'])) {
            $this->activityLogRepository->create([
                'causer_id' => auth()->id(), // System updates might not have auth
                'model_type' => Student::class,
                'subject_id' => $student->id,
                'action' => 'updated',
                'old_values' => $student->getOriginal(),
                'new_values' => $changes,
            ]);
        }
    }
}

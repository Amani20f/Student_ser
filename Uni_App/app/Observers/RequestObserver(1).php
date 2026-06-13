<?php

namespace App\Observers;

use App\Models\Request;
use App\Repositories\Contracts\ActivityLogRepositoryInterface;

class RequestObserver
{
    public function __construct(
        private ActivityLogRepositoryInterface $activityLogRepository
    ) {}

    /**
     * Handle the Request "created" event.
     */
    public function created(Request $request): void
    {
        $this->activityLogRepository->create([
            'causer_id' => auth()->id(),
            'model_type' => Request::class,
            'subject_id' => $request->id,
            'action' => 'created',
            'old_values' => null,
            'new_values' => $request->toArray(),
        ]);
    }

    /**
     * Handle the Request "updated" event.
     */
    public function updated(Request $request): void
    {
        // Log the update
        $this->activityLogRepository->create([
            'causer_id' => auth()->id(),
            'model_type' => Request::class,
            'subject_id' => $request->id,
            'action' => 'updated',
            'old_values' => $request->getOriginal(),
            'new_values' => $request->getChanges(),
        ]);

        // Check if status changed to APPROVED
        if ($request->wasChanged('status') && $request->status === \App\Enums\RequestStatusEnum::APPROVED) {
            // Load request type to check slug
            $requestType = $request->requestType;
            
            // If this is a re-enrollment request, restore student status
            if ($requestType && $requestType->slug === 're_enrollment') {
                $student = $request->student;
                
                if ($student && $student->status === \App\Enums\StudentStatusEnum::SUSPENDED) {
                    $student->status = \App\Enums\StudentStatusEnum::ACTIVE;
                    $student->save();
                    
                    // Log status restoration
                    \Illuminate\Support\Facades\Log::info('Student status restored via re-enrollment', [
                        'student_id' => $student->id,
                        'request_id' => $request->id,
                        'old_status' => 'suspended',
                        'new_status' => 'active',
                    ]);
                }
            } elseif ($requestType && $requestType->slug === 'absence_excuse') {
                 // Log approval for absence excuse (Student status remains ACTIVE)
                 \Illuminate\Support\Facades\Log::info('Absence excuse approved', [
                     'student_id' => $request->student_id,
                     'request_id' => $request->id,
                 ]);
            }
        }
    }

    /**
     * Handle the Request "deleted" event.
     */
    public function deleted(Request $request): void
    {
        $this->activityLogRepository->create([
            'causer_id' => auth()->id(),
            'model_type' => Request::class,
            'subject_id' => $request->id,
            'action' => 'deleted',
            'old_values' => $request->toArray(),
            'new_values' => null,
        ]);
    }
}

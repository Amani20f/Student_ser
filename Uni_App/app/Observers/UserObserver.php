<?php

namespace App\Observers;

use App\Models\User;
use App\Repositories\Contracts\ActivityLogRepositoryInterface;

class UserObserver
{
    public function __construct(
        private ActivityLogRepositoryInterface $activityLogRepository
    ) {}

    /**
     * Handle the User "created" event.
     */
    public function created(User $user): void
    {
        // Only log if the user being created is staff (not student or system)
        if ($user->hasRole(['admin', 'student_affairs', 'accountant', 'grade_control', 'staff'])) {
            $this->activityLogRepository->create([
                'causer_id' => auth()->id(),
                'model_type' => User::class,
                'subject_id' => $user->id,
                'action' => 'created',
                'old_values' => null,
                'new_values' => $user->makeHidden(['password', 'remember_token'])->toArray(),
            ]);
        }
    }

    /**
     * Handle the User "updated" event.
     */
    public function updated(User $user): void
    {
        if ($user->hasRole(['admin', 'student_affairs', 'accountant', 'grade_control', 'staff'])) {
            $changes = $user->getChanges();
            unset($changes['password'], $changes['remember_token']); // Security first

            if (!empty($changes)) {
                $this->activityLogRepository->create([
                    'causer_id' => auth()->id(),
                    'model_type' => User::class,
                    'subject_id' => $user->id,
                    'action' => 'updated',
                    'old_values' => $user->getOriginal(),
                    'new_values' => $changes,
                ]);
            }
        }
    }

    /**
     * Handle the User "deleted" event.
     */
    public function deleted(User $user): void
    {
        if ($user->hasRole(['admin', 'student_affairs', 'accountant', 'grade_control', 'staff'])) {
            $this->activityLogRepository->create([
                'causer_id' => auth()->id(),
                'model_type' => User::class,
                'subject_id' => $user->id,
                'action' => 'deleted',
                'old_values' => $user->makeHidden(['password', 'remember_token'])->toArray(),
                'new_values' => null,
            ]);
        }
    }
}

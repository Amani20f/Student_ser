<?php

namespace App\Policies;

use App\Models\Grade;
use App\Models\User;

class GradePolicy
{
    /**
     * Determine if the user can view any grades.
     */
    public function viewAny(User $user): bool
    {
        return $user->hasAnyRole(['admin', 'staff', 'student']);
    }

    /**
     * Determine if the user can view the grade.
     */
    public function view(User $user, Grade $grade): bool
    {
        // Students can only view their own grades
        if ($user->hasRole('student')) {
            return $user->student && $user->student->id === $grade->student_id;
        }

        // Staff and Admin can view all grades
        return $user->hasAnyRole(['admin', 'staff']) && $user->can('view-grades');
    }

    /**
     * Determine if the user can create grades.
     */
    public function create(User $user): bool
    {
        return $user->hasRole('staff') && $user->can('update-grades');
    }

    /**
     * Determine if the user can update the grade.
     */
    public function update(User $user, Grade $grade): bool
    {
        // Only staff with update-grades permission can update
        return $user->hasRole('staff') && $user->can('update-grades');
    }

    /**
     * Determine if the user can delete the grade.
     */
    public function delete(User $user, Grade $grade): bool
    {
        // Only admin can delete grades
        return $user->hasRole('admin');
    }
}

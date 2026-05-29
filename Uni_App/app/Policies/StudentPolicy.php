<?php

namespace App\Policies;

use App\Models\Student;
use App\Models\User;

class StudentPolicy
{
    /**
     * Determine if the user can view the student.
     */
    public function view(User $user, Student $student): bool
    {
        // Students can only view their own record
        if ($user->hasRole('student')) {
            return $user->student && $user->student->id === $student->id;
        }

        // Staff and Admin can view all students
        return $user->hasAnyRole(['admin', 'staff']);
    }

    /**
     * Determine if the user can update the student.
     */
    public function update(User $user, Student $student): bool
    {
        // Only admin and staff can update student records
        return $user->hasAnyRole(['admin', 'staff']);
    }
}

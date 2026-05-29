<?php

namespace App\Policies;

use App\Models\Appeal;
use App\Models\User;
use Illuminate\Auth\Access\HandlesAuthorization;

class AppealPolicy
{
    use HandlesAuthorization;

    public function viewAny(User $user): bool
    {
        return $user->hasAnyRole(['admin', 'student', 'accountant', 'grade_control']);
    }

    public function view(User $user, Appeal $appeal): bool
    {
        if ($user->hasRole('student')) {
            return $user->student && $user->student->id === $appeal->student_id;
        }

        return $user->hasAnyRole(['admin', 'accountant', 'grade_control']);
    }

    public function create(User $user): bool
    {
        return $user->hasRole('student');
    }

    public function update(User $user, Appeal $appeal): bool
    {
        // Students can't update after submission (except maybe payment)
        // Staff update via specific methods in controller
        return $user->hasAnyRole(['admin', 'accountant', 'grade_control']);
    }

    public function delete(User $user, Appeal $appeal): bool
    {
        return $user->hasRole('admin');
    }
}

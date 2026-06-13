<?php

namespace App\Services;

use App\Models\Notification;
use App\Models\Student;
use App\Models\User;
use Illuminate\Database\Eloquent\Model;

class NotificationService
{
    /**
     * Send a notification to a student.
     */
    public function notifyStudent(Student $student, string $title, string $message, ?Model $relatedModel = null): Notification
    {
        // Create the notification
        $notification = Notification::create([
            'title' => $title,
            'message' => $message,
            'target_type' => 'individual',
            'related_id' => $relatedModel?->getAttribute('id'),
            'related_type' => $relatedModel ? get_class($relatedModel) : null,
        ]);

        // Attach to the student's user account
        $user = $student->user;
        if ($user) {
            $notification->users()->attach($user->id, ['is_read' => false]);
        }

        return $notification;
    }

    /**
     * Send a notification to all users of a specific role.
     */
    public function notifyRole(string $role, string $title, string $message, ?Model $relatedModel = null): Notification
    {
        // Create the notification
        $notification = Notification::create([
            'title' => $title,
            'message' => $message,
            'target_type' => 'group',
            'related_id' => $relatedModel?->getAttribute('id'),
            'related_type' => $relatedModel ? get_class($relatedModel) : null,
        ]);

        // Get users with the role
        $users = User::where('role', $role)->get();
        $userIds = $users->pluck('id')->toArray();

        // Attach to the users
        if (!empty($userIds)) {
            $notification->users()->attach($userIds, ['is_read' => false]);
        }

        return $notification;
    }
}

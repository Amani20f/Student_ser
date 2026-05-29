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
}

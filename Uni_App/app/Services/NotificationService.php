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
    public function notifyStudent(Student $student, string $title, string $message, ?Model $relatedModel = null, string $notificationType = 'system'): Notification
    {
        // Create the notification
        $notification = Notification::create([
            'title' => $title,
            'message' => $message,
            'target_type' => 'individual',
            'related_id' => $relatedModel?->getAttribute('id'),
            'related_type' => $relatedModel ? get_class($relatedModel) : null,
            'notification_type' => $notificationType,
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
    public function notifyRole(string $role, string $title, string $message, ?Model $relatedModel = null, string $notificationType = 'system'): Notification
    {
        // Create the notification
        $notification = Notification::create([
            'title' => $title,
            'message' => $message,
            'target_type' => 'group',
            'related_id' => $relatedModel?->getAttribute('id'),
            'related_type' => $relatedModel ? get_class($relatedModel) : null,
            'notification_type' => $notificationType,
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
    /**
     * Send a notification to students in a specific program.
     */
    public function notifyProgram(int $programId, string $title, string $message, ?Model $relatedModel = null, string $notificationType = 'system'): Notification
    {
        $notification = Notification::create([
            'title' => $title,
            'message' => $message,
            'target_type' => 'group',
            'related_id' => $relatedModel?->getAttribute('id'),
            'related_type' => $relatedModel ? get_class($relatedModel) : null,
            'notification_type' => $notificationType,
        ]);

        $users = User::whereHas('student', function ($query) use ($programId) {
            $query->where('program_id', $programId);
        })->get();

        $userIds = $users->pluck('id')->toArray();

        if (!empty($userIds)) {
            $notification->users()->attach($userIds, ['is_read' => false]);
        }

        return $notification;
    }

    /**
     * Send a notification to students in a specific college.
     */
    public function notifyCollege(int $collegeId, string $title, string $message, ?Model $relatedModel = null, string $notificationType = 'system'): Notification
    {
        $notification = Notification::create([
            'title' => $title,
            'message' => $message,
            'target_type' => 'group',
            'related_id' => $relatedModel?->getAttribute('id'),
            'related_type' => $relatedModel ? get_class($relatedModel) : null,
            'notification_type' => $notificationType,
        ]);

        $users = User::whereHas('student.program', function ($query) use ($collegeId) {
            $query->where('college_id', $collegeId);
        })->get();

        $userIds = $users->pluck('id')->toArray();

        if (!empty($userIds)) {
            $notification->users()->attach($userIds, ['is_read' => false]);
        }

        return $notification;
    }

    /**
     * Send an internal message from a sender to multiple users.
     */
    public function sendMessage(User $sender, array $userIds, string $title, string $message): Notification
    {
        $notification = Notification::create([
            'title' => $title,
            'message' => $message,
            'target_type' => count($userIds) > 1 ? 'group' : 'individual',
            'sender_id' => $sender->id,
            'notification_type' => 'message',
        ]);

        if (!empty($userIds)) {
            $notification->users()->attach($userIds, ['is_read' => false]);
        }

        return $notification;
    }

    /**
     * Send an internal message from a sender to all users of a specific role.
     */
    public function sendMessageToRole(User $sender, string $role, string $title, string $message): Notification
    {
        $notification = Notification::create([
            'title' => $title,
            'message' => $message,
            'target_type' => 'group',
            'sender_id' => $sender->id,
            'notification_type' => 'message',
        ]);

        $users = User::where('role', $role)->get();
        $userIds = $users->pluck('id')->toArray();

        if (!empty($userIds)) {
            $notification->users()->attach($userIds, ['is_read' => false]);
        }

        return $notification;
    }
}

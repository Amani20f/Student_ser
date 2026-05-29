<?php

namespace App\Http\Controllers\Api\Student;

use App\Http\Controllers\Controller;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    /**
     * Get authenticated student's notifications.
     */
    public function index(): JsonResponse
    {
        $notifications = auth()->user()->notifications()
            ->withPivot('is_read', 'created_at')
            ->latest()
            ->get()
            ->map(function ($notification) {
                return [
                    'id' => $notification->id,
                    'title' => $notification->title,
                    'message' => $notification->message,
                    'related_type' => $notification->related_type,
                    'related_id' => $notification->related_id,
                    'is_read' => (bool) $notification->pivot->is_read,
                    'created_at' => $notification->created_at->toDateTimeString(),
                ];
            });

        return response()->json([
            'data' => $notifications
        ]);
    }

    /**
     * Mark a notification as read.
     */
    public function markAsRead(int $id): JsonResponse
    {
        $user = auth()->user();
        
        // Ensure the notification belongs to the user
        $exists = $user->notifications()->where('notification_id', $id)->exists();

        if (!$exists) {
            return response()->json(['message' => 'Notification not found'], 404);
        }

        $user->notifications()->updateExistingPivot($id, ['is_read' => true]);

        return response()->json([
            'message' => 'Notification marked as read'
        ]);
    }
}

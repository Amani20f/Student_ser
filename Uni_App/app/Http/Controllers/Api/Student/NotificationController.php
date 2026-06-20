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
                $relatedType = $notification->related_type;
                $relatedId = $notification->related_id;

                if ($relatedType === 'App\\Models\\Payment' && $relatedId) {
                    $payment = \App\Models\Payment::find($relatedId);
                    if ($payment) {
                        if ($payment->appeal_id) {
                            $relatedType = 'App\\Models\\Appeal';
                            $relatedId = $payment->appeal_id;
                        } elseif ($payment->request_id) {
                            $relatedType = 'App\\Models\\Request';
                            $relatedId = $payment->request_id;
                        }
                    }
                }

                return [
                    'id' => $notification->id,
                    'title' => $notification->title,
                    'message' => $notification->message,
                    'related_type' => $relatedType,
                    'related_id' => $relatedId,
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

    /**
     * Clear all notifications for the authenticated student.
     */
    public function clearAll(): JsonResponse
    {
        $user = auth()->user();
        $user->notifications()->detach();

        return response()->json([
            'message' => 'All notifications cleared'
        ]);
    }
}

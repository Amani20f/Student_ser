<?php

namespace App\Http\Controllers\Api\Staff;

use App\Http\Controllers\Controller;
use App\Models\Notification;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class NotificationController extends Controller
{
    /**
     * Get authenticated staff member's notifications.
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
     * Send notification to a specific role or group.
     */
    public function store(Request $request): JsonResponse
    {
        // Only admin can send notifications
        if (!auth()->user()->hasRole('admin')) {
            return response()->json(['message' => 'Unauthorized. Only admins can send notifications.'], 403);
        }

        $request->validate([
            'title' => 'required|string|max:255',
            'message' => 'required|string',
            'target_role' => 'required|string|in:student_affairs,accountant,grade_control,all_staff',
        ]);

        $title = $request->input('title');
        $message = $request->input('message');
        $targetRole = $request->input('target_role');

        // Create the notification
        $notification = Notification::create([
            'title' => $title,
            'message' => $message,
            'target_type' => 'group',
        ]);

        // Get target users
        if ($targetRole === 'all_staff') {
            $users = User::whereIn('role', ['student_affairs', 'accountant', 'grade_control'])->get();
        } else {
            $users = User::where('role', $targetRole)->get();
        }

        // Attach notification to target users
        $userIds = $users->pluck('id')->toArray();
        $notification->users()->attach($userIds);

        return response()->json([
            'message' => 'Notification sent successfully to ' . count($userIds) . ' users.',
            'data' => $notification
        ]);
    }
}

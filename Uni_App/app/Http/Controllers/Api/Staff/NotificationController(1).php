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
     * Send notification to a specific role, group, or user.
     */
    public function store(Request $request): JsonResponse
    {
        // All authenticated staff can send notifications

        $request->validate([
            'title' => 'required|string|max:255',
            'message' => 'required|string',
            'target_type' => 'nullable|string|in:group,individual,all',
            'target_role' => 'nullable|string',
            'target_user_id' => 'nullable|integer|exists:users,id',
        ]);

        $title = $request->input('title');
        $message = $request->input('message');
        $targetType = $request->input('target_type') ?? 'group';
        $targetRole = $request->input('target_role');
        $targetUserId = $request->input('target_user_id');

        // Create the notification
        $notification = Notification::create([
            'title' => $title,
            'message' => $message,
            'target_type' => $targetType,
        ]);

        $userIds = [];

        if ($targetType === 'individual' && $targetUserId) {
            $userIds = [$targetUserId];
        } elseif ($targetType === 'all') {
            $userIds = User::pluck('id')->toArray();
        } else {
            // Group based on role
            if ($targetRole === 'all_staff') {
                $userIds = User::whereIn('role', ['student_affairs', 'accountant', 'grade_control'])->pluck('id')->toArray();
            } elseif ($targetRole === 'all') {
                $userIds = User::pluck('id')->toArray();
            } elseif ($targetRole === 'student') {
                $userIds = User::where('role', 'student')->pluck('id')->toArray();
            } elseif ($targetRole === 'admin') {
                $userIds = User::where('role', 'admin')->pluck('id')->toArray();
            } else {
                $userIds = User::where('role', $targetRole)->pluck('id')->toArray();
            }
        }

        // Attach notification to target users
        $notification->users()->attach($userIds);

        return response()->json([
            'message' => 'Notification sent successfully to ' . count($userIds) . ' users.',
            'data' => $notification
        ]);
    }
}

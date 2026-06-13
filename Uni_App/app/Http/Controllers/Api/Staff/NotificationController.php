<?php

namespace App\Http\Controllers\Api\Staff;

use App\Http\Controllers\Controller;
use App\Models\Notification;
use App\Models\User;
use App\Services\NotificationService;
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
            ->with(['sender']) // Load sender relationship
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
                    'sender_name' => $notification->sender ? $notification->sender->name : null,
                    'sender_role' => $notification->sender ? $notification->sender->role : null,
                    'notification_type' => $notification->notification_type,
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
     * Get a list of users for messaging (excluding students, only staff/admins).
     */
    public function users(): JsonResponse
    {
        $users = User::where('role', '!=', 'student')
            ->select('id', 'name', 'role')
            ->get();
        return response()->json(['data' => $users]);
    }

    /**
     * Send internal message to role, specific user, or multiple users.
     */
    public function store(Request $request, NotificationService $notificationService): JsonResponse
    {
        $user = auth()->user();
        
        // Allowed roles to send messages
        if (!in_array($user->role, ['admin', 'student_affairs', 'accountant', 'grade_control'])) {
            return response()->json(['message' => 'Unauthorized to send messages.'], 403);
        }

        $request->validate([
            'title' => 'required|string|max:255',
            'message' => 'required|string',
            'recipient_type' => 'required|in:role,specific,multiple',
            'target_role' => 'required_if:recipient_type,role|string|nullable',
            'user_ids' => 'required_if:recipient_type,multiple|array|nullable',
            'user_ids.*' => 'integer|exists:users,id',
            'user_id' => 'required_if:recipient_type,specific|integer|exists:users,id|nullable',
        ]);

        $title = $request->input('title');
        $message = $request->input('message');
        $recipientType = $request->input('recipient_type');

        if ($recipientType === 'role') {
            $notification = $notificationService->sendMessageToRole($user, $request->input('target_role'), $title, $message);
        } elseif ($recipientType === 'multiple') {
            $notification = $notificationService->sendMessage($user, $request->input('user_ids'), $title, $message);
        } else { // specific
            $notification = $notificationService->sendMessage($user, [$request->input('user_id')], $title, $message);
        }

        return response()->json([
            'message' => 'Message sent successfully.',
            'data' => $notification->load('sender')
        ]);
    }
}

<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Announcement;
use App\Services\NotificationService;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Storage;

class AnnouncementController extends Controller
{
    protected $notificationService;

    public function __construct(NotificationService $notificationService)
    {
        $this->notificationService = $notificationService;
    }

    public function index()
    {
        $announcements = Announcement::with(['targetProgram', 'targetCollege'])->orderBy('created_at', 'desc')->get();
        return response()->json($announcements);
    }

    public function store(Request $request)
    {
        \Log::info('--- STORE ANNOUNCEMENT ---');
        \Log::info('All inputs:', $request->all());
        \Log::info('Has image file?', ['has_file' => $request->hasFile('image')]);
        if ($request->hasFile('image')) {
            \Log::info('File details:', ['file' => $request->file('image')]);
        }

        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'content' => 'required|string',
            'image' => 'nullable|image|mimes:jpg,jpeg,png,webp|max:2048',
            'target_audience' => 'required|in:all_students,specific_college,specific_program,staff',
            'target_college_id' => 'required_if:target_audience,specific_college|exists:colleges,id|nullable',
            'target_program_id' => 'required_if:target_audience,specific_program|exists:programs,id|nullable',
            'is_active' => 'boolean',
            'published_at' => 'nullable|date',
            'expires_at' => 'nullable|date',
            'send_notification' => 'boolean'
        ]);

        $imagePath = null;
        if ($request->hasFile('image')) {
            $imagePath = $request->file('image')->store('announcements', 'public');
        }

        DB::beginTransaction();
        try {
            $announcement = Announcement::create([
                'title' => $validated['title'],
                'content' => $validated['content'],
                'image_path' => $imagePath,
                'target_audience' => $validated['target_audience'],
                'target_college_id' => $validated['target_college_id'] ?? null,
                'target_program_id' => $validated['target_program_id'] ?? null,
                'is_active' => $validated['is_active'] ?? true,
                'published_at' => $validated['published_at'] ?? now(),
                'expires_at' => $validated['expires_at'] ?? null,
            ]);

            if ($request->boolean('send_notification')) {
                $this->sendNotification($announcement);
            }

            DB::commit();
            return response()->json($announcement->load(['targetProgram', 'targetCollege']), 201);
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['message' => 'Failed to create announcement', 'error' => $e->getMessage()], 500);
        }
    }

    public function update(Request $request, Announcement $announcement)
    {
        $validated = $request->validate([
            'title' => 'required|string|max:255',
            'content' => 'required|string',
            'image' => 'nullable|image|mimes:jpg,jpeg,png,webp|max:2048',
            'target_audience' => 'required|in:all_students,specific_college,specific_program,staff',
            'target_college_id' => 'required_if:target_audience,specific_college|exists:colleges,id|nullable',
            'target_program_id' => 'required_if:target_audience,specific_program|exists:programs,id|nullable',
            'is_active' => 'boolean',
            'published_at' => 'nullable|date',
            'expires_at' => 'nullable|date',
            'send_notification' => 'boolean'
        ]);

        if ($request->hasFile('image')) {
            if ($announcement->image_path) {
                Storage::disk('public')->delete($announcement->image_path);
            }
            $announcement->image_path = $request->file('image')->store('announcements', 'public');
        }

        DB::beginTransaction();
        try {
            $announcement->update([
                'title' => $validated['title'],
                'content' => $validated['content'],
                'target_audience' => $validated['target_audience'],
                'target_college_id' => $validated['target_college_id'] ?? null,
                'target_program_id' => $validated['target_program_id'] ?? null,
                'is_active' => $validated['is_active'] ?? true,
                'published_at' => $validated['published_at'] ?? $announcement->published_at,
                'expires_at' => $validated['expires_at'] ?? null,
            ]);

            if ($request->boolean('send_notification')) {
                $this->sendNotification($announcement);
            }

            DB::commit();
            return response()->json($announcement->load(['targetProgram', 'targetCollege']));
        } catch (\Exception $e) {
            DB::rollBack();
            return response()->json(['message' => 'Failed to update announcement', 'error' => $e->getMessage()], 500);
        }
    }

    public function destroy(Announcement $announcement)
    {
        if ($announcement->image_path) {
            Storage::disk('public')->delete($announcement->image_path);
        }
        $announcement->delete();
        return response()->json(null, 204);
    }

    public function toggle(Announcement $announcement)
    {
        $announcement->update(['is_active' => !$announcement->is_active]);
        return response()->json($announcement);
    }

    protected function sendNotification(Announcement $announcement)
    {
        $title = "إعلان جديد: " . $announcement->title;
        $message = "تم نشر إعلان جديد، يرجى الاطلاع عليه.";

        switch ($announcement->target_audience) {
            case 'all_students':
                $this->notificationService->notifyRole('student', $title, $message, $announcement, 'announcement');
                break;
            case 'staff':
                $this->notificationService->notifyRole('admin', $title, $message, $announcement, 'announcement');
                $this->notificationService->notifyRole('student_affairs', $title, $message, $announcement, 'announcement');
                $this->notificationService->notifyRole('grade_control', $title, $message, $announcement, 'announcement');
                $this->notificationService->notifyRole('accountant', $title, $message, $announcement, 'announcement');
                break;
            case 'specific_program':
                if ($announcement->target_program_id) {
                    $this->notificationService->notifyProgram($announcement->target_program_id, $title, $message, $announcement, 'announcement');
                }
                break;
            case 'specific_college':
                if ($announcement->target_college_id) {
                    $this->notificationService->notifyCollege($announcement->target_college_id, $title, $message, $announcement, 'announcement');
                }
                break;
        }
    }
}

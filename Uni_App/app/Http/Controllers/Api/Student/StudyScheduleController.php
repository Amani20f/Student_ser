<?php

namespace App\Http\Controllers\Api\Student;

use App\Http\Controllers\Controller;
use App\Models\StudySchedule;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class StudyScheduleController extends Controller
{
    public function show(Request $request): JsonResponse
    {
        $student = $request->user()->student;

        if (!$student || !$student->program_id) {
            return response()->json(['message' => 'No program assigned to this student.'], 403);
        }

        $activeSemester = \App\Models\Semester::active()->first();

        if (!$activeSemester) {
            return response()->json(['message' => 'No active semester found.'], 404);
        }

        \Illuminate\Support\Facades\Log::info('StudySchedule Query Debug', [
            'student_id' => $student->id,
            'program_id' => $student->program_id,
            'current_level' => $student->current_level,
            'active_semester_id' => $activeSemester->id,
        ]);

        $schedule = StudySchedule::with('program')
            ->where('program_id', $student->program_id)
            ->where('semester_id', $activeSemester->id)
            ->where('level', $student->current_level)
            ->first();

        if (!$schedule) {
            \Illuminate\Support\Facades\Log::info('StudySchedule Query Failed to find schedule', [
                'program_id' => $student->program_id,
                'semester_id' => $activeSemester->id,
                'level' => $student->current_level
            ]);
            return response()->json(['message' => 'Study schedule not found for your program, current level, and active semester.'], 404);
        }

        return response()->json([
            'data' => [
                'title'       => $schedule->title,
                'program'     => $schedule->program->name ?? null,
                'file_url'    => $schedule->file_path ? url('storage/' . $schedule->file_path) : null,
                'uploaded_at' => $schedule->updated_at,
            ]
        ]);
    }
}

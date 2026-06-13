<?php

namespace App\Http\Controllers\Api\Student;

use App\Http\Controllers\Controller;
use App\Models\StudySchedule;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class StudyScheduleController extends Controller
{
    /**
     * Get study schedules for the authenticated student.
     * Filters by the student's program and optionally by semester/level.
     */
    public function index(Request $request): JsonResponse
    {
        $student = auth()->user()->student;

        if (!$student) {
            return response()->json(['error' => 'Student profile not found.'], 404);
        }

        $query = StudySchedule::with(['semester'])
            ->where('program_id', $student->program_id);

        if ($request->filled('semester_id')) {
            $query->where('semester_id', $request->semester_id);
        }
        if ($request->filled('level')) {
            $query->where('level', $request->level);
        } else {
            // Default: return schedule for the student's current level
            $query->where('level', $student->current_level);
        }

        $schedules = $query->get()->map(fn($s) => [
            'id'                 => $s->id,
            'program_id'         => $s->program_id,
            'semester_id'        => $s->semester_id,
            'academic_year'      => $s->semester->academic_year ?? null,
            'term'               => $s->semester->term->value ?? null,
            'level'              => $s->level,
            'schedule_image_url' => $s->schedule_image_path ? url('storage/' . $s->schedule_image_path) : null,
            'notes'              => $s->notes,
        ]);

        return response()->json(['data' => $schedules]);
    }
}

<?php

namespace App\Http\Controllers\Api\Student;

use App\Http\Controllers\Controller;
use App\Models\StudyPlan;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class StudyPlanController extends Controller
{
    public function show(Request $request): JsonResponse
    {
        $student = $request->user()->student;

        if (!$student || !$student->program_id) {
            return response()->json(['message' => 'No program assigned to this student.'], 403);
        }

        $plan = StudyPlan::with('program')->where('program_id', $student->program_id)->first();

        if (!$plan) {
            return response()->json(['message' => 'Study plan not found for your program.'], 404);
        }

        return response()->json([
            'data' => [
                'title'       => $plan->title,
                'program'     => $plan->program->name ?? null,
                'file_url'    => $plan->file_path ? url('storage/' . $plan->file_path) : null,
                'uploaded_at' => $plan->updated_at,
            ]
        ]);
    }
}

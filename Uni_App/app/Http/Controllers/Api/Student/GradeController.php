<?php

namespace App\Http\Controllers\Api\Student;

use App\Http\Controllers\Controller;
use App\Services\Student\StudentService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use App\Http\Resources\GradeResource;

class GradeController extends Controller
{
    public function __construct(
        private StudentService $studentService
    ) {}

    /**
     * Get student grades.
     */
    public function index(Request $request): JsonResponse
    {
        try {
            $studentId = auth()->user()->student->id;

            // Check for required survey
            $latestRequiredSurvey = \App\Models\Survey::where('is_active', true)
                ->where('is_required_for_grades', true)
                ->latest()
                ->first();

            if ($latestRequiredSurvey) {
                $hasCompleted = \App\Models\SurveyCompletion::where('survey_id', $latestRequiredSurvey->id)
                    ->where('student_id', $studentId)
                    ->exists();

                if (!$hasCompleted) {
                    return response()->json([
                        'requires_survey' => true,
                        'survey' => $latestRequiredSurvey
                    ]);
                }
            }

            $grades = $this->studentService->getGrades(
                $studentId,
                $request->query('semester_id')
            );
            
            // Transform and Group by Semester Year/Term
            $grouped = $grades->groupBy(fn($grade) => $grade->semester->year . ' ' . $grade->semester->term->value)
                ->map(fn($semesterGrades) => GradeResource::collection($semesterGrades));

            return response()->json([
                'data' => $grouped
            ]);
        } catch (\Exception $e) {
            return response()->json(['error' => $e->getMessage()], 404);
        }
    }
}

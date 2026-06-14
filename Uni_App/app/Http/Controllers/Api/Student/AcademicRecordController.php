<?php

namespace App\Http\Controllers\Api\Student;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;

class AcademicRecordController extends Controller
{
    /**
     * Get the student's results grouped by semester.
     */
    public function results(Request $request)
    {
        /** @var \App\Models\User $user */
        $user = auth()->user();
        $student = $user->student;

        if (!$student) {
            return response()->json(['message' => 'Student record not found.'], 404);
        }

        // Get the active semester
        $activeSemester = \App\Models\Semester::where('is_active', true)->first();

        if (!$activeSemester) {
            return response()->json(['message' => 'No active semester found.'], 404);
        }

        // Check for required active questionnaire (survey)
        $requiredSurvey = \App\Models\Survey::where('semester_id', $activeSemester->id)
            ->where('is_active', true)
            ->where('is_required_for_grades', true)
            ->first();

        if ($requiredSurvey) {
            $isCompleted = \App\Models\SurveyCompletion::where('survey_id', $requiredSurvey->id)
                ->where('student_id', $student->id)
                ->exists();

            if (!$isCompleted) {
                return response()->json([
                    'error' => 'questionnaire_required',
                    'message' => 'You must complete the required questionnaire before viewing your results.',
                    'survey' => [
                        'id' => $requiredSurvey->id,
                        'title' => $requiredSurvey->title,
                        'url' => $requiredSurvey->google_form_url,
                    ]
                ], 403);
            }
        }

        $grades = $student->grades()
            ->where('semester_id', $activeSemester->id)
            ->with(['course', 'semester'])
            ->get();

        $semesterName = $activeSemester->term->value . ' ' . $activeSemester->academic_year;
        
        $courses = $grades->map(function ($grade) {
            return [
                'course_code' => $grade->course->course_code,
                'course_name' => $grade->course->course_name,
                'first' => $grade->first,
                'second' => $grade->second,
                'midterm' => $grade->midterm,
                'final' => $grade->final,
                'total' => $grade->total,
                'status' => $grade->status->value,
            ];
        })->values()->all();

        return response()->json([
            'data' => [
                'semester' => $semesterName,
                'courses' => $courses
            ]
        ]);
    }

    /**
     * Get the student's full academic transcript.
     */
    public function transcript(Request $request)
    {
        /** @var \App\Models\User $user */
        $user = auth()->user();
        $student = $user->student;

        if (!$student) {
            return response()->json(['message' => 'Student record not found.'], 404);
        }

        // Ensure CGPA is up to date
        $student->recalculateGPAAndCredits();

        $grades = $student->grades()->with(['course', 'semester'])->get();

        $groupedTranscript = $grades->groupBy(function ($grade) {
            return $grade->semester_id;
        })->map(function ($semesterGrades) {
            $semester = $semesterGrades->first()->semester;
            $semesterName = $semester->term->value . ' ' . $semester->academic_year;

            $earnedCredits = 0;
            $totalCredits = 0;
            $totalPoints = 0.0;

            $courses = $semesterGrades->map(function ($grade) use (&$earnedCredits, &$totalCredits, &$totalPoints) {
                $credits = $grade->course->credit_hours ?? 0;

                if ($grade->status->value === 'passed') {
                    $earnedCredits += $credits;
                }

                if ($grade->status->value !== 'incomplete') {
                    $totalCredits += $credits;
                    $totalPoints += ($grade->gpa ?? 0.0) * $credits;
                }

                return [
                    'course_code' => $grade->course->course_code,
                    'course_name' => $grade->course->course_name,
                    'total' => $grade->total,
                    'status' => $grade->status->value,
                ];
            })->values()->all();

            $semesterGpa = $totalCredits > 0 ? round($totalPoints / $totalCredits, 2) : 0.00;

            return [
                'semester' => $semesterName,
                'earned_credit_hours' => $earnedCredits,
                'total_credit_hours' => $totalCredits,
                'GPA' => $semesterGpa,
                'courses' => $courses,
            ];
        })->values()->all();

        return response()->json([
            'data' => [
                'CGPA' => $student->cumulative_gpa,
                'total_completed_credit_hours' => $student->completed_credit_hours,
                'transcript' => $groupedTranscript
            ]
        ]);
    }
}

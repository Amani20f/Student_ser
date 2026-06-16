<?php

namespace App\Http\Controllers\Api\Student;

use App\Http\Controllers\Controller;
use App\Models\Survey;
use App\Models\OptionalSurveyView;
use Illuminate\Http\Request;

class OptionalSurveyController extends Controller
{
    /**
     * Get a list of optional surveys for the authenticated student.
     */
    public function index(Request $request)
    {
        $student = auth()->user()->student;
        $studentId = $student->id;
        $programId = $student->program_id;
        $collegeId = $student->program?->department?->college_id;
        $currentLevel = $student->current_level;

        // Fetch optional active surveys targeting this student
        $surveys = Survey::where('is_active', true)
            ->where('is_required_for_grades', false)
            ->where(function($query) use ($programId, $collegeId, $currentLevel) {
                // College matches OR is not set
                $query->where(function ($sub) use ($collegeId) {
                    $sub->whereNull('target_college_id')->orWhere('target_college_id', $collegeId);
                })
                // AND Program matches OR is not set
                ->where(function ($sub) use ($programId) {
                    $sub->whereNull('target_program_id')->orWhere('target_program_id', $programId);
                })
                // AND Level matches OR is not set
                ->where(function ($sub) use ($currentLevel) {
                    $sub->whereNull('target_level')->orWhere('target_level', $currentLevel);
                });
            })
            ->orderBy('created_at', 'desc')
            ->get();

        // Get the survey IDs that this student has viewed
        $viewedSurveyIds = OptionalSurveyView::where('student_id', $studentId)
            ->pluck('survey_id')
            ->toArray();

        // Transform the response to include the view status
        $response = $surveys->map(function ($survey) use ($viewedSurveyIds) {
            return [
                'id' => $survey->id,
                'title' => $survey->title,
                'description' => $survey->description,
                'google_form_url' => $survey->google_form_url,
                'created_at' => $survey->created_at,
                'is_viewed' => in_array($survey->id, $viewedSurveyIds),
            ];
        });

        return response()->json($response);
    }

    /**
     * Mark an optional survey as viewed by the authenticated student.
     */
    public function markViewed($id)
    {
        $student = auth()->user()->student;

        // Check if the survey is optional before marking it here
        $survey = Survey::findOrFail($id);
        if ($survey->is_required_for_grades) {
            return response()->json(['message' => 'Cannot mark a mandatory survey as viewed through this endpoint'], 422);
        }

        OptionalSurveyView::firstOrCreate([
            'student_id' => $student->id,
            'survey_id' => $id
        ]);

        return response()->json(['message' => 'Survey marked as viewed successfully']);
    }
}

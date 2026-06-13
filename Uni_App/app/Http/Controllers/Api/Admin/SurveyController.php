<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Survey;
use Illuminate\Http\Request;

class SurveyController extends Controller
{
    public function index()
    {
        $surveys = Survey::orderBy('created_at', 'desc')->get();
        return response()->json($surveys);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'title' => 'required|string|max:255',
            'google_form_url' => 'required|url',
            'semester_id' => 'nullable|exists:semesters,id',
            'is_active' => 'boolean',
            'is_required_for_grades' => 'boolean',
        ]);

        $survey = Survey::create($data);
        return response()->json($survey, 201);
    }

    public function update(Request $request, Survey $survey)
    {
        $data = $request->validate([
            'title' => 'sometimes|required|string|max:255',
            'google_form_url' => 'sometimes|required|url',
            'semester_id' => 'nullable|exists:semesters,id',
            'is_active' => 'boolean',
            'is_required_for_grades' => 'boolean',
        ]);

        $survey->update($data);
        return response()->json($survey);
    }

    public function destroy(Survey $survey)
    {
        $survey->delete();
        return response()->json(['message' => 'Survey deleted']);
    }

    public function toggle(Survey $survey)
    {
        $survey->update(['is_active' => !$survey->is_active]);
        return response()->json($survey);
    }
}

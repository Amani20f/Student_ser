<?php

namespace App\Http\Controllers\Api\Admin;

use App\Http\Controllers\Controller;
use App\Models\Survey;
use Illuminate\Http\Request;

class SurveyController extends Controller
{
    public function index()
    {
        $surveys = Survey::with(['targetCollege', 'targetProgram'])->orderBy('created_at', 'desc')->get();
        return response()->json($surveys);
    }

    public function store(Request $request)
    {
        $data = $request->validate([
            'title' => 'required|string|max:255',
            'description' => 'nullable|string',
            'google_form_url' => 'required|url',
            'semester_id' => 'nullable|exists:semesters,id',
            'is_active' => 'boolean',
            'is_required_for_grades' => 'boolean',
            'target_college_id' => 'nullable|exists:colleges,id',
            'target_program_id' => 'nullable|exists:programs,id',
            'target_level' => 'nullable|integer|min:1|max:20',
        ]);

        $data['target_audience'] = 'all_students'; // Dummy value for backwards compatibility
        $data['confirmation_code'] = null;

        $survey = Survey::create($data);
        return response()->json($survey->load(['targetCollege', 'targetProgram']), 201);
    }

    public function update(Request $request, Survey $survey)
    {
        $data = $request->validate([
            'title' => 'sometimes|required|string|max:255',
            'description' => 'nullable|string',
            'google_form_url' => 'sometimes|required|url',
            'semester_id' => 'nullable|exists:semesters,id',
            'is_active' => 'boolean',
            'is_required_for_grades' => 'boolean',
            'target_college_id' => 'nullable|exists:colleges,id',
            'target_program_id' => 'nullable|exists:programs,id',
            'target_level' => 'nullable|integer|min:1|max:20',
        ]);

        // When a key isn't present in the request (e.g. they cleared it), we should allow it to become null.
        // But $request->validate only returns fields present in request. 
        // In this case, we'll force the fields if they are in the request, or we can just use $request->all() after validation
        
        $data['target_college_id'] = $request->input('target_college_id');
        $data['target_program_id'] = $request->input('target_program_id');
        $data['target_level'] = $request->input('target_level');
        $data['target_audience'] = 'all_students'; // Dummy value

        $survey->update($data);
        return response()->json($survey->load(['targetCollege', 'targetProgram']));
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

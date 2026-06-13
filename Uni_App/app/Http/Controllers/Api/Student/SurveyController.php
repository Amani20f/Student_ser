<?php

namespace App\Http\Controllers\Api\Student;

use App\Http\Controllers\Controller;
use App\Models\Survey;
use App\Models\SurveyCompletion;
use Illuminate\Http\Request;

class SurveyController extends Controller
{
    public function complete(Request $request)
    {
        $request->validate([
            'survey_id' => 'required|exists:surveys,id'
        ]);

        $studentId = auth()->user()->student->id;

        SurveyCompletion::firstOrCreate([
            'survey_id' => $request->survey_id,
            'student_id' => $studentId,
        ]);

        return response()->json(['message' => 'Survey marked as completed']);
    }
}

<?php

namespace App\Http\Requests\Api\Appeal;

use Illuminate\Foundation\Http\FormRequest;

class StoreAppealRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'semester_id' => 'required|exists:semesters,id',
            'academic_year' => 'required|string|max:20',
            'term' => 'required|string|max:20',
            'student_note' => 'required|string|max:2000',
            'items' => 'required|array|min:1',
            'items.*.course_id' => [
                'required',
                'exists:courses,id',
                function ($attribute, $value, $fail) {
                    $studentId = $this->user()->student->id;
                    $semesterId = $this->input('semester_id');
                    
                    $exists = \App\Models\Appeal::where('student_id', $studentId)
                        ->where('semester_id', $semesterId)
                        ->whereHas('items', function ($query) use ($value) {
                            $query->where('course_id', $value);
                        })
                        ->exists();

                    if ($exists) {
                        $fail("An appeal for this course in the selected semester already exists.");
                    }
                },
            ],
            'items.*.coursework_before' => 'nullable|numeric|min:0|max:100',
            'items.*.final_before' => 'nullable|numeric|min:0|max:100',
            'items.*.total_before' => 'nullable|numeric|min:0|max:100',
        ];
    }
}

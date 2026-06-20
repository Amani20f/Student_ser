<?php

namespace App\Http\Requests\Api\Appeal;

use Illuminate\Foundation\Http\FormRequest;

class StoreAppealRequest extends FormRequest
{
    public function authorize(): bool
    {
        $student = $this->user()?->student;
        if ($student && $student->status === \App\Enums\StudentStatusEnum::SUSPENDED) {
            return false;
        }
        return true;
    }

    public function rules(): array
    {
        return [
            'semester_id' => 'nullable|exists:semesters,id',
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
                        $fail("A grievance for this course in the selected semester already exists.");
                    }
                },
            ],
            'items.*.coursework_before' => 'nullable|numeric|min:0|max:100',
            'items.*.final_before' => 'nullable|numeric|min:0|max:100',
            'items.*.total_before' => 'nullable|numeric|min:0|max:100',
            'attachments' => 'required|array|min:1',
            'attachments.*' => 'file|mimes:pdf,png,jpg,jpeg|max:10240',
        ];
    }
    
    public function messages(): array
    {
        return [
            'attachments.required' => 'يرجى إرفاق المستندات الداعمة.',
            'attachments.min' => 'يجب إرفاق ملف واحد على الأقل.',
        ];
    }
}

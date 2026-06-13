<?php

namespace App\Http\Requests\Request;

use App\Models\RequestType;
use Illuminate\Validation\Validator;

class StoreAbsenceExcuseRequest extends BaseServiceRequestRequest
{
    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return array_merge(parent::rules(), [
            // Student Information
            'form_data.major' => ['required', 'string', 'max:255'],
            'form_data.level' => ['required', 'integer', 'between:1,8'],
            'form_data.college' => ['required', 'string', 'max:255'],
            'form_data.semester' => ['required', 'string', 'max:255'],
            'form_data.academic_year' => ['required', 'string', 'regex:/^\d{4}\/\d{4}$/'],

            // Absence Details
            'form_data.absence_reason' => ['required', 'string', 'min:10', 'max:1000'],
            'form_data.courses' => ['required', 'array', 'min:1'],

            // Course Array Validation
            'form_data.courses.*.course_name' => ['required', 'string', 'max:255'],
            'form_data.courses.*.absence_date' => ['required', 'date', 'before_or_equal:today'],
            'form_data.courses.*.day' => ['required', 'string', 'max:255'],
        ]);
    }

    /**
     * Configure the validator instance.
     */
    public function withValidator(Validator $validator): void
    {
        $validator->after(function ($validator) {
            // Validate that the request type is 'absence_excuse'
            if ($this->has('type_id')) {
                $requestType = RequestType::find($this->input('type_id'));
                
                if ($requestType && $requestType->slug !== 'absence_excuse') {
                    $validator->errors()->add(
                        'type_id',
                        'This validation is only for Absence Excuse requests.'
                    );
                }
            }

            // Validate academic year format (e.g., 2025/2026 should be sequential years)
            if ($this->has('form_data.academic_year')) {
                $academicYear = $this->input('form_data.academic_year');
                
                if (preg_match('/^(\d{4})\/(\d{4})$/', $academicYear, $matches)) {
                    $year1 = (int) $matches[1];
                    $year2 = (int) $matches[2];
                    
                    if ($year2 !== $year1 + 1) {
                        $validator->errors()->add(
                            'form_data.academic_year',
                            'Academic year must be in sequential format (e.g., 2025/2026).'
                        );
                    }
                }
            }
        });
    }

    /**
     * Get custom messages for validator errors.
     */
    public function messages(): array
    {
        return array_merge(parent::messages(), [
            'form_data.major.required' => 'Major is required.',
            'form_data.level.required' => 'Academic level is required.',
            'form_data.level.between' => 'Academic level must be between 1 and 8.',
            'form_data.college.required' => 'College name is required.',
            'form_data.semester.required' => 'Semester is required.',
            'form_data.academic_year.required' => 'Academic year is required.',
            'form_data.academic_year.regex' => 'Academic year must be in format YYYY/YYYY (e.g., 2025/2026).',
            'form_data.absence_reason.required' => 'Absence reason is required.',
            'form_data.absence_reason.min' => 'Absence reason must be at least 10 characters.',
            'form_data.absence_reason.max' => 'Absence reason must not exceed 1000 characters.',
            'form_data.courses.required' => 'At least one course absence must be specified.',
            'form_data.courses.min' => 'At least one course absence must be specified.',
            'form_data.courses.*.course_name.required' => 'Course name is required for each absence.',
            'form_data.courses.*.absence_date.required' => 'Absence date is required for each course.',
            'form_data.courses.*.absence_date.before_or_equal' => 'Absence date cannot be in the future.',
            'form_data.courses.*.day.required' => 'Day of the week is required for each absence.',
        ]);
    }
}

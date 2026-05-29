<?php

namespace App\Http\Requests\Request;

use Illuminate\Foundation\Http\FormRequest;

class RatifyReEnrollmentRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            // Student Affairs fields (optional - at least one should be provided)
            'major' => ['nullable', 'string', 'max:255'],
            'level' => ['nullable', 'integer', 'min:1', 'max:10'],
            'batch' => ['nullable', 'string', 'max:50'],
            'academic_year' => ['nullable', 'string', 'max:50'],
            
            // Accountant/Financial fields (optional)
            'university_fees' => ['nullable', 'numeric', 'min:0'],
            'other_fees' => ['nullable', 'numeric', 'min:0'],
        ];
    }

    /**
     * Get custom messages for validator errors.
     */
    public function messages(): array
    {
        return [
            'major.string' => 'التخصص الأكاديمي يجب أن يكون نصاً.',
            'major.max' => 'التخصص الأكاديمي يجب ألا يتجاوز 255 حرفاً.',
            
            'level.integer' => 'المستوى الأكاديمي يجب أن يكون رقماً صحيحاً.',
            'level.min' => 'المستوى الأكاديمي يجب أن يكون على الأقل 1.',
            'level.max' => 'المستوى الأكاديمي يجب ألا يتجاوز 10.',
            
            'batch.string' => 'الدفعة يجب أن تكون نصاً.',
            'batch.max' => 'الدفعة يجب ألا تتجاوز 50 حرفاً.',
            
            'academic_year.string' => 'العام الجامعي يجب أن يكون نصاً.',
            'academic_year.max' => 'العام الجامعي يجب ألا يتجاوز 50 حرفاً.',
            
            'university_fees.numeric' => 'الرسوم الجامعية يجب أن تكون رقماً.',
            'university_fees.min' => 'الرسوم الجامعية يجب أن تكون صفراً أو أكثر.',
            
            'other_fees.numeric' => 'الرسوم الأخرى يجب أن تكون رقماً.',
            'other_fees.min' => 'الرسوم الأخرى يجب أن تكون صفراً أو أكثر.',
        ];
    }

    /**
     * Get custom attributes for validator errors.
     */
    public function attributes(): array
    {
        return [
            'major' => 'التخصص الأكاديمي',
            'level' => 'المستوى الأكاديمي',
            'batch' => 'الدفعة',
            'academic_year' => 'العام الجامعي',
            'university_fees' => 'الرسوم الجامعية',
            'other_fees' => 'الرسوم الأخرى',
        ];
    }
}

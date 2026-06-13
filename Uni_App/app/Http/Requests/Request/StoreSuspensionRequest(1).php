<?php

namespace App\Http\Requests\Request;

use Illuminate\Foundation\Http\FormRequest;

class StoreSuspensionRequest extends BaseServiceRequestRequest
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
        return array_merge(parent::rules(), [
            'form_data.year_start' => ['required', 'string', 'max:50'],
            'form_data.semester_to' => ['required', 'string', 'max:50'],
            'form_data.year_end' => ['required', 'string', 'max:50'],
            'form_data.reason' => ['required', 'string', 'min:10', 'max:1000'],
        ]);
    }

    /**
     * Get custom messages for validator errors.
     */
    public function messages(): array
    {
        return array_merge(parent::messages(), [
            'form_data.year_start.required' => 'من العام الجامعي مطلوب.',
            'form_data.semester_to.required' => 'إلى الفصل الدراسي مطلوب.',
            'form_data.year_end.required' => 'نهاية العام الجامعي مطلوب.',
            
            'form_data.reason.required' => 'الأسباب مطلوبة.',
            'form_data.reason.string' => 'الأسباب يجب أن تكون نصاً.',
            'form_data.reason.min' => 'الأسباب يجب أن تحتوي على 10 أحرف على الأقل.',
            'form_data.reason.max' => 'الأسباب يجب ألا تتجاوز 1000 حرف.',
        ]);
    }

    /**
     * Get custom attributes for validator errors.
     */
    public function attributes(): array
    {
        return [
            'form_data.year_start' => 'من العام الجامعي',
            'form_data.semester_to' => 'إلى الفصل الدراسي',
            'form_data.year_end' => 'نهاية العام الجامعي',
            'form_data.reason' => 'الأسباب',
        ];
    }
}

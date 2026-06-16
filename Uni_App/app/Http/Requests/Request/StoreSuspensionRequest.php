<?php

namespace App\Http\Requests\Request;

use Illuminate\Foundation\Http\FormRequest;

class StoreSuspensionRequest extends FormRequest
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
            'form_data.suspension_reason'  => ['required', 'string', 'min:5', 'max:1000'],
            'form_data.start_semester_id'  => ['required', 'integer', 'exists:semesters,id'],
            'form_data.duration_semesters' => ['required', 'integer', 'in:1,2'],
            'form_data.notes'              => ['nullable', 'string', 'max:1000'],
            'attachments'                  => ['required', 'array', 'min:1'],
            'attachments.*'                => ['file', 'mimes:pdf,png,jpg,jpeg', 'max:10240'],
        ];
    }

    public function messages(): array
    {
        return array_merge(parent::messages(), [
            'form_data.suspension_reason.required'  => 'سبب الإيقاف مطلوب.',
            'form_data.start_semester_id.required'  => 'الفصل الدراسي للبدء مطلوب.',
            'form_data.duration_semesters.required' => 'مدة الإيقاف مطلوبة.',
            'form_data.duration_semesters.in'       => 'مدة الإيقاف يجب أن تكون فصلاً واحداً أو فصلين.',
            'attachments.required'                  => 'يرجى إرفاق المستندات الداعمة.',
        ]);
    }

    public function attributes(): array
    {
        return [
            'form_data.suspension_reason'  => 'سبب الإيقاف',
            'form_data.start_semester_id'  => 'فصل البدء',
            'form_data.duration_semesters' => 'مدة الإيقاف',
            'form_data.notes'              => 'الملاحظات',
            'attachments'                  => 'المرفقات',
        ];
    }
}

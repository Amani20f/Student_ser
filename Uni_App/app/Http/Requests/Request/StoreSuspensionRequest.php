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
            'suspension_reason'  => ['required', 'string', 'min:5', 'max:1000'],
            'start_semester_id'  => ['required', 'integer', 'exists:semesters,id'],
            'duration_semesters' => ['required', 'integer', 'in:1,2'],
            'notes'              => ['nullable', 'string', 'max:1000'],
            'attachment'         => ['nullable', 'file', 'mimes:pdf,png,jpg,jpeg', 'max:10240'],
        ];
    }

    public function messages(): array
    {
        return array_merge(parent::messages(), [
            'suspension_reason.required'  => 'سبب الإيقاف مطلوب.',
            'start_semester_id.required'  => 'الفصل الدراسي للبدء مطلوب.',
            'duration_semesters.required' => 'مدة الإيقاف مطلوبة.',
            'duration_semesters.in'       => 'مدة الإيقاف يجب أن تكون فصلاً واحداً أو فصلين.',
        ]);
    }

    public function attributes(): array
    {
        return [
            'suspension_reason'  => 'سبب الإيقاف',
            'start_semester_id'  => 'فصل البدء',
            'duration_semesters' => 'مدة الإيقاف',
            'notes'              => 'الملاحظات',
            'attachment'         => 'المرفقات',
        ];
    }
}

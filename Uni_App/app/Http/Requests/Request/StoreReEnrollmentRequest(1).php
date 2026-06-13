<?php

namespace App\Http\Requests\Request;

use Illuminate\Foundation\Http\FormRequest;

class StoreReEnrollmentRequest extends FormRequest
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
            'request_type_id' => ['required', 'integer', 'exists:request_types,id'],
            'suspension_form' => ['required', 'file', 'mimes:pdf,jpg,jpeg,png', 'max:5120'], // 5MB
            'university_id' => ['required', 'file', 'mimes:pdf,jpg,jpeg,png', 'max:5120'], // 5MB
            'description' => ['nullable', 'string', 'max:1000'],
        ];
    }

    /**
     * Get custom messages for validator errors.
     */
    public function messages(): array
    {
        return [
            'request_type_id.required' => 'نوع الطلب مطلوب.',
            'request_type_id.exists' => 'نوع الطلب المحدد غير موجود.',
            
            'suspension_form.required' => 'صورة استمارة وقف القيد مطلوبة.',
            'suspension_form.file' => 'صورة استمارة وقف القيد يجب أن تكون ملفاً.',
            'suspension_form.mimes' => 'صورة استمارة وقف القيد يجب أن تكون بصيغة PDF أو صورة.',
            'suspension_form.max' => 'حجم ملف استمارة وقف القيد يجب ألا يتجاوز 5 ميجابايت.',
            
            'university_id.required' => 'البطاقة الجامعية مطلوبة.',
            'university_id.file' => 'البطاقة الجامعية يجب أن تكون ملفاً.',
            'university_id.mimes' => 'البطاقة الجامعية يجب أن تكون بصيغة PDF أو صورة.',
            'university_id.max' => 'حجم ملف البطاقة الجامعية يجب ألا يتجاوز 5 ميجابايت.',
            
            'description.max' => 'الوصف يجب ألا يتجاوز 1000 حرف.',
        ];
    }

    /**
     * Get custom attributes for validator errors.
     */
    public function attributes(): array
    {
        return [
            'suspension_form' => 'استمارة وقف القيد',
            'university_id' => 'البطاقة الجامعية',
            'description' => 'الوصف',
        ];
    }
}

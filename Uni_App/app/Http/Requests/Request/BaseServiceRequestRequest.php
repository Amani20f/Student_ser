<?php

namespace App\Http\Requests\Request;

use Illuminate\Foundation\Http\FormRequest;

class BaseServiceRequestRequest extends FormRequest
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
            'student_id' => ['required', 'integer', 'exists:students,id'],
            'type_id' => ['required', 'integer', 'exists:request_types,id'],
            'form_data' => ['required', 'array'],
        ];
    }

    /**
     * Get custom messages for validator errors.
     */
    public function messages(): array
    {
        return [
            'student_id.required' => 'Student ID is required.',
            'student_id.exists' => 'The selected student does not exist.',
            'type_id.required' => 'Request type is required.',
            'type_id.exists' => 'The selected request type does not exist or is inactive.',
            'form_data.required' => 'Form data is required.',
            'form_data.array' => 'Form data must be a valid array.',
        ];
    }
}

<?php

namespace App\Http\Requests\Request;

use Illuminate\Foundation\Http\FormRequest;

class UpdateRequestStatusRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        // TODO: Add authorization logic to ensure only admins can update status
        // return auth()->user()->hasRole('admin') || auth()->user()->hasRole('staff');
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
            'status' => ['required', 'string', 'in:pending,approved,rejected'],
            'admin_notes' => ['required_if:status,rejected', 'nullable', 'string', 'max:2000'],
            'should_notify' => ['sometimes', 'boolean'],
        ];
    }

    /**
     * Get custom messages for validator errors.
     */
    public function messages(): array
    {
        return [
            'status.required' => 'Status is required.',
            'status.in' => 'Status must be pending, approved, or rejected.',
            'admin_notes.required_if' => 'Admin notes are required when rejecting a request.',
            'admin_notes.max' => 'Admin notes must not exceed 2000 characters.',
            'should_notify.boolean' => 'Should notify must be true or false.',
        ];
    }

    /**
     * Prepare the data for validation.
     */
    protected function prepareForValidation(): void
    {
        // Set default value for should_notify if not provided
        if (!$this->has('should_notify')) {
            $this->merge([
                'should_notify' => true,
            ]);
        }
    }
}

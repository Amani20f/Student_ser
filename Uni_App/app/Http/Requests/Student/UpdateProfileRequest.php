<?php

namespace App\Http\Requests\Student;

use Illuminate\Foundation\Http\FormRequest;

class UpdateProfileRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return $this->user() && $this->user()->hasRole('student');
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            'name'          => ['nullable', 'string', 'min:2', 'max:255'],
            'email'         => ['nullable', 'email', 'max:255'],
            'phone'         => ['required', 'string', 'min:8', 'max:15'],
            'national_id'   => ['nullable', 'string', 'max:50'],
            'profile_photo' => ['nullable', 'image', 'mimes:jpeg,png,jpg,gif', 'max:2048'],
        ];
    }

    protected function prepareForValidation(): void
    {
        if ($this->has('phone')) {
            $phone = $this->input('phone');
            $arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
            $english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
            $normalized = str_replace($arabic, $english, $phone);
            // Keep only digits and optional plus
            $normalized = preg_replace('/[^\d+]/', '', $normalized);
            $this->merge(['phone' => $normalized]);
        }
    }
}

<?php

namespace App\Http\Requests\Api\Admin;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateRequestTypeRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        $id = $this->route('request_type');

        return [
            'name'        => 'sometimes|string|max:255',
            'slug'        => ['sometimes', 'string', Rule::unique('request_types', 'slug')->ignore($id)],
            'description' => 'nullable|string',
            'is_active'   => 'sometimes|boolean',
            'target_role' => ['nullable', Rule::in(['student_affairs', 'accountant', 'grade_control', 'admin'])],
            'price'       => 'sometimes|numeric|min:0',
            'form_url'    => 'sometimes|nullable|url|max:500',
        ];
    }
}

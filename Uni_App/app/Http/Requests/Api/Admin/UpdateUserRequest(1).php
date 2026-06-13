<?php

namespace App\Http\Requests\Api\Admin;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateUserRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        // The route parameter may be bound as a User model or a plain id
        $userId = $this->route('user')?->id ?? $this->route('user');

        return [
            'name'  => 'sometimes|string|max:255',
            'email' => ['sometimes', 'email', Rule::unique('users', 'email')->ignore($userId)],
            'role'  => ['sometimes', Rule::in(['admin', 'student_affairs', 'accountant', 'grade_control'])],
        ];
    }
}

<?php

namespace App\Http\Requests\Api\Appeal;

use Illuminate\Foundation\Http\FormRequest;

class VerifyAppealPaymentRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()->hasRole('accountant') || $this->user()->hasRole('admin');
    }

    public function rules(): array
    {
        return [
            'status' => 'required|in:approved,rejected',
            'rejection_reason' => 'required_if:status,rejected|nullable|string|max:255',
        ];
    }
}

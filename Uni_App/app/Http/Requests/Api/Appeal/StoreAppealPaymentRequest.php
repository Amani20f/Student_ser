<?php

namespace App\Http\Requests\Api\Appeal;

use App\Enums\AppealStatusEnum;
use Illuminate\Foundation\Http\FormRequest;

class StoreAppealPaymentRequest extends FormRequest
{
    public function authorize(): bool
    {
        $appeal = \App\Models\Appeal::find($this->input('appeal_id'));
        return $appeal && $appeal->student_id === $this->user()->student->id;
    }

    public function rules(): array
    {
        return [
            'appeal_id' => [
                'required',
                'exists:appeals,id',
                function ($attribute, $value, $fail) {
                    $appeal = \App\Models\Appeal::find($value);
                    if ($appeal && $appeal->status !== AppealStatusEnum::PENDING_PAYMENT) {
                        $fail("This appeal is not pending payment.");
                    }
                },
            ],
            'semester_id' => 'required|exists:semesters,id',
            'amount' => 'required|numeric|min:0',
            'receipt_image' => 'required|image|max:2048',
        ];
    }
}

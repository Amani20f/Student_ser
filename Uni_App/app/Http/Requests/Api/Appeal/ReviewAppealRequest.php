<?php

namespace App\Http\Requests\Api\Appeal;

use Illuminate\Foundation\Http\FormRequest;

class ReviewAppealRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()->hasRole('grade_control') || $this->user()->hasRole('admin');
    }

    public function rules(): array
    {
        return [
            'decision' => 'required|in:approved,rejected',
            'committee_report' => 'nullable|string',
            'items' => 'required_if:decision,approved|array',
            'items.*.appeal_item_id' => 'required|exists:appeal_items,id',
            'items.*.coursework_after' => 'nullable|numeric|min:0|max:100',
            'items.*.final_after' => 'nullable|numeric|min:0|max:100',
            'items.*.total_after' => 'nullable|numeric|min:0|max:100',
            'items.*.absence_percentage' => 'nullable|numeric|min:0|max:100',
        ];
    }
}

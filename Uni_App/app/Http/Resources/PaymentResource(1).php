<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class PaymentResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id'               => $this->id,
            'student'          => [
                'id'   => $this->student_id,
                'name' => $this->student->user->name ?? null,
            ],
            'semester'         => [
                'id'            => $this->semester_id,
                'academic_year' => $this->semester->academic_year ?? null,
                'term'          => $this->semester->term->value ?? null,
            ],
            'amount'           => $this->amount,
            'purpose'          => $this->purpose,
            'receipt_image'    => $this->receipt_image ? url('storage/' . $this->receipt_image) : null,
            'status'           => $this->status instanceof \App\Enums\PaymentStatusEnum ? $this->status->value : (string) $this->status,
            'rejection_reason' => $this->rejection_reason,
            'appeal_id'        => $this->appeal_id,
            'request_id'       => $this->request_id,
            'created_at'       => $this->created_at,
            'updated_at'       => $this->updated_at,
        ];
    }
}

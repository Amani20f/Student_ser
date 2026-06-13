<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class AppealResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'student' => [
                'id' => $this->student_id,
                'name' => $this->student->user->name ?? null,
                'student_number' => $this->student->student_number ?? null,
                'program' => $this->student->program->program_name ?? null,
            ],
            'semester' => [
                'id' => $this->semester_id,
                'academic_year' => $this->semester->academic_year ?? null,
                'term' => $this->semester->term->value ?? (string)$this->semester->term,
            ],
            // Also exposed at top level for direct access by frontend consumers
            'academic_year' => $this->semester->academic_year ?? null,
            'term'          => $this->semester->term->value ?? (string)$this->semester->term,
            'status'        => $this->status->value ?? (string)$this->status,
            'student_note' => $this->student_note,
            'committee_report' => $this->committee_report,
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
            'accountant' => [
                'id' => $this->accountant_id,
                'name' => $this->accountant->name ?? null,
            ],
            'reviewed_by' => [
                'id' => $this->reviewed_by,
                'name' => $this->reviewer->name ?? null,
            ],
            'paid_at' => $this->paid_at,
            'reviewed_at' => $this->reviewed_at,
            'items' => AppealItemResource::collection($this->whenLoaded('items')),
            'payments' => PaymentResource::collection($this->whenLoaded('payments')),
        ];
    }
}

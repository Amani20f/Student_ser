<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class RequestResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id'              => $this->id,
            'student'         => [
                'id'             => $this->student_id,
                'name'           => $this->student->user->name ?? null,
                'student_number' => $this->student->student_number ?? null,
                'program_name'   => $this->student->program->name ?? null,
                'current_level'  => $this->student->current_level ?? null,
            ],
            'request_type'    => $this->requestType->name ?? null,
            'description'     => $this->description,
            'attachment'      => $this->attachment,
            'status'          => $this->status instanceof \App\Enums\RequestStatusEnum ? $this->status->value : (string) $this->status,
            'processed_by'    => $this->processedBy->name ?? null,
            'response_message'=> $this->response_message,
            'admin_notes'     => $this->admin_notes,
            'form_data'       => $this->form_data,
            'absence_excuse'  => $this->absenceExcuse ? [
                'academic_year' => $this->absenceExcuse->academic_year,
                'semester'      => $this->absenceExcuse->semester,
                'reason'        => $this->absenceExcuse->reason,
                'items'         => $this->absenceExcuse->items->map(fn($item) => [
                    'id'                     => $item->id,
                    'course_name'            => $item->course_name ?? 'Unknown',
                    'prev_excused_count'     => $item->prev_excused_count,
                    'prev_unexcused_count'   => $item->prev_unexcused_count,
                ]),
            ] : null,
            'created_at'      => $this->created_at->toDateTimeString(),
            'updated_at'      => $this->updated_at->toDateTimeString(),
        ];
    }
}

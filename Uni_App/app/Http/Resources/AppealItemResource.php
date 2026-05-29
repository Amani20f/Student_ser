<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class AppealItemResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'course_id' => $this->course_id,
            'course_name' => $this->course->course_name ?? null,
            'absence_percentage' => $this->absence_percentage,
            'before' => [
                'coursework' => $this->coursework_before,
                'final' => $this->final_before,
                'total' => $this->total_before,
            ],
            'after' => [
                'coursework' => $this->coursework_after,
                'final' => $this->final_after,
                'total' => $this->total_after,
            ],
            'created_at' => $this->created_at,
            'updated_at' => $this->updated_at,
        ];
    }
}

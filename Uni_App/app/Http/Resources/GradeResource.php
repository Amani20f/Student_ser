<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class GradeResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'student_id' => $this->student_id,
            'student_name' => $this->student->user->name ?? null,
            'course_id' => $this->course_id,
            'semester_id' => $this->semester_id,
            'course_name' => $this->course->course_name ?? null,
            'course_code' => $this->course->course_code ?? null,
            'academic_year' => $this->semester->academic_year ?? null,
            'semester_term' => $this->semester->term ?? null,
            'first' => $this->first,
            'second' => $this->second,
            'midterm' => $this->midterm,
            'final' => $this->final,
            'total' => $this->total,
            'gpa' => $this->gpa,
            'status' => $this->status ?? null,
            'grade_estimate' => $this->grade_estimate ?? null,
            'updated_at' => $this->updated_at,
        ];
    }
}

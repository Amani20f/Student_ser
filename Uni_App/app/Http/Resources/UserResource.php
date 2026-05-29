<?php

namespace App\Http\Resources;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class UserResource extends JsonResource
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
            'name' => $this->name,
            'username' => $this->username,
            'email' => $this->email,
            'role' => $this->role,
            'roles' => $this->getRoleNames(),
            'permissions' => $this->getAllPermissions()->pluck('name'),
            'email_verified_at' => $this->email_verified_at,
            'student' => $this->when($this->role === 'student' && $this->student, function () {
                return [
                    'id' => $this->student->id,
                    'student_number' => $this->student->student_number,
                    'phone' => $this->student->phone,
                    'current_level' => (int) $this->student->current_level,
                    'status' => $this->student->status,
                    'national_id' => $this->student->national_id,
                    'gender' => $this->student->gender,
                    'nationality' => $this->student->nationality,
                    'date_of_birth' => $this->student->date_of_birth?->toDateString(),
                    'profile_photo_path' => $this->student->profile_photo_path,
                    'cumulative_gpa' => (float) $this->student->cumulative_gpa,
                    'completed_credit_hours' => (int) $this->student->completed_credit_hours,
                    'program' => $this->student->program ? [
                        'id' => $this->student->program->id,
                        'name' => $this->student->program->name,
                        'code' => $this->student->program->code,
                    ] : null,
                ];
            }),
        ];
    }
}

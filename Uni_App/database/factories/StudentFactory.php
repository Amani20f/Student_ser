<?php

namespace Database\Factories;

use App\Models\Student;
use App\Models\User;
use App\Models\Program;
use App\Enums\StudentStatusEnum;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

class StudentFactory extends Factory
{
    protected $model = Student::class;

    public function definition(): array
    {
        return [
            'user_id' => User::factory(),
            'program_id' => Program::factory(),
            'student_number' => 'S' . fake()->unique()->numerify('#####'),
            'phone' => fake()->phoneNumber(),
            'current_level' => 1,
            'status' => StudentStatusEnum::ACTIVE,
        ];
    }
}

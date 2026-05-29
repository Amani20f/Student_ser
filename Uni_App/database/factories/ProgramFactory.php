<?php

namespace Database\Factories;

use App\Models\Program;
use App\Models\Department;
use App\Enums\DegreeTypeEnum;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

class ProgramFactory extends Factory
{
    protected $model = Program::class;

    public function definition(): array
    {
        return [
            'department_id' => Department::factory(),
            'name' => fake()->unique()->word() . ' Program',
            'code' => strtoupper(Str::random(4)),
            'duration_years' => 4,
            'degree_type' => DegreeTypeEnum::BACHELOR,
        ];
    }
}

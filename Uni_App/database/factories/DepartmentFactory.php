<?php

namespace Database\Factories;

use App\Models\Department;
use App\Models\College;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

class DepartmentFactory extends Factory
{
    protected $model = Department::class;

    public function definition(): array
    {
        return [
            'college_id' => College::factory(),
            'name' => fake()->unique()->word() . ' Department',
            'code' => strtoupper(Str::random(4)),
        ];
    }
}

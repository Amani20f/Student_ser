<?php

namespace Database\Factories;

use App\Models\College;
use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Str;

class CollegeFactory extends Factory
{
    protected $model = College::class;

    public function definition(): array
    {
        return [
            'name' => fake()->unique()->word() . ' College',
            'code' => strtoupper(Str::random(4)),
        ];
    }
}

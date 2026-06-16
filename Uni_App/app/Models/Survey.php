<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Survey extends Model
{
    protected $fillable = [
        'title',
        'description',
        'google_form_url',
        'semester_id',
        'is_active',
        'is_required_for_grades',
        'target_audience',
        'target_college_id',
        'target_program_id',
        'target_level',
        'confirmation_code',
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'is_required_for_grades' => 'boolean',
    ];

    public function semester()
    {
        return $this->belongsTo(Semester::class);
    }

    public function targetCollege()
    {
        return $this->belongsTo(College::class, 'target_college_id');
    }

    public function targetProgram()
    {
        return $this->belongsTo(Program::class, 'target_program_id');
    }
}

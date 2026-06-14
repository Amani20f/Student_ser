<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class SurveyCompletion extends Model
{
    protected $fillable = [
        'survey_id',
        'student_id',
        'completed_at',
    ];

    protected $casts = [
        'completed_at' => 'datetime',
    ];

    public function survey()
    {
        return $this->belongsTo(Survey::class);
    }

    public function student()
    {
        return $this->belongsTo(Student::class);
    }
}

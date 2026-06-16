<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class OptionalSurveyView extends Model
{
    use HasFactory;

    protected $fillable = [
        'student_id',
        'survey_id'
    ];

    public function student()
    {
        return $this->belongsTo(Student::class);
    }

    public function survey()
    {
        return $this->belongsTo(Survey::class);
    }
}

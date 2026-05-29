<?php

namespace App\Models;

use App\Enums\GradeStatusEnum;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Grade extends Model
{
    use HasFactory, \App\Traits\Filterable;

    protected $fillable = [
        'student_id',
        'course_id',
        'semester_id',
        'first',
        'second',
        'midterm',
        'final',
        'total',
        'gpa',
        'status',
        'grade_estimate',
    ];

    protected $casts = [
        'status' => GradeStatusEnum::class,
        'grade_estimate' => \App\Enums\GradeEstimateEnum::class,
        'first' => 'decimal:2',
        'second' => 'decimal:2',
        'midterm' => 'decimal:2',
        'final' => 'decimal:2',
        'total' => 'decimal:2',
        'gpa' => 'decimal:2',
    ];

    protected static function booted()
    {
        static::saved(function ($grade) {
            $grade->student->recalculateGPAAndCredits();
        });

        static::deleted(function ($grade) {
            $grade->student->recalculateGPAAndCredits();
        });
    }

    /**
     * Get the student that owns the grade.
     */
    public function student(): BelongsTo
    {
        return $this->belongsTo(Student::class);
    }

    /**
     * Get the course for this grade.
     */
    public function course(): BelongsTo
    {
        return $this->belongsTo(Course::class);
    }

    /**
     * Get the semester this grade belongs to.
     */
    public function semester(): BelongsTo
    {
        return $this->belongsTo(Semester::class);
    }
}

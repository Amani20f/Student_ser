<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class StudySchedule extends Model
{
    use HasFactory;

    protected $fillable = [
        'program_id',
        'level',
        'semester_id',
        'schedule_image_path',
        'notes',
    ];

    protected $casts = [
        'level' => 'integer',
    ];

    /**
     * Get the program for this schedule.
     */
    public function program(): BelongsTo
    {
        return $this->belongsTo(Program::class);
    }

    /**
     * Get the semester for this schedule.
     */
    public function semester(): BelongsTo
    {
        return $this->belongsTo(Semester::class);
    }
}

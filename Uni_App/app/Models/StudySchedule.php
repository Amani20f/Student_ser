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
        'semester_id',
        'level',
        'title',
        'file_path',
        'uploaded_by',
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
     * Get the user who uploaded this schedule.
     */
    public function uploader(): BelongsTo
    {
        return $this->belongsTo(User::class, 'uploaded_by');
    }

    /**
     * Get the semester for this schedule.
     */
    public function semester(): BelongsTo
    {
        return $this->belongsTo(Semester::class);
    }
}

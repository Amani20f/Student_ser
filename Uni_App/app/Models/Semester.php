<?php

namespace App\Models;

use App\Enums\SemesterTermEnum;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Semester extends Model
{
    use HasFactory;

    protected $fillable = [
        'academic_year',
        'term',
        'is_active',
        'start_date',
        'end_date',
        'exams_start_date',
    ];

    protected $casts = [
        'is_active' => 'boolean',
        'term' => SemesterTermEnum::class,
        'start_date' => 'date',
        'end_date' => 'date',
        'exams_start_date' => 'date',
    ];

    /**
     * Get all grades for this semester.
     */
    public function grades(): HasMany
    {
        return $this->hasMany(Grade::class);
    }

    /**
     * Get all payments for this semester.
     */
    public function payments(): HasMany
    {
        return $this->hasMany(Payment::class);
    }

    /**
     * Scope to get the active semester.
     */
    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }
}

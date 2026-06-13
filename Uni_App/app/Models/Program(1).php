<?php

namespace App\Models;

use App\Enums\DegreeTypeEnum;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

use Illuminate\Database\Eloquent\SoftDeletes;

class Program extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'department_id',
        'name',
        'code',
        'duration_years',
        'degree_type',
        'fees',
    ];

    protected $casts = [
        'degree_type' => DegreeTypeEnum::class,
        'fees' => 'decimal:2',
    ];

    /**
     * Get the department that owns the program.
     */
    public function department(): BelongsTo
    {
        return $this->belongsTo(Department::class);
    }

    /**
     * Get all students enrolled in this program.
     */
    public function students(): HasMany
    {
        return $this->hasMany(Student::class);
    }

    /**
     * Get all courses defined in this program's curriculum.
     */
    public function courses(): HasMany
    {
        return $this->hasMany(Course::class);
    }
}

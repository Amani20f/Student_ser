<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class AppealItem extends Model
{
    use HasFactory;

    protected $fillable = [
        'appeal_id',
        'course_id',
        'coursework_before',
        'final_before',
        'total_before',
        'coursework_after',
        'final_after',
        'total_after',
        'absence_percentage',
    ];

    protected $casts = [
        'coursework_before'  => 'decimal:2',
        'final_before'       => 'decimal:2',
        'total_before'       => 'decimal:2',
        'coursework_after'   => 'decimal:2',
        'final_after'        => 'decimal:2',
        'total_after'        => 'decimal:2',
        'absence_percentage' => 'decimal:2',
    ];

    /**
     * Get the appeal this item belongs to.
     */
    public function appeal(): BelongsTo
    {
        return $this->belongsTo(Appeal::class);
    }

    /**
     * Get the course being appealed.
     */
    public function course(): BelongsTo
    {
        return $this->belongsTo(Course::class);
    }
}

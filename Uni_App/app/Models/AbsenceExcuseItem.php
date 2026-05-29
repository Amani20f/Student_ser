<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class AbsenceExcuseItem extends Model
{
    use HasFactory;

    protected $fillable = [
        'absence_excuse_id',
        'course_name',
        'absence_date',
        'day',
        'prev_excused_count',
        'prev_unexcused_count',
    ];

    /**
     * Get the absence excuse that owns the item.
     */
    public function absenceExcuse(): BelongsTo
    {
        return $this->belongsTo(AbsenceExcuse::class);
    }
}

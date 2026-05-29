<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class AbsenceExcuse extends Model
{
    use HasFactory;

    protected $fillable = [
        'request_id',
        'academic_year',
        'semester',
        'reason',
    ];

    /**
     * Get the request that owns the absence excuse.
     */
    public function request(): BelongsTo
    {
        return $this->belongsTo(Request::class);
    }

    /**
     * Get the items for the absence excuse.
     */
    public function items(): HasMany
    {
        return $this->hasMany(AbsenceExcuseItem::class);
    }
}

<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class SuspensionRatification extends Model
{
    use HasFactory;

    protected $fillable = [
        'request_id',
        'old_debts_cleared',
        'verified_by',
        'verified_at',
        'notes',
    ];

    protected $casts = [
        'old_debts_cleared' => 'boolean',
        'verified_at' => 'datetime',
    ];

    /**
     * Get the suspension request associated with this ratification.
     */
    public function request(): BelongsTo
    {
        return $this->belongsTo(Request::class);
    }

    /**
     * Get the accountant/user who verified this ratification.
     */
    public function verifiedBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'verified_by');
    }
}

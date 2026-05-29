<?php

namespace App\Models;

use App\Enums\AppealStatusEnum;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Appeal extends Model
{
    use HasFactory;

    protected $fillable = [
        'student_id',
        'semester_id',
        'status',
        'student_note',
        'committee_report',
        'accountant_id',
        'reviewed_by',
        'paid_at',
        'reviewed_at',
    ];

    protected $casts = [
        'status'      => AppealStatusEnum::class,
        'paid_at'     => 'datetime',
        'reviewed_at' => 'datetime',
    ];

    // ────────────────────────────────────────
    // Relationships
    // ────────────────────────────────────────

    /**
     * Get the student who submitted the appeal.
     */
    public function student(): BelongsTo
    {
        return $this->belongsTo(Student::class);
    }

    /**
     * Get the semester this appeal is for.
     */
    public function semester(): BelongsTo
    {
        return $this->belongsTo(Semester::class);
    }

    /**
     * Get the accountant who verified the payment.
     */
    public function accountant(): BelongsTo
    {
        return $this->belongsTo(User::class, 'accountant_id');
    }

    /**
     * Get the grade control staff who reviewed the appeal.
     */
    public function reviewer(): BelongsTo
    {
        return $this->belongsTo(User::class, 'reviewed_by');
    }

    /**
     * Get all items (courses) included in this appeal.
     */
    public function items(): HasMany
    {
        return $this->hasMany(AppealItem::class);
    }

    /**
     * Get all payments linked to this appeal.
     */
    public function payments(): HasMany
    {
        return $this->hasMany(Payment::class);
    }

    // ────────────────────────────────────────
    // Scopes
    // ────────────────────────────────────────

    /**
     * Scope to filter by status.
     */
    public function scopeStatus($query, AppealStatusEnum $status)
    {
        return $query->where('status', $status);
    }
}

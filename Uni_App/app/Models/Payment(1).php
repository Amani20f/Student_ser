<?php

namespace App\Models;

use App\Enums\PaymentStatusEnum;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Payment extends Model
{
    use HasFactory, \App\Traits\Filterable;

    protected $fillable = [
        'student_id',
        'semester_id',
        'amount',
        'purpose',
        'receipt_image',
        'status',
        'rejection_reason',
        'appeal_id',
        'request_id',
    ];

    protected $casts = [
        'amount' => 'decimal:2',
        'status' => PaymentStatusEnum::class,
    ];

    /**
     * Get the student that made the payment.
     */
    public function student(): BelongsTo
    {
        return $this->belongsTo(Student::class);
    }

    /**
     * Get the semester this payment is for.
     */
    public function semester(): BelongsTo
    {
        return $this->belongsTo(Semester::class);
    }

    /**
     * Get the appeal this payment is linked to (optional).
     */
    public function appeal(): BelongsTo
    {
        return $this->belongsTo(Appeal::class);
    }

    /**
     * Get the service request this payment is linked to (optional).
     */
    public function request(): BelongsTo
    {
        return $this->belongsTo(Request::class);
    }
}

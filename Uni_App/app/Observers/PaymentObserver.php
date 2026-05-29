<?php

namespace App\Observers;

use App\Models\Payment;
use App\Repositories\Contracts\ActivityLogRepositoryInterface;

class PaymentObserver
{
    public function __construct(
        private ActivityLogRepositoryInterface $activityLogRepository
    ) {}

    /**
     * Handle the Payment "created" event.
     */
    public function created(Payment $payment): void
    {
        $this->activityLogRepository->create([
            'causer_id' => auth()->id(),
            'model_type' => Payment::class,
            'subject_id' => $payment->id,
            'action' => 'created',
            'old_values' => null,
            'new_values' => $payment->toArray(),
        ]);
    }

    /**
     * Handle the Payment "updated" event.
     */
    public function updated(Payment $payment): void
    {
        // Special attention to status changes (fraud detection)
        $changes = $payment->getChanges();
        
        $this->activityLogRepository->create([
            'causer_id' => auth()->id(),
            'model_type' => Payment::class,
            'subject_id' => $payment->id,
            'action' => 'updated',
            'old_values' => $payment->getOriginal(),
            'new_values' => $changes,
        ]);
    }
}

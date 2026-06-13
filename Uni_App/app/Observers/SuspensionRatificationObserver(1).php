<?php

namespace App\Observers;

use App\Models\SuspensionRatification;

class SuspensionRatificationObserver
{
    /**
     * Handle the SuspensionRatification "created" event.
     * Automatically update student status to SUSPENDED when debts are cleared.
     */
    public function created(SuspensionRatification $suspensionRatification): void
    {
        $this->updateStudentStatusIfCleared($suspensionRatification);
    }

    /**
     * Handle the SuspensionRatification "updated" event.
     * Automatically update student status to SUSPENDED when debts are cleared.
     */
    public function updated(SuspensionRatification $suspensionRatification): void
    {
        $this->updateStudentStatusIfCleared($suspensionRatification);
    }

    /**
     * Update student status if old debts are cleared.
     */
    private function updateStudentStatusIfCleared(SuspensionRatification $suspensionRatification): void
    {
        if ($suspensionRatification->old_debts_cleared) {
            $request = $suspensionRatification->request;
            $student = $request->student;

            if ($student && $student->status !== \App\Enums\StudentStatusEnum::SUSPENDED) {
                $student->status = \App\Enums\StudentStatusEnum::SUSPENDED;
                $student->save();

                // Also accept the request if not already approved
                if ($request->status !== \App\Enums\RequestStatusEnum::APPROVED) {
                    $request->accept('تم تصديق الإيقاف ولا توجد ديون سابقة.');
                }
            }
        }
    }
}

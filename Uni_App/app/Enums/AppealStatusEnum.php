<?php

namespace App\Enums;

enum AppealStatusEnum: string
{
    case PENDING      = 'pending';
    case PAID         = 'paid';
    case UNDER_REVIEW = 'under_review';
    case APPROVED     = 'approved';
    case REJECTED     = 'rejected';
}

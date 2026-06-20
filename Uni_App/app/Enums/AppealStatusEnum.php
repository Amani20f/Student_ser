<?php

namespace App\Enums;

enum AppealStatusEnum: string
{
    case PENDING      = 'pending';
    case PAID         = 'paid';
    case VERIFIED     = 'verified';
    case APPROVED     = 'approved';
    case REJECTED     = 'rejected';
}

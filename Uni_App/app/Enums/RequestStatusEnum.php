<?php

namespace App\Enums;

enum RequestStatusEnum: string
{
    case PENDING = 'pending';
    case RATIFIED = 'ratified';
    case APPROVED = 'approved';
    case REJECTED = 'rejected';
}


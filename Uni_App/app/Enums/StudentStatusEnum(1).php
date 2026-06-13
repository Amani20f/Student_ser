<?php

namespace App\Enums;

enum StudentStatusEnum: string
{
    case ACTIVE = 'active';
    case SUSPENDED = 'suspended';
    case GRADUATED = 'graduated';
}

<?php

namespace App\Enums;

enum GradeStatusEnum: string
{
    case PASSED = 'passed';
    case FAILED = 'failed';
    case INCOMPLETE = 'incomplete';
}

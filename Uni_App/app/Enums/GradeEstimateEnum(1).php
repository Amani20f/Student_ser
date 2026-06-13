<?php

namespace App\Enums;

enum GradeEstimateEnum: string
{
    case EXCELLENT = 'excellent';
    case VERY_GOOD = 'very_good';
    case GOOD = 'good';
    case ACCEPTABLE = 'acceptable';
    case FAIL = 'fail';
}

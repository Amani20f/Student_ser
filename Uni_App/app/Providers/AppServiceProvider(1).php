<?php

namespace App\Providers;

use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Register any application services.
     */
    public function register(): void
    {
        //
    }

    /**
     * Bootstrap any application services.
     */
    public function boot(): void
    {
        // Register Model Observers for audit logging
        \App\Models\Grade::observe(\App\Observers\GradeObserver::class);
        \App\Models\Payment::observe(\App\Observers\PaymentObserver::class);
        \App\Models\Student::observe(\App\Observers\StudentObserver::class);
        \App\Models\Request::observe(\App\Observers\RequestObserver::class);
        \App\Models\User::observe(\App\Observers\UserObserver::class);
        
        // Register SuspensionRatification observer for automatic student status updates
        \App\Models\SuspensionRatification::observe(\App\Observers\SuspensionRatificationObserver::class);
    }
}

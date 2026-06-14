<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // For PostgreSQL, drop check constraint and recreate with standardized statuses
        if (\Illuminate\Support\Facades\DB::getDriverName() !== 'sqlite') { \Illuminate\Support\Facades\DB::statement("ALTER TABLE requests DROP CONSTRAINT IF EXISTS requests_status_check"); }
        if (\Illuminate\Support\Facades\DB::getDriverName() !== 'sqlite') { \Illuminate\Support\Facades\DB::statement("ALTER TABLE requests ADD CONSTRAINT requests_status_check CHECK (status IN ('pending', 'approved', 'rejected'))"); }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        if (\Illuminate\Support\Facades\DB::getDriverName() !== 'sqlite') { \Illuminate\Support\Facades\DB::statement("ALTER TABLE requests DROP CONSTRAINT IF EXISTS requests_status_check"); }
        if (\Illuminate\Support\Facades\DB::getDriverName() !== 'sqlite') { \Illuminate\Support\Facades\DB::statement("ALTER TABLE requests ADD CONSTRAINT requests_status_check CHECK (status IN ('pending', 'approved', 'rejected'))"); }
    }
};

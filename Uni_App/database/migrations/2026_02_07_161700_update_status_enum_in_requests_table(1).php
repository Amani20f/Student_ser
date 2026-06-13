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
        DB::statement("ALTER TABLE requests DROP CONSTRAINT IF EXISTS requests_status_check");
        DB::statement("ALTER TABLE requests ADD CONSTRAINT requests_status_check CHECK (status IN ('pending', 'approved', 'rejected'))");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        DB::statement("ALTER TABLE requests DROP CONSTRAINT IF EXISTS requests_status_check");
        DB::statement("ALTER TABLE requests ADD CONSTRAINT requests_status_check CHECK (status IN ('pending', 'approved', 'rejected'))");
    }
};

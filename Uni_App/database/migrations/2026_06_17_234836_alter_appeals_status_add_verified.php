<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // Support pgsql check constraint alteration
        if (config('database.default') === 'pgsql') {
            DB::statement("ALTER TABLE appeals DROP CONSTRAINT IF EXISTS appeals_status_check");
            DB::statement("ALTER TABLE appeals ADD CONSTRAINT appeals_status_check CHECK (status::text IN ('pending', 'paid', 'under_review', 'verified', 'approved', 'rejected'))");
        }

        // Migrate any under_review status to verified
        DB::table('appeals')->where('status', 'under_review')->update(['status' => 'verified']);
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        if (config('database.default') === 'pgsql') {
            DB::statement("ALTER TABLE appeals DROP CONSTRAINT IF EXISTS appeals_status_check");
            DB::statement("ALTER TABLE appeals ADD CONSTRAINT appeals_status_check CHECK (status::text IN ('pending', 'paid', 'under_review', 'approved', 'rejected'))");
        }
        
        DB::table('appeals')->where('status', 'verified')->update(['status' => 'under_review']);
    }
};

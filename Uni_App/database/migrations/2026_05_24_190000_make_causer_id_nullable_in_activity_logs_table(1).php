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
        // Use DB statement to drop NOT NULL constraint on causer_id
        DB::statement('ALTER TABLE activity_logs ALTER COLUMN causer_id DROP NOT NULL');
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Re-apply NOT NULL constraint
        DB::statement('ALTER TABLE activity_logs ALTER COLUMN causer_id SET NOT NULL');
    }
};

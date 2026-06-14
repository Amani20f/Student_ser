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
        if (\Illuminate\Support\Facades\DB::getDriverName() !== 'sqlite') { \Illuminate\Support\Facades\DB::statement('ALTER TABLE activity_logs ALTER COLUMN causer_id DROP NOT NULL'); }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        // Re-apply NOT NULL constraint
        if (\Illuminate\Support\Facades\DB::getDriverName() !== 'sqlite') { \Illuminate\Support\Facades\DB::statement('ALTER TABLE activity_logs ALTER COLUMN causer_id SET NOT NULL'); }
    }
};

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
        Schema::table('grades', function (Blueprint $table) {
            $table->enum('grade_estimate', ['excellent', 'very_good', 'good', 'acceptable', 'fail'])->nullable();
        });

        // Update PGSQL constraint for grades status to include incomplete
        DB::statement("ALTER TABLE grades DROP CONSTRAINT IF EXISTS grades_status_check");
        DB::statement("ALTER TABLE grades ADD CONSTRAINT grades_status_check CHECK (status IN ('passed', 'failed', 'incomplete'))");
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('grades', function (Blueprint $table) {
            $table->dropColumn('grade_estimate');
        });

        DB::statement("ALTER TABLE grades DROP CONSTRAINT IF EXISTS grades_status_check");
        DB::statement("ALTER TABLE grades ADD CONSTRAINT grades_status_check CHECK (status IN ('passed', 'failed'))");
    }
};

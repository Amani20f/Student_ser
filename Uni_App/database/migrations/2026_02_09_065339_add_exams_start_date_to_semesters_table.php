<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        if (!Schema::hasColumn('semesters', 'exams_start_date')) {
            Schema::table('semesters', function (Blueprint $table) {
                $table->date('exams_start_date')->nullable()->after('is_active');
            });
        }
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        if (Schema::hasColumn('semesters', 'exams_start_date')) {
            Schema::table('semesters', function (Blueprint $table) {
                $table->dropColumn('exams_start_date');
            });
        }
    }
};

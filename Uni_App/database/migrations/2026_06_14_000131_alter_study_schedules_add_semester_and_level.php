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
        Schema::table('study_schedules', function (Blueprint $table) {
            $table->dropUnique(['program_id']);
            $table->foreignId('semester_id')->nullable()->after('program_id')->constrained()->cascadeOnDelete();
            $table->integer('level')->nullable()->after('semester_id');
            $table->unique(['program_id', 'semester_id', 'level'], 'study_schedules_p_s_l_unique');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('study_schedules', function (Blueprint $table) {
            $table->dropUnique('study_schedules_p_s_l_unique');
            $table->dropForeign(['semester_id']);
            $table->dropColumn(['semester_id', 'level']);
            $table->unique('program_id');
        });
    }
};

<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('surveys', function (Blueprint $table) {
            $table->text('description')->nullable()->after('title');
            $table->enum('target_audience', ['all_students', 'specific_college', 'specific_program'])->default('all_students')->after('google_form_url');
            $table->foreignId('target_college_id')->nullable()->after('target_audience')->constrained('colleges')->nullOnDelete();
            $table->foreignId('target_program_id')->nullable()->after('target_college_id')->constrained('programs')->nullOnDelete();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('surveys', function (Blueprint $table) {
            $table->dropForeign(['target_college_id']);
            $table->dropForeign(['target_program_id']);
            $table->dropColumn(['description', 'target_audience', 'target_college_id', 'target_program_id']);
        });
    }
};

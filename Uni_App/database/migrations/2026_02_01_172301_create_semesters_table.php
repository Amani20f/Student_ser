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
        Schema::create('semesters', function (Blueprint $table) {
            $table->id();
            $table->string('academic_year')->comment('e.g., 2025/2026');
            $table->enum('term', ['first', 'second']);
            $table->date('start_date')->nullable();
            $table->date('end_date')->nullable();
            $table->date('exams_start_date')->nullable();
            $table->boolean('is_active')->default(false);
            $table->timestamps();
            
            $table->unique(['academic_year', 'term']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('semesters');
    }
};

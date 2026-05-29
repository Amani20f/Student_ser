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
        Schema::create('courses', function (Blueprint $table) {
            $table->id();
            $table->foreignId('program_id')->constrained()->cascadeOnDelete();
            $table->string('course_code', 20)->unique();
            $table->string('course_name');
            $table->integer('credit_hours');
            $table->integer('semester_level')->comment('Fixed curriculum level 1-8');
            $table->text('description')->nullable();
            $table->timestamps();
            
            // Index for fast curriculum generation
            $table->index('semester_level');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('courses');
    }
};

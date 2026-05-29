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
        Schema::create('study_schedules', function (Blueprint $table) {
            $table->bigIncrements('id');
            
            // Foreign keys
            $table->unsignedBigInteger('program_id');
            $table->unsignedBigInteger('semester_id');
            
            // Academic information
            $table->integer('level')->comment('Academic year: 1, 2, 3, 4, etc.');
            
            // Schedule details
            $table->string('schedule_image_path')->comment('File path of uploaded schedule image');
            $table->text('notes')->nullable();
            $table->boolean('is_schedule_active')->default(true);
            
            // Timestamps
            $table->timestamps();
            
            // Foreign key constraints
            $table->foreign('program_id')
                  ->references('id')
                  ->on('programs')
                  ->onDelete('cascade');
                  
            $table->foreign('semester_id')
                  ->references('id')
                  ->on('semesters')
                  ->onDelete('cascade');
            
            // Unique constraint: One schedule per program-semester-level combination
            $table->unique(['program_id', 'semester_id', 'level'], 'unique_schedule_combination');
            
            // Additional indexes for query performance
            $table->index('is_schedule_active');
            
            // Storage engine and charset
            $table->engine = 'InnoDB';
            $table->charset = 'utf8mb4';
            $table->collation = 'utf8mb4_unicode_ci';
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('study_schedules');
    }
};

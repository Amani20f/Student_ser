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
        Schema::create('study_plans', function (Blueprint $table) {
            $table->id();
            $table->foreignId('program_id')->constrained()->cascadeOnDelete();
            $table->string('title');
            $table->string('file_path');
            $table->foreignId('uploaded_by')->constrained('users')->cascadeOnDelete();
            $table->timestamps();

            // Enforce only one active study plan per program
            $table->unique('program_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('study_plans');
    }
};

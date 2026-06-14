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
        Schema::dropIfExists('study_schedules');

        Schema::create('study_schedules', function (Blueprint $table) {
            $table->id();
            $table->foreignId('program_id')->constrained()->cascadeOnDelete();
            $table->string('title');
            $table->string('file_path');
            $table->foreignId('uploaded_by')->constrained('users')->cascadeOnDelete();
            $table->timestamps();

            // Enforce only one active study schedule per program
            $table->unique('program_id');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        //
    }
};

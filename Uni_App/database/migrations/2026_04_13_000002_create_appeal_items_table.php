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
        Schema::create('appeal_items', function (Blueprint $table) {
            $table->id();
            $table->foreignId('appeal_id')->constrained()->cascadeOnDelete();
            $table->foreignId('course_id')->constrained()->cascadeOnDelete();

            // Before appeal (snapshot of current grades)
            $table->decimal('coursework_before', 5, 2)->nullable();
            $table->decimal('final_before', 5, 2)->nullable();
            $table->decimal('total_before', 5, 2)->nullable();

            // After appeal (updated by grade control)
            $table->decimal('coursework_after', 5, 2)->nullable();
            $table->decimal('final_after', 5, 2)->nullable();
            $table->decimal('total_after', 5, 2)->nullable();

            $table->decimal('absence_percentage', 5, 2)->nullable();
            $table->timestamps();

            $table->unique(['appeal_id', 'course_id']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('appeal_items');
    }
};

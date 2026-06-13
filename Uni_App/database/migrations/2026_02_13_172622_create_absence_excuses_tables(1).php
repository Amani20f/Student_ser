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
        Schema::create('absence_excuses', function (Blueprint $table) {
            $table->id();
            $table->foreignId('request_id')->constrained()->cascadeOnDelete();
            $table->string('academic_year');
            $table->enum('semester', ['first', 'second']);
            $table->text('reason');
            $table->timestamps();
        });

        Schema::create('absence_excuse_items', function (Blueprint $table) {
            $table->id();
            $table->foreignId('absence_excuse_id')->constrained()->cascadeOnDelete();
            $table->string('course_name');
            $table->date('absence_date');
            $table->integer('prev_excused_count')->nullable();
            $table->integer('prev_unexcused_count')->nullable();
            $table->timestamps();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('absence_excuse_items');
        Schema::dropIfExists('absence_excuses');
    }
};

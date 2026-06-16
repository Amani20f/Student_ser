<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('student_applications', function (Blueprint $table) {
            $table->unsignedBigInteger('first_choice_program_id')->nullable();
            $table->unsignedBigInteger('second_choice_program_id')->nullable();
            $table->unsignedBigInteger('third_choice_program_id')->nullable();
            $table->unsignedBigInteger('approved_program_id')->nullable();

            $table->foreign('first_choice_program_id')->references('id')->on('programs')->onDelete('set null');
            $table->foreign('second_choice_program_id')->references('id')->on('programs')->onDelete('set null');
            $table->foreign('third_choice_program_id')->references('id')->on('programs')->onDelete('set null');
            $table->foreign('approved_program_id')->references('id')->on('programs')->onDelete('set null');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('student_applications', function (Blueprint $table) {
            $table->dropForeign(['first_choice_program_id']);
            $table->dropForeign(['second_choice_program_id']);
            $table->dropForeign(['third_choice_program_id']);
            $table->dropForeign(['approved_program_id']);

            $table->dropColumn([
                'first_choice_program_id',
                'second_choice_program_id',
                'third_choice_program_id',
                'approved_program_id'
            ]);
        });
    }
};

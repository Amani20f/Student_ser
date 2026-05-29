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
        Schema::table('absence_excuses', function (Blueprint $table) {
            $table->string('semester')->change();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('absence_excuses', function (Blueprint $table) {
            $table->enum('semester', ['first', 'second'])->change();
        });
    }
};

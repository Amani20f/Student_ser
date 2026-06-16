<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('programs', function (Blueprint $table) {
            $table->enum('certificate_type', ['scientific', 'literary', 'both'])->default('both');
            $table->decimal('minimum_percentage', 5, 2)->default(60.00);
            $table->boolean('is_available')->default(true);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('programs', function (Blueprint $table) {
            $table->dropColumn(['certificate_type', 'minimum_percentage', 'is_available']);
        });
    }
};

<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration {
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::table('absence_excuse_items', function (Blueprint $table) {
            // Add the day of the week for each absence (e.g., Saturday, Sunday ...)
            // Nullable for backward compatibility with older records.
            $table->string('day', 10)->nullable()->after('absence_date');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('absence_excuse_items', function (Blueprint $table) {
            $table->dropColumn('day');
        });
    }
};
?>

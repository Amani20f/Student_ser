<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\DB;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        // 1. Fill existing NULL purposes with a default value
        DB::table('payments')
            ->whereNull('purpose')
            ->update(['purpose' => 'Unspecified Payment']);

        Schema::table('payments', function (Blueprint $table) {
            // 2. Make purpose NOT NULL
            $table->string('purpose')->nullable(false)->change();

            // 3. Add request_id for linking to general service requests
            $table->foreignId('request_id')
                ->nullable()
                ->after('appeal_id')
                ->constrained('requests')
                ->nullOnDelete();
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('payments', function (Blueprint $table) {
            $table->dropForeign(['request_id']);
            $table->dropColumn('request_id');
            $table->string('purpose')->nullable()->change();
        });
    }
};

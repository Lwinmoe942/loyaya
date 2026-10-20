<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('point_transactions', function (Blueprint $table) {
            // Was globally unique — first user to claim a Watch/Survey key
            // blocked every other user from earning the same content.
            $table->dropUnique(['idempotent_key']);
            $table->unique(['user_id', 'idempotent_key'], 'point_tx_user_idempotent_unique');
        });
    }

    public function down(): void
    {
        Schema::table('point_transactions', function (Blueprint $table) {
            $table->dropUnique('point_tx_user_idempotent_unique');
            $table->unique('idempotent_key');
        });
    }
};

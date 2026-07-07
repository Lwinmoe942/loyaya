<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->string('public_id', 20)->unique()->after('id');
            $table->string('phone', 30)->nullable()->after('password');
            $table->string('tier', 20)->default('bronze')->after('phone');
            $table->string('api_token', 80)->nullable()->unique()->after('tier');
        });

        Schema::create('point_transactions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->integer('amount');
            $table->string('type', 50);
            $table->string('reference_id', 80)->nullable();
            $table->integer('balance_after');
            $table->string('idempotent_key', 120)->nullable()->unique();
            $table->timestamp('created_at')->useCurrent();
            $table->index('user_id');
        });

        Schema::create('withdraw_requests', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->integer('points');
            $table->integer('mmk_amount');
            $table->integer('rate');
            $table->string('payment_method', 30);
            $table->string('payment_phone', 30);
            $table->string('email', 190);
            $table->string('status', 20)->default('pending');
            $table->timestamps();
            $table->index('status');
            $table->index('email');
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('withdraw_requests');
        Schema::dropIfExists('point_transactions');

        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn(['public_id', 'phone', 'tier', 'api_token']);
        });
    }
};

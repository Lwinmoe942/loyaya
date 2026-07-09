<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('gift_codes', function (Blueprint $table) {
            $table->id();
            $table->string('code', 32)->unique();
            $table->integer('points');
            $table->unsignedInteger('max_uses')->default(1);
            $table->unsignedInteger('uses_count')->default(0);
            $table->timestamp('expires_at')->nullable();
            $table->timestamps();
        });

        Schema::create('gift_code_redemptions', function (Blueprint $table) {
            $table->id();
            $table->foreignId('gift_code_id')->constrained()->cascadeOnDelete();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->timestamp('created_at')->useCurrent();
            $table->unique(['gift_code_id', 'user_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('gift_code_redemptions');
        Schema::dropIfExists('gift_codes');
    }
};

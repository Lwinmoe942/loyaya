<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('content_locks', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('content_type', 32);
            $table->string('content_id', 80);
            $table->timestamp('locked_until');
            $table->timestamps();

            $table->unique(['user_id', 'content_type', 'content_id']);
            $table->index(['user_id', 'locked_until']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('content_locks');
    }
};

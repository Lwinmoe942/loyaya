<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('ai_histories', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('tool_type', 40);
            $table->text('input_preview')->nullable();
            $table->text('output_preview')->nullable();
            $table->unsignedInteger('points_charged');
            $table->string('status', 20)->default('success');
            $table->string('voice_name', 40)->nullable();
            $table->string('language', 20)->nullable();
            $table->timestamps();
            $table->index(['user_id', 'created_at']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('ai_histories');
    }
};

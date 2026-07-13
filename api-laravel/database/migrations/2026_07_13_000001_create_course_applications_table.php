<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('course_applications', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->cascadeOnDelete();
            $table->string('course_id', 80);
            $table->string('applicant_name', 120);
            $table->string('applicant_phone', 30);
            $table->integer('points_deducted');
            $table->string('status', 20)->default('pending');
            $table->timestamps();
            $table->index(['status', 'created_at']);
            $table->index(['user_id', 'course_id']);
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('course_applications');
    }
};

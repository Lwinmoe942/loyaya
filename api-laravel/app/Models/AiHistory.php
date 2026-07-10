<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class AiHistory extends Model
{
    protected $fillable = [
        'user_id',
        'tool_type',
        'input_preview',
        'output_preview',
        'points_charged',
        'status',
        'voice_name',
        'language',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}

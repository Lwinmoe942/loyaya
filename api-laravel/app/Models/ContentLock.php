<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class ContentLock extends Model
{
    protected $fillable = [
        'user_id',
        'content_type',
        'content_id',
        'locked_until',
    ];

    protected function casts(): array
    {
        return [
            'locked_until' => 'datetime',
        ];
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}

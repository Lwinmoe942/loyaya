<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class GiftCodeRedemption extends Model
{
    public $timestamps = false;

    protected $fillable = [
        'gift_code_id',
        'user_id',
        'created_at',
    ];

    protected function casts(): array
    {
        return [
            'created_at' => 'datetime',
        ];
    }

    public function giftCode(): BelongsTo
    {
        return $this->belongsTo(GiftCode::class);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}

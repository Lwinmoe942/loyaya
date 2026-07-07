<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class WithdrawRequest extends Model
{
    protected $fillable = [
        'user_id',
        'points',
        'mmk_amount',
        'rate',
        'payment_method',
        'payment_phone',
        'email',
        'status',
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}

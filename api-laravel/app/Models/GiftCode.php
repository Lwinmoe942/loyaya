<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\HasMany;

class GiftCode extends Model
{
    protected $fillable = [
        'code',
        'points',
        'max_uses',
        'uses_count',
        'expires_at',
    ];

    protected function casts(): array
    {
        return [
            'expires_at' => 'datetime',
        ];
    }

    public function redemptions(): HasMany
    {
        return $this->hasMany(GiftCodeRedemption::class);
    }
}

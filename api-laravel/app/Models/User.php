<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;

class User extends Authenticatable
{
    use Notifiable;

    protected $fillable = [
        'public_id',
        'name',
        'email',
        'password',
        'phone',
        'tier',
        'api_token',
        'device_id',
        'device_bound_at',
        'referral_code',
        'referred_by_user_id',
    ];

    protected $hidden = [
        'password',
        'api_token',
        'device_id',
        'remember_token',
    ];

    protected function casts(): array
    {
        return [
            'password' => 'hashed',
            'device_bound_at' => 'datetime',
        ];
    }

    public function pointTransactions(): HasMany
    {
        return $this->hasMany(PointTransaction::class);
    }

    public function withdrawRequests(): HasMany
    {
        return $this->hasMany(WithdrawRequest::class);
    }
}

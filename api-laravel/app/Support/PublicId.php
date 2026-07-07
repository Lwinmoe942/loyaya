<?php

namespace App\Support;

class PublicId
{
    public static function generate(): string
    {
        $part = fn () => strtoupper(bin2hex(random_bytes(2)));

        return 'LSO-'.$part().'-'.$part();
    }

    public static function token(): string
    {
        return bin2hex(random_bytes(32));
    }
}

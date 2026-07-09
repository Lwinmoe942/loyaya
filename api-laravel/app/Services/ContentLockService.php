<?php

namespace App\Services;

use App\Models\ContentLock;
use Carbon\Carbon;

class ContentLockService
{
    /** @var list<string> */
    public const LOCKABLE_TYPES = ['math_quiz', 'survey'];

    public function lockUntilTomorrow(int $userId, string $contentType, string $contentId): array
    {
        if (! in_array($contentType, self::LOCKABLE_TYPES, true)) {
            throw new \RuntimeException('INVALID_CONTENT_TYPE');
        }

        $lockedUntil = $this->nextDayStart();

        ContentLock::query()->updateOrCreate(
            [
                'user_id' => $userId,
                'content_type' => $contentType,
                'content_id' => $contentId,
            ],
            [
                'locked_until' => $lockedUntil,
            ],
        );

        return [
            'content_type' => $contentType,
            'content_id' => $contentId,
            'locked_until' => $lockedUntil->toIso8601String(),
        ];
    }

    public function isLocked(int $userId, string $contentType, string $contentId): bool
    {
        $lock = ContentLock::query()
            ->where('user_id', $userId)
            ->where('content_type', $contentType)
            ->where('content_id', $contentId)
            ->first();

        if (! $lock) {
            return false;
        }

        if (now()->gte($lock->locked_until)) {
            $lock->delete();

            return false;
        }

        return true;
    }

    public function activeLocks(int $userId): array
    {
        $now = now();

        $locks = ContentLock::query()
            ->where('user_id', $userId)
            ->where('locked_until', '>', $now)
            ->orderBy('locked_until')
            ->get(['content_type', 'content_id', 'locked_until']);

        ContentLock::query()
            ->where('user_id', $userId)
            ->where('locked_until', '<=', $now)
            ->delete();

        return $locks->map(fn (ContentLock $lock) => [
            'content_type' => $lock->content_type,
            'content_id' => $lock->content_id,
            'locked_until' => $lock->locked_until?->toIso8601String(),
        ])->all();
    }

    private function nextDayStart(): Carbon
    {
        return now()->addDay()->startOfDay();
    }
}

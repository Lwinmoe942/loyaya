<?php

namespace App\Services;

use App\Models\AiHistory;
use App\Models\PointTransaction;
use Illuminate\Support\Str;

class AiService
{
    public function __construct(private readonly PointService $points) {}

    /** @return array<string, mixed> */
    public function recordToText(
        int $userId,
        string $text,
        int $durationSeconds,
        string $language,
        string $requestId,
    ): array {
        $requestId = $this->normalizeRequestId($requestId);
        $cost = $this->costForRecordToText($durationSeconds);

        return $this->chargeAndSave(
            $userId,
            'record_to_text',
            $cost,
            $requestId,
            [
                'input_preview' => 'Voice recording',
                'output_preview' => Str::limit(trim($text), 500),
                'language' => $language,
            ],
        );
    }

    /** @return array<string, mixed> */
    public function textToVoice(
        int $userId,
        string $text,
        string $voice,
        string $requestId,
    ): array {
        $requestId = $this->normalizeRequestId($requestId);
        $text = trim($text);
        if ($text === '') {
            throw new \RuntimeException('EMPTY_TEXT');
        }

        $cost = $this->costForTextToVoice($text);

        return $this->chargeAndSave(
            $userId,
            'text_to_voice',
            $cost,
            $requestId,
            [
                'input_preview' => Str::limit($text, 500),
                'output_preview' => 'Voice generated',
                'voice_name' => $voice,
            ],
        );
    }

    /** @return list<array<string, mixed>> */
    public function history(int $userId, int $limit = 50): array
    {
        return AiHistory::query()
            ->where('user_id', $userId)
            ->orderByDesc('created_at')
            ->limit($limit)
            ->get()
            ->map(fn (AiHistory $item) => $this->formatHistory($item))
            ->all();
    }

    public function costForRecordToText(int $durationSeconds): int
    {
        $seconds = max(1, $durationSeconds);

        return max(1, (int) ceil($seconds / 10));
    }

    public function costForTextToVoice(string $text): int
    {
        $length = max(1, mb_strlen(trim($text)));

        return max(1, (int) ceil($length / 50));
    }

    /** @param array<string, mixed> $payload */
    private function chargeAndSave(
        int $userId,
        string $toolType,
        int $cost,
        string $requestId,
        array $payload,
    ): array {
        $key = "ai_{$toolType}_{$userId}_{$requestId}";

        if ($this->points->getBalance($userId) < $cost) {
            throw new \RuntimeException('INSUFFICIENT_POINTS');
        }

        $existingTx = PointTransaction::query()
            ->where('idempotent_key', $key)
            ->first();

        if ($existingTx) {
            $history = AiHistory::query()
                ->where('user_id', $userId)
                ->where('tool_type', $toolType)
                ->orderByDesc('created_at')
                ->first();

            return [
                'duplicate' => true,
                'points_charged' => $cost,
                'history' => $history ? $this->formatHistory($history) : null,
                'balance' => $this->points->getBalance($userId),
            ];
        }

        $result = $this->points->addTransaction(
            $userId,
            -$cost,
            "ai_{$toolType}",
            $requestId,
            $key,
        );

        if ($result['duplicate']) {
            throw new \RuntimeException('ALREADY_PROCESSED');
        }

        $history = AiHistory::query()->create([
            'user_id' => $userId,
            'tool_type' => $toolType,
            'input_preview' => $payload['input_preview'] ?? null,
            'output_preview' => $payload['output_preview'] ?? null,
            'points_charged' => $cost,
            'status' => 'success',
            'voice_name' => $payload['voice_name'] ?? null,
            'language' => $payload['language'] ?? null,
        ]);

        return [
            'duplicate' => false,
            'points_charged' => $cost,
            'balance' => $result['balance'],
            'history' => $this->formatHistory($history),
        ];
    }

    /** @return array<string, mixed> */
    private function formatHistory(AiHistory $item): array
    {
        return [
            'id' => $item->id,
            'tool_type' => $item->tool_type,
            'title' => $item->tool_type === 'record_to_text'
                ? 'Record to Text'
                : 'Text to Voice',
            'input_preview' => $item->input_preview,
            'output_preview' => $item->output_preview,
            'points_charged' => $item->points_charged,
            'status' => $item->status,
            'voice_name' => $item->voice_name,
            'language' => $item->language,
            'created_at' => $item->created_at?->toIso8601String(),
        ];
    }

    private function normalizeRequestId(string $requestId): string
    {
        $requestId = preg_replace('/[^a-zA-Z0-9_-]/', '', $requestId) ?? '';

        if ($requestId === '' || strlen($requestId) > 80) {
            throw new \RuntimeException('INVALID_REQUEST');
        }

        return $requestId;
    }
}

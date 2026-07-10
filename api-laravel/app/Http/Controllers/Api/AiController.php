<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\AiService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class AiController extends Controller
{
    public function __construct(private readonly AiService $ai) {}

    public function history(Request $request): JsonResponse
    {
        $user = $request->attributes->get('auth_user');

        return response()->json([
            'items' => $this->ai->history($user->id),
        ]);
    }

    public function recordToText(Request $request): JsonResponse
    {
        $data = $request->validate([
            'text' => ['required', 'string', 'max:5000'],
            'duration_seconds' => ['required', 'integer', 'min:1', 'max:3600'],
            'language' => ['required', 'string', 'max:20'],
            'request_id' => ['required', 'string', 'max:80'],
        ]);

        $user = $request->attributes->get('auth_user');

        try {
            $result = $this->ai->recordToText(
                $user->id,
                $data['text'],
                (int) $data['duration_seconds'],
                $data['language'],
                $data['request_id'],
            );
        } catch (\RuntimeException $e) {
            $code = match ($e->getMessage()) {
                'INSUFFICIENT_POINTS' => 402,
                'ALREADY_PROCESSED' => 409,
                default => 400,
            };

            return response()->json(['error' => $e->getMessage()], $code);
        }

        return response()->json([
            'points_charged' => $result['points_charged'],
            'balance' => $result['balance'],
            'history' => $result['history'],
            'message' => "Transcription saved. -{$result['points_charged']} points.",
        ]);
    }

    public function textToVoice(Request $request): JsonResponse
    {
        $data = $request->validate([
            'text' => ['required', 'string', 'max:5000'],
            'voice' => ['required', 'string', 'max:40'],
            'request_id' => ['required', 'string', 'max:80'],
        ]);

        $user = $request->attributes->get('auth_user');

        try {
            $result = $this->ai->textToVoice(
                $user->id,
                $data['text'],
                $data['voice'],
                $data['request_id'],
            );
        } catch (\RuntimeException $e) {
            $code = match ($e->getMessage()) {
                'INSUFFICIENT_POINTS' => 402,
                'EMPTY_TEXT' => 422,
                'ALREADY_PROCESSED' => 409,
                default => 400,
            };

            return response()->json(['error' => $e->getMessage()], $code);
        }

        return response()->json([
            'points_charged' => $result['points_charged'],
            'balance' => $result['balance'],
            'history' => $result['history'],
            'message' => "Voice generated. -{$result['points_charged']} points.",
        ]);
    }

    public function estimate(Request $request): JsonResponse
    {
        $data = $request->validate([
            'tool' => ['required', 'string', 'in:record_to_text,text_to_voice'],
            'duration_seconds' => ['nullable', 'integer', 'min:1', 'max:3600'],
            'text' => ['nullable', 'string', 'max:5000'],
        ]);

        $cost = match ($data['tool']) {
            'record_to_text' => $this->ai->costForRecordToText((int) ($data['duration_seconds'] ?? 1)),
            default => $this->ai->costForTextToVoice((string) ($data['text'] ?? '')),
        };

        return response()->json(['points_cost' => $cost]);
    }
}

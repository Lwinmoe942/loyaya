<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\CpxService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Http\Response;
use Illuminate\Support\Facades\Log;

class CpxController extends Controller
{
    public function __construct(private readonly CpxService $cpx) {}

    public function config(Request $request): JsonResponse
    {
        $user = $request->attributes->get('auth_user');

        try {
            return response()->json($this->cpx->buildClientConfig($user));
        } catch (\RuntimeException $e) {
            if ($e->getMessage() === 'CPX_NOT_CONFIGURED') {
                return response()->json(['error' => 'CPX_NOT_CONFIGURED'], 503);
            }

            throw $e;
        }
    }

    public function postback(Request $request): Response
    {
        if (! $this->cpx->isAllowedIp($request->ip())) {
            Log::warning('CPX postback blocked IP', ['ip' => $request->ip()]);

            return response('0', 403);
        }

        $params = array_merge($request->query(), $request->post());

        try {
            $result = $this->cpx->handlePostback($params);
            Log::info('CPX postback ok', array_merge(
                ['ip' => $request->ip()],
                ['trans_id' => $params['trans_id'] ?? null, 'user_id' => $params['user_id'] ?? null],
                $result,
            ));
        } catch (\RuntimeException $e) {
            Log::warning('CPX postback rejected', [
                'error' => $e->getMessage(),
                'ip' => $request->ip(),
                'trans_id' => $params['trans_id'] ?? null,
            ]);

            return response('0', 400);
        }

        return response('1', 200);
    }
}

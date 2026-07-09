<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\ContentLockService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Validation\Rule;

class ContentController extends Controller
{
    public function __construct(private readonly ContentLockService $locks) {}

    public function locks(Request $request): JsonResponse
    {
        $user = $request->attributes->get('auth_user');

        return response()->json([
            'locks' => $this->locks->activeLocks($user->id),
        ]);
    }

    public function fail(Request $request): JsonResponse
    {
        $data = $request->validate([
            'content_type' => ['required', 'string', Rule::in(ContentLockService::LOCKABLE_TYPES)],
            'content_id' => ['required', 'string', 'max:80'],
        ]);

        $user = $request->attributes->get('auth_user');

        try {
            $lock = $this->locks->lockUntilTomorrow(
                $user->id,
                $data['content_type'],
                $data['content_id'],
            );
        } catch (\RuntimeException $e) {
            return response()->json(['error' => $e->getMessage()], 400);
        }

        return response()->json($lock);
    }
}

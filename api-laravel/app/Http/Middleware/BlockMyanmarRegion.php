<?php

namespace App\Http\Middleware;

use App\Services\RegionService;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class BlockMyanmarRegion
{
    public function __construct(private readonly RegionService $regions) {}

    public function handle(Request $request, Closure $next): Response
    {
        $result = $this->regions->evaluate($request);

        if ($result['allowed']) {
            return $next($request);
        }

        return response()->json([
            'error' => 'REGION_BLOCKED',
            'country' => $result['country'],
            'reason' => $result['reason'],
            'message' => $this->regions->blockMessage(),
        ], 403);
    }
}

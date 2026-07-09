<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\ContentCatalogService;
use Illuminate\Http\JsonResponse;

class CatalogController extends Controller
{
    public function __construct(private readonly ContentCatalogService $catalog) {}

    public function tutorials(): JsonResponse
    {
        return response()->json(['items' => $this->catalog->tutorials()]);
    }

    public function classroom(): JsonResponse
    {
        return response()->json(['items' => $this->catalog->classroom()]);
    }

    public function watchVideos(): JsonResponse
    {
        return response()->json(['items' => $this->catalog->watchVideos()]);
    }
}

<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Services\CourseService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CoursesController extends Controller
{
    public function __construct(private readonly CourseService $courses) {}

    public function index(): JsonResponse
    {
        return response()->json(['items' => $this->courses->catalog()]);
    }

    public function applications(Request $request): JsonResponse
    {
        $user = $request->attributes->get('auth_user');

        return response()->json([
            'applications' => $this->courses->applicationsForUser($user->id),
            'contact_email' => config('lotaya.course_contact_email'),
        ]);
    }

    public function apply(Request $request): JsonResponse
    {
        $data = $request->validate([
            'course_id' => ['required', 'string', 'max:80'],
            'name' => ['required', 'string', 'max:120'],
            'phone' => ['required', 'string', 'max:30'],
        ]);

        $user = $request->attributes->get('auth_user');

        try {
            $result = $this->courses->apply(
                $user,
                $data['course_id'],
                trim($data['name']),
                trim($data['phone']),
            );
        } catch (\RuntimeException $e) {
            $map = [
                'INVALID_COURSE' => 404,
                'INSUFFICIENT_POINTS_FOR_COURSE' => 422,
                'COURSE_ALREADY_APPLIED' => 409,
            ];

            return response()->json(
                ['error' => $e->getMessage()],
                $map[$e->getMessage()] ?? 400,
            );
        }

        return response()->json($result);
    }
}

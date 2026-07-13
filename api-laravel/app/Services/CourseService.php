<?php

namespace App\Services;

use App\Models\CourseApplication;
use App\Models\User;
use Illuminate\Support\Facades\DB;

class CourseService
{
    public function __construct(
        private readonly ContentCatalogService $catalog,
        private readonly PointService $points,
    ) {}

    /** @return list<array<string, mixed>> */
    public function catalog(): array
    {
        return $this->catalog->courses();
    }

    public function findCourse(string $courseId): ?array
    {
        foreach ($this->catalog() as $course) {
            if (($course['id'] ?? '') === $courseId) {
                return $course;
            }
        }

        return null;
    }

    /** @return list<array<string, mixed>> */
    public function applicationsForUser(int $userId): array
    {
        return CourseApplication::query()
            ->where('user_id', $userId)
            ->orderByDesc('id')
            ->get()
            ->map(fn (CourseApplication $row) => $this->presentApplication($row))
            ->all();
    }

    /** @return array<string, mixed> */
    public function apply(User $user, string $courseId, string $name, string $phone): array
    {
        $course = $this->findCourse($courseId);
        if (! $course) {
            throw new \RuntimeException('INVALID_COURSE');
        }

        $required = (int) ($course['points_required'] ?? 0);
        $balance = $this->points->getBalance($user->id);
        if ($balance < $required) {
            throw new \RuntimeException('INSUFFICIENT_POINTS_FOR_COURSE');
        }

        $active = CourseApplication::query()
            ->where('user_id', $user->id)
            ->where('course_id', $courseId)
            ->whereIn('status', ['pending', 'approved'])
            ->exists();

        if ($active) {
            throw new \RuntimeException('COURSE_ALREADY_APPLIED');
        }

        $application = DB::transaction(function () use ($user, $courseId, $name, $phone, $balance) {
            $deduct = $balance;
            if ($deduct > 0) {
                $this->points->addTransaction(
                    $user->id,
                    -$deduct,
                    'course_apply',
                    $courseId,
                    "course_apply_{$user->id}_{$courseId}_".now()->timestamp,
                );
            }

            return CourseApplication::query()->create([
                'user_id' => $user->id,
                'course_id' => $courseId,
                'applicant_name' => $name,
                'applicant_phone' => $phone,
                'points_deducted' => $deduct,
                'status' => 'pending',
            ]);
        });

        return [
            'application' => $this->presentApplication($application),
            'balance' => $this->points->getBalance($user->id),
            'contact_email' => config('lotaya.course_contact_email'),
        ];
    }

    public function approve(int $applicationId): void
    {
        $row = CourseApplication::query()->findOrFail($applicationId);
        if ($row->status !== 'pending') {
            throw new \RuntimeException('INVALID_STATUS');
        }

        $row->update(['status' => 'approved']);
    }

    public function reject(int $applicationId): void
    {
        $row = CourseApplication::query()->findOrFail($applicationId);
        if ($row->status !== 'pending') {
            throw new \RuntimeException('INVALID_STATUS');
        }

        $row->update(['status' => 'rejected']);
    }

    /** @return array<string, mixed> */
    private function presentApplication(CourseApplication $row): array
    {
        $course = $this->findCourse($row->course_id);

        return [
            'id' => $row->id,
            'course_id' => $row->course_id,
            'course_title' => $course['title'] ?? $row->course_id,
            'applicant_name' => $row->applicant_name,
            'applicant_phone' => $row->applicant_phone,
            'points_deducted' => $row->points_deducted,
            'status' => $row->status,
            'video_url' => $row->status === 'approved'
                ? ($course['video_url'] ?? null)
                : null,
            'created_at' => $row->created_at?->toIso8601String(),
        ];
    }
}

<?php

namespace App\Services;

class ContentCatalogService
{
    /** @return list<array<string, mixed>> */
    public function tutorials(): array
    {
        return $this->load('tutorials.json');
    }

    /** @return list<array<string, mixed>> */
    public function classroom(): array
    {
        return $this->load('classroom.json');
    }

    /** @return list<array<string, mixed>> */
    public function watchVideos(): array
    {
        return $this->load('watch_videos.json');
    }

    /** @return list<array<string, mixed>> */
    public function courses(): array
    {
        return $this->load('courses.json');
    }

    /** @return list<array<string, mixed>> */
    private function load(string $filename): array
    {
        $path = resource_path('content/'.$filename);
        if (! is_file($path)) {
            return [];
        }

        $data = json_decode((string) file_get_contents($path), true);

        return is_array($data) ? $data : [];
    }
}

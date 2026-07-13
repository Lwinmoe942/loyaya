@extends('layouts.admin')

@section('title', 'Course Applications — Admin')

@section('content')
    <div class="card">
        <h2>Course Applications</h2>
        <p class="lead">
            Users apply with name &amp; phone after reaching the point threshold.
            All points are deducted on apply. Contact them at
            <strong>{{ config('lotaya.course_contact_email') }}</strong>.
        </p>

        <div class="filter-nav">
            @foreach (['pending', 'approved', 'rejected'] as $s)
                <a href="{{ route('admin.course-applications', ['status' => $s]) }}"
                   @if($status === $s) class="is-active" @endif>
                    {{ ucfirst($s) }} ({{ $counts[$s] ?? 0 }})
                </a>
            @endforeach
        </div>

        <div class="table-wrap">
            <table>
                <thead>
                    <tr>
                        <th>ID</th>
                        <th>Public ID</th>
                        <th>Course</th>
                        <th>Name</th>
                        <th>Phone</th>
                        <th>Points</th>
                        <th>Status</th>
                        <th>Date</th>
                        <th></th>
                    </tr>
                </thead>
                <tbody>
                    @forelse ($applications as $row)
                        <tr>
                            <td>{{ $row->id }}</td>
                            <td>{{ $row->user?->public_id }}</td>
                            <td>{{ $row->course_id }}</td>
                            <td>{{ $row->applicant_name }}</td>
                            <td><a href="tel:{{ $row->applicant_phone }}">{{ $row->applicant_phone }}</a></td>
                            <td>{{ number_format($row->points_deducted) }}</td>
                            <td>
                                <span class="badge badge-{{ $row->status }}">{{ $row->status }}</span>
                            </td>
                            <td>{{ $row->created_at?->format('Y-m-d H:i') }}</td>
                            <td>
                                @if ($row->status === 'pending')
                                    <form method="post" action="{{ route('admin.course-applications.approve', $row->id) }}" style="display:inline;">
                                        @csrf
                                        <button class="btn" type="submit">Approve</button>
                                    </form>
                                    <form method="post" action="{{ route('admin.course-applications.reject', $row->id) }}" style="display:inline;">
                                        @csrf
                                        <button class="btn btn-secondary" type="submit">Reject</button>
                                    </form>
                                @endif
                            </td>
                        </tr>
                    @empty
                        <tr>
                            <td colspan="9">No applications.</td>
                        </tr>
                    @endforelse
                </tbody>
            </table>
        </div>
    </div>
@endsection

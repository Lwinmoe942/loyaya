@extends('layouts.admin')

@section('title', 'Gift Codes — Lotaya Shwe Oh')

@section('content')
<div class="card">
    <h2>Create Gift Codes</h2>
    <p class="lead">Generate codes for users to redeem in the app (Redeem Gift Code screen).</p>

    <form method="post" action="{{ route('admin.gift-codes.create') }}">
        @csrf
        <div class="field-row">
            <div>
                <label for="points">Points per code</label>
                <input id="points" name="points" type="number" min="1" value="100" required>
            </div>
            <div>
                <label for="count">How many codes</label>
                <input id="count" name="count" type="number" min="1" max="50" value="5" required>
            </div>
            <div>
                <label for="max_uses">Max uses each</label>
                <input id="max_uses" name="max_uses" type="number" min="1" value="1" required>
            </div>
        </div>
        <button class="btn" type="submit" style="margin-top:12px;">Generate Codes</button>
    </form>
</div>

<div class="card">
    <h2>Recent Gift Codes</h2>
    @if ($codes->isEmpty())
        <p style="color:var(--muted);">No gift codes yet.</p>
    @else
        <div class="table-wrap">
            <table>
                <thead>
                    <tr>
                        <th>Code</th>
                        <th>Points</th>
                        <th>Uses</th>
                        <th>Expires</th>
                        <th>Created</th>
                    </tr>
                </thead>
                <tbody>
                    @foreach ($codes as $code)
                        <tr>
                            <td><strong>{{ $code->code }}</strong></td>
                            <td>{{ number_format($code->points) }}</td>
                            <td>{{ $code->uses_count }} / {{ $code->max_uses }}</td>
                            <td>{{ $code->expires_at?->format('Y-m-d') ?? '—' }}</td>
                            <td>{{ $code->created_at?->format('Y-m-d H:i') }}</td>
                        </tr>
                    @endforeach
                </tbody>
            </table>
        </div>
    @endif
</div>
@endsection

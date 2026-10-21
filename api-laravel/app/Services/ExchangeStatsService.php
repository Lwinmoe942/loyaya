<?php

namespace App\Services;

use App\Models\PointTransaction;
use App\Models\User;
use App\Models\WithdrawRequest;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;

class ExchangeStatsService
{
    /** @return array<string, int> */
    public function statusCounts(): array
    {
        $rows = WithdrawRequest::query()
            ->select('status', DB::raw('COUNT(*) as total'))
            ->groupBy('status')
            ->pluck('total', 'status');

        return [
            'total' => (int) $rows->sum(),
            'approved' => (int) ($rows['approved'] ?? 0),
            'pending' => (int) ($rows['pending'] ?? 0),
            'rejected' => (int) ($rows['rejected'] ?? 0),
        ];
    }

    public function totalApprovedMmk(): int
    {
        return (int) WithdrawRequest::query()
            ->where('status', 'approved')
            ->sum('mmk_amount');
    }

    public function totalPendingMmk(): int
    {
        return (int) WithdrawRequest::query()
            ->where('status', 'pending')
            ->sum('mmk_amount');
    }

    /** Sum of every user's current point balance (outstanding liability in points). */
    public function totalOutstandingPoints(): int
    {
        return (int) PointTransaction::query()->sum('amount');
    }

    /** Lifetime points credited (positive ledger rows only). */
    public function totalPointsEarned(): int
    {
        return (int) PointTransaction::query()
            ->where('amount', '>', 0)
            ->sum('amount');
    }

    /** Points already locked/paid via approved withdraws. */
    public function totalApprovedPoints(): int
    {
        return (int) WithdrawRequest::query()
            ->where('status', 'approved')
            ->sum('points');
    }

    /**
     * Estimated MMK if every outstanding balance were cashed at each user's tier rate.
     *
     * @return array{
     *   outstanding_points: int,
     *   points_earned: int,
     *   approved_points: int,
     *   approved_mmk: int,
     *   pending_mmk: int,
     *   estimated_liability_mmk: int
     * }
     */
    public function financeSnapshot(): array
    {
        $rates = config('lotaya.rates', []);
        $balances = DB::table('users')
            ->leftJoin('point_transactions', 'point_transactions.user_id', '=', 'users.id')
            ->groupBy('users.id', 'users.tier')
            ->select([
                'users.tier',
                DB::raw('COALESCE(SUM(point_transactions.amount), 0) as balance'),
            ])
            ->get();

        $liability = 0;
        foreach ($balances as $row) {
            $bal = max(0, (int) $row->balance);
            $rate = (int) ($rates[$row->tier] ?? $rates['bronze'] ?? 3);
            $liability += $bal * $rate;
        }

        return [
            'outstanding_points' => $this->totalOutstandingPoints(),
            'points_earned' => $this->totalPointsEarned(),
            'approved_points' => $this->totalApprovedPoints(),
            'approved_mmk' => $this->totalApprovedMmk(),
            'pending_mmk' => $this->totalPendingMmk(),
            'estimated_liability_mmk' => $liability,
        ];
    }

    /** @return array<string, int> */
    public function approvedMmkByPaymentMethod(): array
    {
        $methods = ['kbz', 'wave', 'true_money'];
        $rows = WithdrawRequest::query()
            ->select('payment_method', DB::raw('SUM(mmk_amount) as total'))
            ->where('status', 'approved')
            ->whereIn('payment_method', $methods)
            ->groupBy('payment_method')
            ->pluck('total', 'payment_method');

        $result = [];
        foreach ($methods as $method) {
            $result[$method] = (int) ($rows[$method] ?? 0);
        }

        return $result;
    }

    /** @return array<string, int> */
    public function tierUserCounts(): array
    {
        $tiers = ['diamond', 'fire', 'gold', 'silver', 'bronze'];
        $rows = User::query()
            ->select('tier', DB::raw('COUNT(*) as total'))
            ->groupBy('tier')
            ->pluck('total', 'tier');

        $result = [];
        foreach ($tiers as $tier) {
            $result[$tier] = (int) ($rows[$tier] ?? 0);
        }

        return $result;
    }

    public function recentTransactions(int $perPage = 15): LengthAwarePaginator
    {
        return WithdrawRequest::query()
            ->with('user:id,tier')
            ->orderByDesc('id')
            ->paginate($perPage)
            ->withQueryString();
    }

    /** @return Collection<int, array{tier: string, min: int, rate: int, users: int, label: string}> */
    public function tierCards(): Collection
    {
        $rates = config('lotaya.rates', []);
        $thresholds = config('lotaya.tier_thresholds', []);
        $counts = $this->tierUserCounts();

        $labels = [
            'diamond' => '10,000+ Points',
            'fire' => '6,000+ Points',
            'gold' => '3,000+ Points',
            'silver' => '1,000+ Points',
            'bronze' => '0–999 Points',
        ];

        return collect($thresholds)->map(function (array $item) use ($rates, $counts, $labels) {
            $tier = $item['tier'];

            return [
                'tier' => $tier,
                'min' => (int) $item['min'],
                'rate' => (int) ($rates[$tier] ?? 3),
                'users' => $counts[$tier] ?? 0,
                'label' => $labels[$tier] ?? ucfirst($tier),
            ];
        });
    }
}

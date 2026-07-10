<?php

namespace App\Http\Controllers;

use App\Models\WithdrawRequest;
use App\Services\ExchangeStatsService;
use App\Services\PointService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

class ExchangeController extends Controller
{
    public function __construct(
        private readonly PointService $points,
        private readonly ExchangeStatsService $stats,
    ) {}

    public function index(Request $request): View
    {
        $statusCounts = $this->stats->statusCounts();

        return view('exchange.index', [
            'minPoints' => config('lotaya.min_withdraw_points', 500),
            'step' => config('lotaya.withdraw_step', 500),
            'rates' => config('lotaya.rates', []),
            'statusCounts' => $statusCounts,
            'totalApprovedMmk' => $this->stats->totalApprovedMmk(),
            'paymentTotals' => $this->stats->approvedMmkByPaymentMethod(),
            'tierCards' => $this->stats->tierCards(),
            'transactions' => $this->stats->recentTransactions(15),
        ]);
    }

    public function submit(Request $request): RedirectResponse
    {
        $data = $request->validate([
            'public_id' => ['required', 'string', 'max:20'],
            'name' => ['nullable', 'string', 'max:120'],
            'email' => ['required', 'email', 'max:190'],
            'points' => ['required', 'integer'],
            'payment_method' => ['required', 'in:kbz,wave,true_money'],
            'payment_phone' => ['required', 'string', 'max:30'],
        ]);

        try {
            $this->points->validateWithdrawAmount((int) $data['points']);
        } catch (\RuntimeException $e) {
            return back()->withInput()->with('error', $this->errorMessage($e->getMessage()));
        }

        $user = \App\Models\User::query()->where('public_id', $data['public_id'])->first();
        if (! $user) {
            return back()->withInput()->with('error', 'User ID မတွေ့ပါ။ App ထဲက ID ကို ပြန်စစ်ပါ။');
        }

        $min = (int) config('lotaya.min_withdraw_points', 500);
        $balance = $this->points->getBalance($user->id);
        if ($balance < $min) {
            return back()->withInput()->with(
                'error',
                "လက်ရှိ point {$balance} သာ ရှိပါသည်။ အနည်းဆုံး {$min} points လိုအပ်ပါသည်။",
            );
        }

        $points = (int) $data['points'];
        if ($balance < $points) {
            return back()->withInput()->with('error', "Point မလုံလောက်ပါ။ လက်ရှိ: {$balance}");
        }

        $tier = $this->points->syncUserTier($user->id);
        $rate = $this->points->getRateForTier($tier);
        $mmkAmount = $points * $rate;

        $withdraw = WithdrawRequest::query()->create([
            'user_id' => $user->id,
            'points' => $points,
            'mmk_amount' => $mmkAmount,
            'rate' => $rate,
            'payment_method' => $data['payment_method'],
            'payment_phone' => $data['payment_phone'],
            'email' => strtolower($data['email']),
            'status' => 'pending',
        ]);

        $this->points->lockWithdrawPoints($user->id, $points, $withdraw->id);

        return redirect()
            ->route('exchange.status.form')
            ->with('success', "တောင်းဆိုမှု #{$withdraw->id} အောင်မြင်ပါပြီ။ {$points} pts = {$mmkAmount} MMK (rate {$rate})");
    }

    public function status(Request $request): View
    {
        $email = $request->query('email');
        $requests = null;

        if (is_string($email) && trim($email) !== '') {
            $email = strtolower(trim($email));
            if (! filter_var($email, FILTER_VALIDATE_EMAIL)) {
                return view('exchange.status', [
                    'email' => $email,
                    'statusError' => 'Email မှန်ကန်စွာ ထည့်ပါ။',
                ]);
            }

            $requests = WithdrawRequest::query()
                ->where('email', $email)
                ->orderByDesc('id')
                ->limit(20)
                ->get();
        }

        return view('exchange.status', [
            'email' => $email,
            'requests' => $requests,
        ]);
    }

    /** @deprecated Use GET /exchange/status?email= instead */
    public function statusCheck(Request $request): View
    {
        $request->validate([
            'email' => ['required', 'email', 'max:190'],
        ]);

        return redirect()->route('exchange.status.form', [
            'email' => $request->input('email'),
        ]);
    }

    private function errorMessage(string $code): string
    {
        return match ($code) {
            'BELOW_MINIMUM' => 'အနည်းဆုံး '.config('lotaya.min_withdraw_points', 500).' points ထုတ်ရပါမယ်။',
            'INVALID_STEP' => 'Point ပမာဏက '.config('lotaya.withdraw_step', 500).' ဖြင့် စားပြတ်ရပါမယ်။',
            default => 'တောင်းဆိုမှု မအောင်မြင်ပါ။',
        };
    }
}

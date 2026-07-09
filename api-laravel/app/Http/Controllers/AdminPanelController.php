<?php

namespace App\Http\Controllers;

use App\Models\GiftCode;
use App\Models\User;
use App\Models\WithdrawRequest;
use App\Services\ExchangeStatsService;
use App\Services\GiftCodeService;
use App\Services\PointService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

class AdminPanelController extends Controller
{
    public function __construct(
        private readonly PointService $points,
        private readonly ExchangeStatsService $stats,
        private readonly GiftCodeService $gifts,
    ) {}

    public function loginForm(): View
    {
        return view('admin.login');
    }

    public function login(Request $request): RedirectResponse
    {
        $data = $request->validate([
            'admin_password' => ['required', 'string'],
        ]);

        $expected = config('lotaya.admin_password') ?: config('lotaya.admin_api_key');
        if (! $expected || ! hash_equals($expected, $data['admin_password'])) {
            return back()->with('error', 'Invalid admin password.');
        }

        $request->session()->put('admin_authenticated', true);
        $request->session()->regenerate();

        return redirect()->route('admin.dashboard');
    }

    public function logout(Request $request): RedirectResponse
    {
        $request->session()->forget('admin_authenticated');
        $request->session()->regenerateToken();

        return redirect()->route('admin.login');
    }

    public function dashboard(Request $request): View
    {
        $status = $request->query('status', 'pending');
        $statusCounts = $this->stats->statusCounts();

        $requests = WithdrawRequest::query()
            ->with('user:id,public_id,name,tier')
            ->where('status', $status)
            ->orderByDesc('id')
            ->limit(50)
            ->get();

        return view('admin.dashboard', [
            'status' => $status,
            'statusCounts' => $statusCounts,
            'totalApprovedMmk' => $this->stats->totalApprovedMmk(),
            'paymentTotals' => $this->stats->approvedMmkByPaymentMethod(),
            'tierCards' => $this->stats->tierCards(),
            'userCount' => User::query()->count(),
            'giftCodeCount' => GiftCode::query()->count(),
            'requests' => $requests,
        ]);
    }

    public function giftCodes(): View
    {
        $codes = GiftCode::query()
            ->orderByDesc('id')
            ->limit(100)
            ->get();

        return view('admin.gift_codes', [
            'codes' => $codes,
        ]);
    }

    public function createGiftCodes(Request $request): RedirectResponse
    {
        $data = $request->validate([
            'points' => ['required', 'integer', 'min:1', 'max:100000'],
            'count' => ['required', 'integer', 'min:1', 'max:50'],
            'max_uses' => ['nullable', 'integer', 'min:1', 'max:1000'],
        ]);

        $codes = $this->gifts->generateBatch(
            (int) $data['points'],
            (int) $data['count'],
            (int) ($data['max_uses'] ?? 1),
        );

        return back()->with('success', count($codes).' gift codes created: '.implode(', ', $codes));
    }

    public function withdraws(Request $request): View
    {
        return $this->dashboard($request);
    }

    public function approve(int $id): RedirectResponse
    {
        $row = WithdrawRequest::query()->findOrFail($id);

        if ($row->status !== 'pending') {
            return back()->with('error', 'ဒီတောင်းဆိုမှုကို လုပ်ပြီးသားပါ။');
        }

        $row->update(['status' => 'approved']);

        return back()->with('success', "#{$id} ကို approve လုပ်ပြီးပါပြီ။ KBZ/Wave လွှဲပေးပါ။");
    }

    public function reject(int $id): RedirectResponse
    {
        $row = WithdrawRequest::query()->findOrFail($id);

        if ($row->status !== 'pending') {
            return back()->with('error', 'ဒီတောင်းဆိုမှုကို လုပ်ပြီးသားပါ။');
        }

        $this->points->refundWithdrawPoints($row->user_id, $row->points, $row->id);
        $row->update(['status' => 'rejected']);

        return back()->with('success', "#{$id} ကို reject လုပ်ပြီး point ပြန်ပေးပြီးပါပြီ။");
    }
}

<?php

namespace App\Http\Controllers;

use App\Models\WithdrawRequest;
use App\Services\PointService;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\View\View;

class AdminPanelController extends Controller
{
    public function __construct(private readonly PointService $points) {}

    public function loginForm(): View
    {
        return view('admin.login');
    }

    public function login(Request $request): RedirectResponse
    {
        $data = $request->validate([
            'admin_key' => ['required', 'string'],
        ]);

        $expected = config('lotaya.admin_api_key');
        if (! $expected || ! hash_equals($expected, $data['admin_key'])) {
            return back()->with('error', 'Admin key မှားနေပါတယ်။');
        }

        $request->session()->put('admin_authenticated', true);

        return redirect()->route('admin.withdraws');
    }

    public function logout(Request $request): RedirectResponse
    {
        $request->session()->forget('admin_authenticated');

        return redirect()->route('admin.login');
    }

    public function withdraws(Request $request): View
    {
        $status = $request->query('status', 'pending');

        $requests = WithdrawRequest::query()
            ->with('user:id,public_id,name,tier')
            ->where('status', $status)
            ->orderBy('id')
            ->limit(100)
            ->get();

        return view('admin.withdraws', [
            'requests' => $requests,
            'status' => $status,
        ]);
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

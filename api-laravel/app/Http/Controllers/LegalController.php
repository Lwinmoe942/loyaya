<?php

namespace App\Http\Controllers;

use App\Models\User;
use Illuminate\Http\RedirectResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\View\View;

class LegalController extends Controller
{
    public function privacy(): View
    {
        return view('legal.privacy');
    }

    public function accountDeletionForm(): View
    {
        return view('legal.account-deletion');
    }

    public function accountDeletionSubmit(Request $request): RedirectResponse
    {
        $data = $request->validate([
            'email' => ['required', 'email'],
            'password' => ['required', 'string'],
        ]);

        $email = strtolower(trim($data['email']));
        $user = User::query()->whereRaw('LOWER(email) = ?', [$email])->first();

        if (! $user || ! Hash::check($data['password'], $user->password)) {
            return back()
                ->withInput($request->only('email'))
                ->withErrors(['email' => 'Invalid email or password.']);
        }

        User::query()
            ->where('referred_by_user_id', $user->id)
            ->update(['referred_by_user_id' => null]);

        $user->delete();

        return redirect()
            ->route('account-deletion')
            ->with('status', 'Your Lotaya Shwe Oh account and associated data have been deleted.');
    }
}

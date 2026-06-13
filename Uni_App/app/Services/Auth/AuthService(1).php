<?php

namespace App\Services\Auth;

use App\Models\User;
use Exception;
use Illuminate\Support\Facades\Hash;

class AuthService
{
    /**
     * Authenticate a user and return a token.
     */
    public function login(array $credentials): array
    {
        $user = User::where('email', $credentials['email'])
            ->orWhere('username', $credentials['email'])
            ->first();

        if (!$user || !Hash::check($credentials['password'], $user->password)) {
            throw new Exception('Invalid credentials provided.');
        }

        $token = $user->createToken('auth_token')->plainTextToken;

        return [
            'user' => $user,
            'token' => $token,
            'token_type' => 'Bearer'
        ];
    }

    /**
     * Revoke tokens for a user.
     */
    public function logout(User $user): void
    {
        $user->tokens()->delete();
    }

    /**
     * Change user password.
     */
    public function changePassword(User $user, array $data): void
    {
        if (!Hash::check($data['current_password'], $user->password)) {
            throw \Illuminate\Validation\ValidationException::withMessages([
                'current_password' => ['The provided password does not match your current password.'],
            ]);
        }

        $user->update([
            'password' => Hash::make($data['new_password']),
        ]);
    }

    /**
     * Send password reset link (Dev Mode: Return token directly).
     * Development mode only – remove in production.
     */
    public function forgotPassword(string $email): array
    {
        $user = User::where('email', $email)->first();

        if (!$user) {
            throw new Exception('User not found.');
        }

        $token = \Illuminate\Support\Facades\Password::createToken($user);

        return [
            'message' => 'Reset token generated (Dev Mode)',
            'token' => $token
        ];
    }

    /**
     * Reset user password.
     */
    public function resetPassword(array $data): string
    {
        return \Illuminate\Support\Facades\Password::reset(
            $data,
            function ($user, $password) {
                $user->password = Hash::make($password);
                $user->save();
            }
        );
    }
}

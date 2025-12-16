<?php

namespace App\Http\Controllers\API;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Str;
use Carbon\Carbon;

/**
 * @OA\Tag(
 *     name="Password Reset",
 *     description="API Endpoints for Password Reset"
 * )
 */
class PasswordResetController extends ApiController
{
    /**
     * Request password reset (forgot password)
     * 
     * @OA\Post(
     *      path="/api/v1/forgot-password",
     *      operationId="forgotPassword",
     *      tags={"Password Reset"},
     *      summary="Request password reset",
     *      description="Send password reset link to user's email",
     *      @OA\RequestBody(
     *          required=true,
     *          @OA\JsonContent(
     *              required={"email"},
     *              @OA\Property(property="email", type="string", format="email", example="user@example.com")
     *          )
     *      ),
     *      @OA\Response(
     *          response=200,
     *          description="Password reset link sent",
     *       ),
     *      @OA\Response(
     *          response=404,
     *          description="User not found"
     *      ),
     *      @OA\Response(
     *          response=422,
     *          description="Validation error"
     *      ),
     *      @OA\Response(
     *          response=429,
     *          description="Too many requests"
     *      )
     * )
     * 
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function forgotPassword(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
        ]);

        $user = User::where('email', $request->email)->first();

        if (!$user) {
            // For security, don't reveal if email exists or not
            return $this->sendResponse(null, 'If the email exists, a password reset link will be sent.');
        }

        // Check if a recent token exists (rate limiting)
        $recentToken = DB::table('password_reset_tokens')
            ->where('email', $request->email)
            ->where('created_at', '>', Carbon::now()->subMinutes(2))
            ->first();

        if ($recentToken) {
            return $this->sendError('Please wait before requesting another reset link.', [], 429);
        }

        // Generate token
        $token = Str::random(64);

        // Delete any existing tokens for this email
        DB::table('password_reset_tokens')->where('email', $request->email)->delete();

        // Store new token
        DB::table('password_reset_tokens')->insert([
            'email' => $request->email,
            'token' => Hash::make($token),
            'created_at' => Carbon::now(),
        ]);

        // Send email with reset link
        try {
            $this->sendResetEmail($user, $token);
        } catch (\Exception $e) {
            // Log the error but don't reveal to user
            \Log::error('Password reset email failed: ' . $e->getMessage());
        }

        return $this->sendResponse(null, 'If the email exists, a password reset link will be sent.');
    }

    /**
     * Reset password with token
     * 
     * @OA\Post(
     *      path="/api/v1/reset-password",
     *      operationId="resetPassword",
     *      tags={"Password Reset"},
     *      summary="Reset password",
     *      description="Reset password using token received via email",
     *      @OA\RequestBody(
     *          required=true,
     *          @OA\JsonContent(
     *              required={"email", "token", "password", "password_confirmation"},
     *              @OA\Property(property="email", type="string", format="email", example="user@example.com"),
     *              @OA\Property(property="token", type="string", example="abc123..."),
     *              @OA\Property(property="password", type="string", format="password", example="newpassword123"),
     *              @OA\Property(property="password_confirmation", type="string", format="password", example="newpassword123")
     *          )
     *      ),
     *      @OA\Response(
     *          response=200,
     *          description="Password reset successful",
     *       ),
     *      @OA\Response(
     *          response=400,
     *          description="Invalid or expired token"
     *      ),
     *      @OA\Response(
     *          response=422,
     *          description="Validation error"
     *      )
     * )
     * 
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function resetPassword(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'token' => 'required|string',
            'password' => 'required|string|min:8|confirmed',
        ]);

        // Find the token record
        $tokenRecord = DB::table('password_reset_tokens')
            ->where('email', $request->email)
            ->first();

        if (!$tokenRecord) {
            return $this->sendError('Invalid or expired reset token.', [], 400);
        }

        // Check if token is expired (60 minutes)
        if (Carbon::parse($tokenRecord->created_at)->addMinutes(60)->isPast()) {
            // Delete expired token
            DB::table('password_reset_tokens')->where('email', $request->email)->delete();
            return $this->sendError('Reset token has expired. Please request a new one.', [], 400);
        }

        // Verify token
        if (!Hash::check($request->token, $tokenRecord->token)) {
            return $this->sendError('Invalid or expired reset token.', [], 400);
        }

        // Find user and update password
        $user = User::where('email', $request->email)->first();

        if (!$user) {
            return $this->sendError('User not found.', [], 404);
        }

        // Update password
        $user->password = Hash::make($request->password);
        $user->save();

        // Delete the token
        DB::table('password_reset_tokens')->where('email', $request->email)->delete();

        // Revoke all existing tokens for security
        $user->tokens()->delete();

        return $this->sendResponse(null, 'Password has been reset successfully. Please login with your new password.');
    }

    /**
     * Verify reset token (optional - for mobile apps to validate before showing reset form)
     * 
     * @OA\Post(
     *      path="/api/v1/verify-reset-token",
     *      operationId="verifyResetToken",
     *      tags={"Password Reset"},
     *      summary="Verify reset token",
     *      description="Verify if a password reset token is valid",
     *      @OA\RequestBody(
     *          required=true,
     *          @OA\JsonContent(
     *              required={"email", "token"},
     *              @OA\Property(property="email", type="string", format="email", example="user@example.com"),
     *              @OA\Property(property="token", type="string", example="abc123...")
     *          )
     *      ),
     *      @OA\Response(
     *          response=200,
     *          description="Token is valid",
     *       ),
     *      @OA\Response(
     *          response=400,
     *          description="Invalid or expired token"
     *      ),
     *      @OA\Response(
     *          response=422,
     *          description="Validation error"
     *      )
     * )
     * 
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function verifyResetToken(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'token' => 'required|string',
        ]);

        // Find the token record
        $tokenRecord = DB::table('password_reset_tokens')
            ->where('email', $request->email)
            ->first();

        if (!$tokenRecord) {
            return $this->sendError('Invalid or expired reset token.', [], 400);
        }

        // Check if token is expired (60 minutes)
        if (Carbon::parse($tokenRecord->created_at)->addMinutes(60)->isPast()) {
            return $this->sendError('Reset token has expired. Please request a new one.', [], 400);
        }

        // Verify token
        if (!Hash::check($request->token, $tokenRecord->token)) {
            return $this->sendError('Invalid or expired reset token.', [], 400);
        }

        return $this->sendResponse([
            'valid' => true,
            'expires_at' => Carbon::parse($tokenRecord->created_at)->addMinutes(60)->toIso8601String(),
        ], 'Token is valid.');
    }

    /**
     * Send reset email to user
     * 
     * @param User $user
     * @param string $token
     * @return void
     */
    private function sendResetEmail(User $user, string $token)
    {
        $resetUrl = config('app.frontend_url', config('app.url')) . '/reset-password?token=' . $token . '&email=' . urlencode($user->email);
        
        // Use Laravel's built-in mail or a custom mailable
        Mail::send('emails.password-reset', [
            'user' => $user,
            'resetUrl' => $resetUrl,
            'token' => $token,
            'expiresIn' => '60 minutes',
        ], function ($message) use ($user) {
            $message->to($user->email, $user->name)
                    ->subject('Password Reset Request - ' . config('app.name'));
        });
    }
}

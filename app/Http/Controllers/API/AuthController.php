<?php

namespace App\Http\Controllers\API;

use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Log;
use Illuminate\Validation\Rule;
use App\Mail\WelcomeMail;

/**
 * @OA\Tag(
 *     name="Authentication",
 *     description="API Endpoints for Authentication"
 * )
 */
class AuthController extends ApiController
{
    /**
     * User login
     * 
     * @OA\Post(
     *      path="/api/v1/login",
     *      operationId="loginUser",
     *      tags={"Authentication"},
     *      summary="User login",
     *      description="Authenticate a user and return an access token",
     *      @OA\RequestBody(
     *          required=true,
     *          @OA\JsonContent(
     *              required={"email","password"},
     *              @OA\Property(property="email", type="string", format="email", example="johndoe@example.com"),
     *              @OA\Property(property="password", type="string", format="password", example="Password123"),
     *              @OA\Property(property="device_token", type="string", example="fcm_device_token_here", description="FCM device token for push notifications (optional)"),
     *          ),
     *      ),
     *      @OA\Response(
     *          response=200,
     *          description="Successful login",
     *       ),
     *      @OA\Response(
     *          response=401,
     *          description="Unauthorized"
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
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required',
            'device_token' => 'nullable|string',
        ]);

        $credentials = $request->only('email', 'password');

        if (!Auth::attempt($credentials)) {
            return $this->sendError('Unauthorized', ['error' => 'Invalid credentials'], 401);
        }

        $user = Auth::user();
        
        // Update device token if provided
        if ($request->filled('device_token')) {
            $user->device_token = $request->device_token;
            $user->save();
        }
        
        $token = $user->createToken('API Token')->plainTextToken;

        $success['token'] = $token;
        $success['user'] = $user;

        return $this->sendResponse($success, 'User login successful');
    }

    /**
     * User registration
     * 
     * @OA\Post(
     *      path="/api/v1/register",
     *      operationId="registerUser",
     *      tags={"Authentication"},
     *      summary="User registration",
     *      description="Register a new user",
     *      @OA\RequestBody(
     *          required=true,
     *          @OA\JsonContent(
     *              required={"name","email","password","password_confirmation"},
     *              @OA\Property(property="name", type="string", format="name", example="John Doe"),
     *              @OA\Property(property="email", type="string", format="email", example="johndoe@example.com"),
     *              @OA\Property(property="password", type="string", format="password", example="Password123"),
     *              @OA\Property(property="password_confirmation", type="string", format="password", example="Password123"),
     *              @OA\Property(property="device_token", type="string", example="fcm_device_token_here", description="FCM device token for push notifications (optional)"),
     *          ),
     *      ),
     *      @OA\Response(
     *          response=201,
     *          description="Successful registration",
     *       ),
     *      @OA\Response(
     *          response=422,
     *          description="Validation error"
     *      )
     * )
     * 
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function register(Request $request)
    {
        $request->validate([
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:8|confirmed',
            'device_token' => 'nullable|string',
        ]);

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'user_role' => 'user',
            'is_approved' => false,
            'device_token' => $request->device_token,
        ]);

        // Send welcome email
        try {
            Mail::to($user->email)->send(new WelcomeMail($user, true));
            Log::info('Welcome email sent successfully to: ' . $user->email);
        } catch (\Exception $e) {
            Log::error('Failed to send welcome email: ' . $e->getMessage());
            // Continue with registration even if email fails
        }

        $token = $user->createToken('API Token')->plainTextToken;

        $success['token'] = $token;
        $success['user'] = $user;

        return $this->sendResponse($success, 'User registered successfully', 201);
    }

    /**
     * User logout
     * 
     * @OA\Post(
     *      path="/api/v1/logout",
     *      operationId="logoutUser",
     *      tags={"Authentication"},
     *      summary="User logout",
     *      description="Logout the authenticated user and clear device token",
     *      security={{"sanctum": {}}},
     *      @OA\RequestBody(
     *          required=false,
     *          @OA\JsonContent(
     *              @OA\Property(property="clear_device_token", type="boolean", example=true, description="Clear device token on logout (default: true)"),
     *          ),
     *      ),
     *      @OA\Response(
     *          response=200,
     *          description="Successful logout",
     *       ),
     *      @OA\Response(
     *          response=401,
     *          description="Unauthenticated"
     *      )
     * )
     * 
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function logout(Request $request)
    {
        $user = $request->user();
        
        // Clear device token by default (unless explicitly set to false)
        $clearDeviceToken = $request->input('clear_device_token', true);
        if ($clearDeviceToken) {
            $user->device_token = null;
            $user->save();
        }
        
        // Delete current access token
        $user->currentAccessToken()->delete();

        return $this->sendResponse(null, 'User logged out successfully');
    }

    /**
     * Get authenticated user
     * 
     * @OA\Get(
     *      path="/api/v1/user",
     *      operationId="getAuthenticatedUser",
     *      tags={"Authentication"},
     *      summary="Get authenticated user",
     *      description="Get details of the authenticated user",
     *      security={{"sanctum": {}}},
     *      @OA\Response(
     *          response=200,
     *          description="Successful operation",
     *       ),
     *      @OA\Response(
     *          response=401,
     *          description="Unauthenticated"
     *      )
     * )
     * 
     * @param Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function user(Request $request)
    {
        return $this->sendResponse($request->user(), 'User retrieved successfully');
    }
}
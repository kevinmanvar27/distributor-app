<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\User;
use App\Models\Role;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\Rule;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Auth;

class UserController extends Controller
{
    /**
     * Display a listing of all users.
     *
     * @return \Illuminate\View\View
     */
    public function index()
    {
        // Show only regular users
        $users = User::where('user_role', 'user')
                    ->orderBy('created_at', 'desc')
                    ->paginate(10);
        return view('admin.users.index', compact('users'));
    }
    
    /**
     * Display a listing of staff members (admin, super_admin, editor).
     *
     * @return \Illuminate\View\View
     */
    public function staff()
    {
        // Fetch all users except those with the 'user' role
        $staff = User::where('user_role', '!=', 'user')
                    ->orderBy('user_role')
                    ->orderBy('created_at', 'desc')
                    ->paginate(10);

        return view('admin.users.staff', compact('staff'));
    }

    /**
     * Show the form for creating a new user.
     *
     * @return \Illuminate\View\View
     */
    public function create()
    {
        $role = request('role', 'user');
        // Ensure the role is valid
        $validRoles = ['super_admin', 'admin', 'editor', 'user'];
        if (!in_array($role, $validRoles)) {
            $role = 'user';
        }
        $roles = Role::all();
        return view('admin.users.create', compact('role', 'roles'));
    }

    /**
     * Store a newly created user in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\RedirectResponse
     */
    public function store(Request $request)
    {
        // Get all role names dynamically for validation
        $roleNames = Role::pluck('name')->toArray();
        
        $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'email', 'max:255', 'unique:users'],
            'password' => ['required', 'string', 'min:8', 'confirmed'],
            'user_role' => ['required', 'string', Rule::in($roleNames)],
            'date_of_birth' => ['nullable', 'date', 'before_or_equal:today'],
        ], [
            'user_role.required' => 'Please select a user role.',
            'user_role.in' => 'Please select a valid user role.',
        ]);

        // Create user without immediately setting the user_role to avoid sync issues
        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => Hash::make($request->password),
            'date_of_birth' => $request->date_of_birth,
        ]);
        
        // Now set the user role which will properly sync with the roles relationship
        $user->user_role = $request->user_role;
        $user->save();

        // Handle avatar upload if provided
        $this->handleAvatarUpload($request, $user);

        // Redirect to appropriate page based on user role
        if ($user->hasAnyRole(['user'])) {
            return redirect()->route('admin.users.index')->with('success', 'User created successfully.');
        } else {
            return redirect()->route('admin.users.staff')->with('success', 'Staff member created successfully.');
        }
    }

    /**
     * Display the specified user.
     *
     * @param  \App\Models\User  $user
     * @return \Illuminate\View\View
     */
    public function show(User $user)
    {
        // Check if the request is an AJAX request for modal content
        if (request()->ajax()) {
            // Return only the partial view for modals
            return view('admin.users._user_details', compact('user'));
        }
        
        return view('admin.users.show', compact('user'));
    }

    /**
     * Show the form for editing the specified user.
     *
     * @param  \App\Models\User  $user
     * @return \Illuminate\View\View
     */
    public function edit(User $user)
    {
        $roles = Role::all();
        return view('admin.users.edit', compact('user', 'roles'));
    }

    /**
     * Update the specified user in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Models\User  $user
     * @return \Illuminate\Http\RedirectResponse
     */
    public function update(Request $request, User $user)
    {
        // Get all role names dynamically for validation
        $roleNames = Role::pluck('name')->toArray();
        
        $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'email' => ['required', 'string', 'email', 'max:255', Rule::unique('users')->ignore($user->id)],
            'user_role' => ['required', 'string', Rule::in($roleNames)],
            'date_of_birth' => ['nullable', 'date', 'before_or_equal:today'],
        ], [
            'user_role.required' => 'Please select a user role.',
            'user_role.in' => 'Please select a valid user role.',
        ]);

        $user->name = $request->name;
        $user->email = $request->email;
        $user->user_role = $request->user_role;
        $user->date_of_birth = $request->date_of_birth;

        // Update password only if provided
        if ($request->filled('password')) {
            $request->validate([
                'password' => ['string', 'min:8', 'confirmed'],
            ]);
            $user->password = Hash::make($request->password);
        }

        $user->save();

        // Handle avatar upload if provided
        $this->handleAvatarUpload($request, $user);

        // Redirect to appropriate page based on user role
        if ($user->hasAnyRole(['user'])) {
            return redirect()->route('admin.users.index')->with('success', 'User updated successfully.');
        } else {
            return redirect()->route('admin.users.staff')->with('success', 'Staff member updated successfully.');
        }
    }

    /**
     * Update the user's avatar.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Models\User  $user
     * @return \Illuminate\Http\RedirectResponse
     */
    public function updateAvatar(Request $request, User $user)
    {
        // Validate only the avatar field - avatar is required when directly updating avatar
        $request->validate([
            'avatar' => ['required', 'image', 'mimes:jpeg,png,jpg,gif', 'max:2048'], // 2MB max
        ], [
            'avatar.required' => 'Please select an image to upload.',
            'avatar.image' => 'The file must be an image.',
            'avatar.max' => 'The image may not be greater than 2MB.',
        ]);

        // Delete old avatar if exists
        if ($user->avatar) {
            Storage::disk('public')->delete('avatars/' . $user->avatar);
        }
        
        // Store new avatar
        $avatarName = time() . '_' . $user->id . '.' . $request->file('avatar')->extension();
        $request->file('avatar')->storeAs('avatars', $avatarName, 'public');
        $user->avatar = $avatarName;
        $user->save();

        return redirect()->back()->with('success', 'Profile picture updated successfully.');
    }
    
    /**
     * Handle avatar upload from user update form.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Models\User  $user
     * @return void
     */
    protected function handleAvatarUpload(Request $request, User $user)
    {
        // Only process if avatar file is provided
        if (!$request->hasFile('avatar')) {
            return;
        }
        
        // Validate only the avatar field - avatar is optional when updating user profile
        $request->validate([
            'avatar' => ['image', 'mimes:jpeg,png,jpg,gif', 'max:2048'], // 2MB max
        ], [
            'avatar.image' => 'The file must be an image.',
            'avatar.max' => 'The image may not be greater than 2MB.',
        ]);

        // Delete old avatar if exists
        if ($user->avatar) {
            Storage::disk('public')->delete('avatars/' . $user->avatar);
        }
        
        // Store new avatar
        $avatarName = time() . '_' . $user->id . '.' . $request->file('avatar')->extension();
        $request->file('avatar')->storeAs('avatars', $avatarName, 'public');
        $user->avatar = $avatarName;
        $user->save();
    }

    /**
     * Remove the specified user's avatar.
     *
     * @param  \App\Models\User  $user
     * @return \Illuminate\Http\RedirectResponse
     */
    public function removeAvatar(User $user)
    {
        // Delete avatar file if exists
        if ($user->avatar) {
            Storage::disk('public')->delete('avatars/' . $user->avatar);
            $user->avatar = null;
            $user->save();
        }
        
        return redirect()->back()->with('success', 'Profile picture removed successfully.');
    }

    /**
     * Remove the specified user from storage.
     *
     * @param  \App\Models\User  $user
     * @return \Illuminate\Http\RedirectResponse
     */
    public function destroy(User $user)
    {
        // Prevent deleting the current logged in user
        if (Auth::user()->id == $user->id) {
            return redirect()->route('admin.users.index')->with('error', 'You cannot delete your own account.');
        }

        // Delete avatar if exists
        if ($user->avatar) {
            Storage::disk('public')->delete('avatars/' . $user->avatar);
        }

        $user->delete();

        // Redirect to appropriate page based on user role
        if ($user->hasAnyRole(['super_admin', 'admin', 'editor'])) {
            return redirect()->route('admin.users.staff')->with('success', 'Staff member deleted successfully.');
        } else {
            return redirect()->route('admin.users.index')->with('success', 'User deleted successfully.');
        }
    }
}
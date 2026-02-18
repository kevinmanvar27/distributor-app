<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\UserGroup;
use App\Models\User;
use App\Models\UserGroupMember;
use Illuminate\Validation\Rule;

class UserGroupController extends Controller
{
    /**
     * Display a listing of user groups.
     *
     * @return \Illuminate\View\View
     */
    public function index()
    {
        $userGroups = UserGroup::orderBy('created_at', 'desc')->paginate(10);
        return view('admin.user-groups.index', compact('userGroups'));
    }

    /**
     * Show the form for creating a new user group.
     *
     * @return \Illuminate\View\View
     */
    public function create()
    {
        $users = User::where('user_role', 'user')->with('userGroups')->orderBy('name')->get();
        return view('admin.user-groups.create', compact('users'));
    }

    /**
     * Store a newly created user group in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\RedirectResponse
     */
    public function store(Request $request)
    {
        $request->validate([
            'name' => ['required', 'string', 'max:255', 'unique:user_groups'],
            'description' => ['nullable', 'string'],
            'discount_percentage' => ['required', 'numeric', 'between:0,100'],
            'users' => ['nullable', 'array'],
            'users.*' => ['exists:users,id'],
            'force_add' => ['nullable', 'boolean'], // Allow force adding users
        ]);

        $userGroup = UserGroup::create([
            'name' => $request->name,
            'description' => $request->description,
            'discount_percentage' => $request->discount_percentage,
        ]);

        // Attach selected users to the group
        if ($request->has('users')) {
            // If force_add is true, remove users from their existing groups
            if ($request->force_add) {
                foreach ($request->users as $userId) {
                    // Remove user from all other groups
                    UserGroupMember::where('user_id', $userId)->delete();
                }
            }
            
            $userGroup->users()->attach($request->users);
        }

        return redirect()->route('admin.user-groups.index')->with('success', 'User group created successfully.');
    }

    /**
     * Display the specified user group.
     *
     * @param  \App\Models\UserGroup  $userGroup
     * @return \Illuminate\View\View
     */
    public function show(UserGroup $userGroup)
    {
        $userGroup->load('users');
        
        // Check if the request is an AJAX request for modal content
        if (request()->ajax()) {
            // Return only the partial view for modals
            return view('admin.user-groups._group_details', compact('userGroup'));
        }
        
        return view('admin.user-groups.show', compact('userGroup'));
    }

    /**
     * Show the form for editing the specified user group.
     *
     * @param  \App\Models\UserGroup  $userGroup
     * @return \Illuminate\View\View
     */
    public function edit(UserGroup $userGroup)
    {
        $userGroup->load('users');
        $users = User::where('user_role', 'user')->with('userGroups')->orderBy('name')->get();
        $selectedUsers = $userGroup->users->pluck('id')->toArray();
        
        // Check if the request is an AJAX request for modal content
        if (request()->ajax()) {
            // Return only the partial view for modals
            return view('admin.user-groups._group_edit', compact('userGroup', 'users', 'selectedUsers'));
        }
        
        return view('admin.user-groups.edit', compact('userGroup', 'users', 'selectedUsers'));
    }

    /**
     * Update the specified user group in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Models\UserGroup  $userGroup
     * @return \Illuminate\Http\RedirectResponse
     */
    public function update(Request $request, UserGroup $userGroup)
    {
        $request->validate([
            'name' => ['required', 'string', 'max:255', Rule::unique('user_groups')->ignore($userGroup->id)],
            'description' => ['nullable', 'string'],
            'discount_percentage' => ['required', 'numeric', 'between:0,100'],
            'users' => ['nullable', 'array'],
            'users.*' => ['exists:users,id'],
            'force_add' => ['nullable', 'boolean'], // Allow force adding users
        ]);

        $userGroup->update([
            'name' => $request->name,
            'description' => $request->description,
            'discount_percentage' => $request->discount_percentage,
        ]);

        // Sync selected users with the group
        if ($request->has('users')) {
            // If force_add is true, remove users from their existing groups (except current group)
            if ($request->force_add) {
                foreach ($request->users as $userId) {
                    // Remove user from all other groups except the current one
                    UserGroupMember::where('user_id', $userId)
                        ->where('user_group_id', '!=', $userGroup->id)
                        ->delete();
                }
            }
            
            $userGroup->users()->sync($request->users);
        } else {
            $userGroup->users()->sync([]);
        }

        // Check if the request is an AJAX request
        if (request()->ajax()) {
            return response()->json(['success' => true, 'message' => 'User group updated successfully.']);
        }

        return redirect()->route('admin.user-groups.index')->with('success', 'User group updated successfully.');
    }

    /**
     * Remove the specified user group from storage.
     *
     * @param  \App\Models\UserGroup  $userGroup
     * @return \Illuminate\Http\RedirectResponse
     */
    public function destroy(UserGroup $userGroup)
    {
        $userGroup->delete();

        // Check if the request is an AJAX request
        if (request()->ajax()) {
            return response()->json(['success' => true, 'message' => 'User group deleted successfully.']);
        }

        return redirect()->route('admin.user-groups.index')->with('success', 'User group deleted successfully.');
    }

    /**
     * Check if users are already in other groups.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function checkUserConflicts(Request $request)
    {
        $request->validate([
            'user_ids' => ['required', 'array'],
            'user_ids.*' => ['exists:users,id'],
            'current_group_id' => ['nullable', 'exists:user_groups,id'],
        ]);

        $conflicts = [];
        $currentGroupId = $request->current_group_id;

        foreach ($request->user_ids as $userId) {
            // Find if user is in any group (excluding the current group if editing)
            $existingMembership = UserGroupMember::with('userGroup')
                ->where('user_id', $userId)
                ->when($currentGroupId, function ($query) use ($currentGroupId) {
                    return $query->where('user_group_id', '!=', $currentGroupId);
                })
                ->first();

            if ($existingMembership) {
                $user = User::find($userId);
                $conflicts[] = [
                    'user_id' => $userId,
                    'user_name' => $user->name,
                    'existing_group_id' => $existingMembership->user_group_id,
                    'existing_group_name' => $existingMembership->userGroup->name,
                ];
            }
        }

        return response()->json([
            'has_conflicts' => count($conflicts) > 0,
            'conflicts' => $conflicts,
        ]);
    }
}
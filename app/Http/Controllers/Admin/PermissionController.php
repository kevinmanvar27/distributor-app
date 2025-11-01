<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\User;
use App\Models\Permission;

class PermissionController extends Controller
{
    /**
     * Show the form for assigning permissions to a user.
     *
     * @param  \App\Models\User  $user
     * @return \Illuminate\View\View
     */
    public function edit(User $user)
    {
        // Only super admins can assign permissions
        if (!Auth::user()->isSuperAdmin()) {
            return redirect()->back()->with('error', 'Only super admins can assign permissions.');
        }
        
        $permissions = Permission::all();
        $userPermissions = $user->permissions->pluck('id')->toArray();
        
        return view('admin.users.permissions', compact('user', 'permissions', 'userPermissions'));
    }

    /**
     * Update the specified user's permissions in storage.
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Models\User  $user
     * @return \Illuminate\Http\RedirectResponse
     */
    public function update(Request $request, User $user)
    {
        // Only super admins can assign permissions
        if (!Auth::user()->isSuperAdmin()) {
            return redirect()->back()->with('error', 'Only super admins can assign permissions.');
        }
        
        $request->validate([
            'permissions' => 'array',
            'permissions.*' => 'exists:permissions,id',
        ]);
        
        // Sync the user's permissions
        $user->permissions()->sync($request->input('permissions', []));
        
        return redirect()->back()->with('success', 'Permissions updated successfully.');
    }
}
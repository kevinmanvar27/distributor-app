<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\Role;
use App\Models\Permission;
use Illuminate\Support\Facades\DB;

class SettingsPermissionSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        // Create settings-related permissions
        $permissions = [
            [
                'name' => 'view_settings',
                'display_name' => 'View Settings',
                'description' => 'View application settings'
            ],
            [
                'name' => 'update_settings',
                'display_name' => 'Update Settings',
                'description' => 'Modify application settings'
            ],
            [
                'name' => 'reset_settings',
                'display_name' => 'Reset Settings',
                'description' => 'Reset settings to default values'
            ],
        ];

        // Create or update permissions
        foreach ($permissions as $permissionData) {
            Permission::updateOrCreate(
                ['name' => $permissionData['name']],
                $permissionData
            );
        }

        // Assign permissions to roles
        $superAdminRole = Role::where('name', 'super_admin')->first();
        $adminRole = Role::where('name', 'admin')->first();
        $editorRole = Role::where('name', 'editor')->first();

        $allSettingsPermissions = Permission::whereIn('name', [
            'view_settings',
            'update_settings',
            'reset_settings',
        ])->get();

        $viewOnlyPermissions = Permission::whereIn('name', [
            'view_settings',
        ])->get();

        // Super admin gets all permissions (they already have them, but let's ensure)
        if ($superAdminRole) {
            $existingPermissions = $superAdminRole->permissions()->pluck('permissions.id')->toArray();
            $newPermissions = $allSettingsPermissions->pluck('id')->toArray();
            $superAdminRole->permissions()->syncWithoutDetaching(array_unique(array_merge($existingPermissions, $newPermissions)));
        }

        // Admin gets all settings permissions
        if ($adminRole) {
            $existingPermissions = $adminRole->permissions()->pluck('permissions.id')->toArray();
            $newPermissions = $allSettingsPermissions->pluck('id')->toArray();
            $adminRole->permissions()->syncWithoutDetaching(array_unique(array_merge($existingPermissions, $newPermissions)));
        }

        // Editor gets only view permission
        if ($editorRole) {
            $existingPermissions = $editorRole->permissions()->pluck('permissions.id')->toArray();
            $newPermissions = $viewOnlyPermissions->pluck('id')->toArray();
            $editorRole->permissions()->syncWithoutDetaching(array_unique(array_merge($existingPermissions, $newPermissions)));
        }

        $this->command->info('Settings permissions created and assigned successfully!');
    }
}

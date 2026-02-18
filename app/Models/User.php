<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;
use Illuminate\Database\Eloquent\SoftDeletes;

class User extends Authenticatable
{
    /** @use HasFactory<\Database\Factories\UserFactory> */
    use HasFactory, Notifiable, HasApiTokens, SoftDeletes;

    /**
     * The attributes that are mass assignable.
     *
     * @var list<string>
     */
    protected $fillable = [
        'name',
        'email',
        'device_token',
        'password',
        'user_role',
        'date_of_birth',
        'avatar',
        'address',
        'mobile_number',
        'is_approved',
        'status',
        'discount_percentage',
    ];

    /**
     * The attributes that should be hidden for serialization.
     *
     * @var list<string>
     */
    protected $hidden = [
        'password',
        'remember_token',
    ];

    /**
     * Get the attributes that should be cast.
     *
     * @return array<string, string>
     */
    protected function casts(): array
    {
        return [
            'email_verified_at' => 'datetime',
            'password' => 'hashed',
            'date_of_birth' => 'date',
            'discount_percentage' => 'decimal:2',
            'deleted_at' => 'datetime',
        ];
    }

    /**
     * Check if the user is a super admin.
     *
     * @return bool
     */
    public function isSuperAdmin()
    {
        return $this->user_role === 'super_admin';
    }

    /**
     * Check if the user is an admin.
     *
     * @return bool
     */
    public function isAdmin()
    {
        return $this->user_role === 'admin';
    }

    /**
     * Check if the user has a specific role.
     *
     * @param string $role
     * @return bool
     */
    public function hasRole($role)
    {
        return $this->user_role === $role;
    }

    /**
     * Check if the user has any of the specified roles.
     *
     * @param array $roles
     * @return bool
     */
    public function hasAnyRole($roles)
    {
        return in_array($this->user_role, $roles);
    }

    /**
     * Check if the user has a specific permission.
     *
     * @param string $permission
     * @return bool
     */
    public function hasPermission($permission)
    {
        // Super admins have all permissions
        if ($this->isSuperAdmin()) {
            return true;
        }

        // Check if user has the permission through their roles
        foreach ($this->roles as $role) {
            if ($role->permissions()->where('name', $permission)->exists()) {
                return true;
            }
        }

        // Also check direct user permissions
        if ($this->permissions()->where('name', $permission)->exists()) {
            return true;
        }

        return false;
    }

    /**
     * Check if the user has any of the specified permissions.
     *
     * @param array $permissions
     * @return bool
     */
    public function hasAnyPermission($permissions)
    {
        // Super admins have all permissions
        if ($this->isSuperAdmin()) {
            return true;
        }

        // Check if user has any of the permissions through their role
        $userRole = $this->user_role;
        $role = \App\Models\Role::where('name', $userRole)->first();
        
        if ($role) {
            return $role->permissions()->whereIn('name', $permissions)->exists();
        }

        return false;
    }

    /**
     * Get the URL of the user's avatar.
     *
     * @return string
     */
    public function getAvatarUrlAttribute()
    {
        if ($this->avatar) {
            // Check if the file exists in storage
            if (\Illuminate\Support\Facades\Storage::disk('public')->exists('avatars/' . $this->avatar)) {
                return asset('storage/avatars/' . $this->avatar);
            }
        }
        
        // Return a default avatar if none is set
        return 'https://ui-avatars.com/api/?name=' . urlencode($this->name ?? 'User') . '&background=0D8ABC&color=fff';
    }

    /**
     * Scope a query to only include staff members (super_admin, admin, editor).
     *
     * @param \Illuminate\Database\Eloquent\Builder $query
     * @return \Illuminate\Database\Eloquent\Builder
     */
    public function scopeStaff($query)
    {
        return $query->whereIn('user_role', ['super_admin', 'admin', 'editor']);
    }

    /**
     * Scope a query to exclude super admins.
     *
     * @param \Illuminate\Database\Eloquent\Builder $query
     * @return \Illuminate\Database\Eloquent\Builder
     */
    public function scopeNonSuperAdmin($query)
    {
        return $query->where('user_role', '!=', 'super_admin');
    }

    /**
     * Get the roles assigned to this user.
     */
    public function roles()
    {
        return $this->belongsToMany(Role::class, 'user_role');
    }
    
    /**
     * Get the permissions directly assigned to this user.
     */
    public function permissions()
    {
        return $this->belongsToMany(\App\Models\Permission::class, 'user_permissions');
    }
    
    /**
     * Get the user groups that this user belongs to.
     */
    public function userGroups()
    {
        return $this->belongsToMany(UserGroup::class, 'user_group_members');
    }
    
    /**
     * Check if the user is approved.
     *
     * @return bool
     */
    public function isApproved()
    {
        return $this->is_approved;
    }
    
    /**
     * Get the status badge HTML.
     *
     * @return string
     */
    public function getStatusBadgeAttribute()
    {
        $badges = [
            'pending' => '<span class="badge bg-warning text-dark">Pending</span>',
            'under_review' => '<span class="badge bg-info">Under Review</span>',
            'approved' => '<span class="badge bg-success">Approved</span>',
            'suspended' => '<span class="badge bg-secondary">Suspended</span>',
            'blocked' => '<span class="badge bg-danger">Blocked</span>',
        ];
        
        return $badges[$this->status] ?? '<span class="badge bg-secondary">Unknown</span>';
    }
    
    /**
     * Check if user can access the system.
     *
     * @return bool
     */
    public function canAccess()
    {
        return in_array($this->status, ['approved', 'under_review']);
    }
    
    /**
     * Get available status options.
     *
     * @return array
     */
    public static function getStatusOptions()
    {
        return [
            'pending' => 'Pending',
            'under_review' => 'Under Review',
            'approved' => 'Approved',
            'suspended' => 'Suspended',
            'blocked' => 'Blocked',
        ];
    }
    
    /**
     * Get the shopping cart items for the user.
     *
     * @return HasMany<ShoppingCartItem>
     */
    public function cartItems()
    {
        return $this->hasMany(ShoppingCartItem::class);
    }
    
    /**
     * Get the notifications for the user.
     */
    public function notifications()
    {
        return $this->hasMany(\App\Models\Notification::class)->orderBy('created_at', 'desc');
    }
    
    /**
     * Get unread notifications for the user.
     */
    public function unreadNotifications()
    {
        return $this->hasMany(\App\Models\Notification::class)->where('read', false)->orderBy('created_at', 'desc');
    }
    
    /**
     * Get the wishlist items for the user.
     */
    public function wishlistItems()
    {
        return $this->hasMany(Wishlist::class);
    }
    
    /**
     * Get the proforma invoices for the user.
     */
    public function proformaInvoices()
    {
        return $this->hasMany(ProformaInvoice::class);
    }
    
    /**
     * Get the attendance records for the user.
     */
    public function attendances()
    {
        return $this->hasMany(Attendance::class);
    }
    
    /**
     * Get the salary records for the user.
     */
    public function salaries()
    {
        return $this->hasMany(Salary::class);
    }
    
    /**
     * Get the active salary for the user.
     */
    public function activeSalary()
    {
        return $this->hasOne(Salary::class)->where('is_active', true)->latestOfMany('effective_from');
    }
    
    /**
     * Get the salary payments for the user.
     */
    public function salaryPayments()
    {
        return $this->hasMany(SalaryPayment::class);
    }
}
<!-- Sidebar -->
<nav id="sidebar" class="col-md-3 col-lg-2 d-md-block bg-surface sidebar">
    <!-- Mobile close button -->
    <button type="button" class="sidebar-close" id="sidebar-close" aria-label="Close sidebar">
        <i class="fas fa-times"></i>
    </button>
    <div class="position-sticky pt-2 d-flex flex-column vh-100">
        <!-- Sidebar Header - Compact -->
        <div class="px-3 pb-2 border-bottom border-default sidebar-header">
            <div class="d-flex align-items-center">
                @if(setting('header_logo'))
                    <img src="{{ asset('storage/' . setting('header_logo')) }}" alt="{{ setting('site_title', 'Admin Panel') }}" class="me-2 rounded sidebar-logo" height="40">
                @else
                    <div class="bg-theme rounded-circle d-flex align-items-center justify-content-center me-2 sidebar-logo-icon" style="width: 40px; height: 40px;">
                        <i class="fas fa-cube text-white fs-6"></i>
                    </div>
                    <h1 class="h6 mb-0 fw-bold sidebar-header-text">{{ setting('site_title', 'Admin Panel') }}</h1>
                @endif
            </div>
        </div>
        
        <!-- Sidebar Navigation - Compact -->
        <div class="flex-grow-1 overflow-hidden" style="max-height: calc(100vh - 180px);">
            <div class="h-100 overflow-auto scrollbar-thin">
                <ul class="nav flex-column py-2">
                    <!-- Dashboard -->
                    <li class="nav-item">
                        <a class="nav-link py-2 {{ request()->routeIs('dashboard') ? 'active' : '' }}" href="{{ route('dashboard') }}" data-title="Dashboard">
                            <i class="fas fa-home me-2"></i>
                            <span class="sidebar-text">Dashboard</span>
                        </a>
                    </li>
                    
                    @php 
                        $hasProductPermission = auth()->user()->hasPermission('viewAny_product') || 
                                               auth()->user()->hasPermission('create_product') || 
                                               auth()->user()->hasPermission('update_product') || 
                                               auth()->user()->hasPermission('delete_product');
                        $hasCategoryPermission = auth()->user()->hasPermission('viewAny_category') || 
                                                auth()->user()->hasPermission('create_category') || 
                                                auth()->user()->hasPermission('update_category') || 
                                                auth()->user()->hasPermission('delete_category');
                        $hasUserPermission = auth()->user()->hasPermission('show_user') ||
                                            auth()->user()->hasPermission('add_user') || 
                                            auth()->user()->hasPermission('edit_user') || 
                                            auth()->user()->hasPermission('delete_user');
                        $hasStaffPermission = auth()->user()->hasPermission('show_staff') ||
                                             auth()->user()->hasPermission('add_staff') || 
                                             auth()->user()->hasPermission('edit_staff') || 
                                             auth()->user()->hasPermission('delete_staff');
                        $hasAttendancePermission = auth()->user()->hasPermission('viewAny_attendance') ||
                                                  auth()->user()->hasPermission('create_attendance') || 
                                                  auth()->user()->hasPermission('update_attendance') || 
                                                  auth()->user()->hasPermission('delete_attendance') ||
                                                  auth()->user()->isSuperAdmin();
                        $hasSalaryPermission = auth()->user()->hasPermission('viewAny_salary') ||
                                              auth()->user()->hasPermission('create_salary') || 
                                              auth()->user()->hasPermission('update_salary') || 
                                              auth()->user()->hasPermission('delete_salary') ||
                                              auth()->user()->isSuperAdmin();
                        $hasTaskPermission = auth()->user()->hasPermission('manage_tasks') ||
                                            auth()->user()->hasPermission('view_tasks') || 
                                            auth()->user()->hasPermission('create_tasks') || 
                                            auth()->user()->hasPermission('edit_tasks') ||
                                            auth()->user()->isSuperAdmin();
                        $hasLeadPermission = auth()->user()->hasPermission('viewAny_lead') || 
                                            auth()->user()->hasPermission('view_lead') || 
                                            auth()->user()->hasPermission('create_lead') || 
                                            auth()->user()->hasPermission('update_lead') || 
                                            auth()->user()->hasPermission('delete_lead');
                        $hasPagePermission = auth()->user()->hasPermission('viewAny_page') || 
                                            auth()->user()->hasPermission('create_page') || 
                                            auth()->user()->hasPermission('update_page') || 
                                            auth()->user()->hasPermission('delete_page');
                    @endphp
                    
                    <!-- Products & Inventory -->
                    @if($hasProductPermission || $hasCategoryPermission || auth()->user()->hasPermission('viewAny_coupon'))
                        <li class="nav-item mt-2">
                            <div class="px-3 py-1">
                                <small class="text-muted text-uppercase fw-semibold sidebar-text" style="font-size: 0.7rem; letter-spacing: 0.5px;">Products</small>
                            </div>
                        </li>
                        
                        @if($hasProductPermission)
                            <li class="nav-item">
                                <a class="nav-link py-2 {{ request()->routeIs('admin.products*') && !request()->routeIs('admin.attributes*') ? 'active' : '' }}" href="{{ route('admin.products.index') }}" data-title="Products">
                                    <i class="fas fa-box me-2"></i>
                                    <span class="sidebar-text">Products</span>
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link py-2 {{ request()->routeIs('admin.attributes*') ? 'active' : '' }}" href="{{ route('admin.attributes.index') }}" data-title="Attributes">
                                    <i class="fas fa-sliders-h me-2"></i>
                                    <span class="sidebar-text">Attributes</span>
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link py-2 {{ request()->routeIs('admin.analytics.products*') ? 'active' : '' }}" href="{{ route('admin.analytics.products') }}" data-title="Analytics">
                                    <i class="fas fa-chart-line me-2"></i>
                                    <span class="sidebar-text">Analytics</span>
                                </a>
                            </li>
                        @endif
                        
                        @if($hasCategoryPermission)
                            <li class="nav-item">
                                <a class="nav-link py-2 {{ request()->routeIs('admin.categories*') ? 'active' : '' }}" href="{{ route('admin.categories.index') }}" data-title="Categories">
                                    <i class="fas fa-tags me-2"></i>
                                    <span class="sidebar-text">Categories</span>
                                </a>
                            </li>
                        @endif
                        
                        @if(auth()->user()->hasPermission('viewAny_coupon'))
                            <li class="nav-item">
                                <a class="nav-link py-2 {{ request()->routeIs('admin.coupons*') ? 'active' : '' }}" href="{{ route('admin.coupons.index') }}" data-title="Coupons">
                                    <i class="fas fa-ticket-alt me-2"></i>
                                    <span class="sidebar-text">Coupons</span>
                                </a>
                            </li>
                        @endif
                    @endif
                    
                    <!-- Sales -->
                    @if(auth()->user()->hasPermission('manage_proforma_invoices') || auth()->user()->hasPermission('manage_pending_bills'))
                        <li class="nav-item mt-2">
                            <div class="px-3 py-1">
                                <small class="text-muted text-uppercase fw-semibold sidebar-text" style="font-size: 0.7rem; letter-spacing: 0.5px;">Sales</small>
                            </div>
                        </li>
                        
                        @if(auth()->user()->hasPermission('manage_proforma_invoices'))
                            <li class="nav-item">
                                <a class="nav-link py-2 {{ request()->routeIs('admin.proforma-invoice*') ? 'active' : '' }}" href="{{ route('admin.proforma-invoice.index') }}" data-title="Invoices">
                                    <i class="fas fa-file-invoice me-2"></i>
                                    <span class="sidebar-text">Invoices</span>
                                </a>
                            </li>
                        @endif
                        
                        @if(auth()->user()->hasPermission('manage_pending_bills'))
                            <li class="nav-item">
                                <a class="nav-link py-2 {{ request()->routeIs('admin.pending-bills*') ? 'active' : '' }}" href="{{ route('admin.pending-bills.index') }}" data-title="Pending Bills">
                                    <i class="fas fa-money-bill-wave me-2"></i>
                                    <span class="sidebar-text">Pending Bills</span>
                                </a>
                            </li>
                        @endif
                    @endif
                    
                    <!-- Users -->
                    @if($hasUserPermission || $hasStaffPermission || auth()->user()->hasPermission('manage_roles'))
                        <li class="nav-item mt-2">
                            <div class="px-3 py-1">
                                <small class="text-muted text-uppercase fw-semibold sidebar-text" style="font-size: 0.7rem; letter-spacing: 0.5px;">Users</small>
                            </div>
                        </li>
                        
                        @if($hasUserPermission)
                            <li class="nav-item">
                                <a class="nav-link py-2 {{ request()->routeIs('admin.users.index') && !request()->routeIs('admin.users.staff*') ? 'active' : '' }}" href="{{ route('admin.users.index') }}" data-title="Users">
                                    <i class="fas fa-users me-2"></i>
                                    <span class="sidebar-text">Users</span>
                                </a>
                            </li>
                            <li class="nav-item">
                                <a class="nav-link py-2 {{ request()->routeIs('admin.user-groups*') ? 'active' : '' }}" href="{{ route('admin.user-groups.index') }}" data-title="Groups">
                                    <i class="fas fa-users-cog me-2"></i>
                                    <span class="sidebar-text">Groups</span>
                                </a>
                            </li>
                        @endif
                        
                        @if($hasStaffPermission)
                            <li class="nav-item">
                                <a class="nav-link py-2 {{ request()->routeIs('admin.users.staff*') ? 'active' : '' }}" href="{{ route('admin.users.staff') }}" data-title="Staff">
                                    <i class="fas fa-user-tie me-2"></i>
                                    <span class="sidebar-text">Staff</span>
                                </a>
                            </li>
                        @endif
                        
                        @if(auth()->user()->hasPermission('manage_roles'))
                            <li class="nav-item">
                                <a class="nav-link py-2 {{ request()->routeIs('admin.roles*') || request()->routeIs('admin.permissions*') ? 'active' : '' }}" href="{{ route('admin.roles.index') }}" data-title="Roles">
                                    <i class="fas fa-user-shield me-2"></i>
                                    <span class="sidebar-text">Roles</span>
                                </a>
                            </li>
                        @endif
                    @endif
                    
                    <!-- HR -->
                    @if($hasAttendancePermission || $hasSalaryPermission || $hasTaskPermission)
                        <li class="nav-item mt-2">
                            <div class="px-3 py-1">
                                <small class="text-muted text-uppercase fw-semibold sidebar-text" style="font-size: 0.7rem; letter-spacing: 0.5px;">HR</small>
                            </div>
                        </li>
                        
                        @if($hasAttendancePermission)
                            <li class="nav-item">
                                <a class="nav-link py-2 {{ request()->routeIs('admin.attendance*') ? 'active' : '' }}" href="{{ route('admin.attendance.index') }}" data-title="Attendance">
                                    <i class="fas fa-calendar-check me-2"></i>
                                    <span class="sidebar-text">Attendance</span>
                                </a>
                            </li>
                        @endif
                        
                        @if($hasSalaryPermission)
                            <li class="nav-item">
                                <a class="nav-link py-2 {{ request()->routeIs('admin.salary*') ? 'active' : '' }}" href="{{ route('admin.salary.index') }}" data-title="Salary">
                                    <i class="fas fa-wallet me-2"></i>
                                    <span class="sidebar-text">Salary</span>
                                </a>
                            </li>
                        @endif
                        
                        @if($hasTaskPermission)
                            <li class="nav-item">
                                <a class="nav-link py-2 {{ request()->routeIs('admin.tasks*') ? 'active' : '' }}" href="{{ route('admin.tasks.index') }}" data-title="Tasks">
                                    <i class="fas fa-tasks me-2"></i>
                                    <span class="sidebar-text">Tasks</span>
                                </a>
                            </li>
                        @endif
                    @endif
                    
                    <!-- Content -->
                    @if($hasLeadPermission || $hasPagePermission)
                        <li class="nav-item mt-2">
                            <div class="px-3 py-1">
                                <small class="text-muted text-uppercase fw-semibold sidebar-text" style="font-size: 0.7rem; letter-spacing: 0.5px;">Content</small>
                            </div>
                        </li>
                        
                        @if($hasLeadPermission)
                            <li class="nav-item">
                                <a class="nav-link py-2 {{ request()->routeIs('admin.leads*') ? 'active' : '' }}" href="{{ route('admin.leads.index') }}" data-title="Leads">
                                    <i class="fas fa-bullseye me-2"></i>
                                    <span class="sidebar-text">Leads</span>
                                </a>
                            </li>
                        @endif
                        
                        @if($hasPagePermission)
                            <li class="nav-item">
                                <a class="nav-link py-2 {{ request()->routeIs('admin.pages*') ? 'active' : '' }}" href="{{ route('admin.pages.index') }}" data-title="Pages">
                                    <i class="fas fa-file-alt me-2"></i>
                                    <span class="sidebar-text">Pages</span>
                                </a>
                            </li>
                        @endif
                    @endif
                    
                    <!-- System -->
                    <li class="nav-item mt-2">
                        <div class="px-3 py-1">
                            <small class="text-muted text-uppercase fw-semibold sidebar-text" style="font-size: 0.7rem; letter-spacing: 0.5px;">System</small>
                        </div>
                    </li>
                    
                    <li class="nav-item">
                        <a class="nav-link py-2 {{ request()->routeIs('admin.firebase.notifications*') ? 'active' : '' }}" href="{{ route('admin.firebase.notifications') }}" data-title="Notifications">
                            <i class="fas fa-bell me-2"></i>
                            <span class="sidebar-text">Notifications</span>
                        </a>
                    </li>
                    
                    @if(auth()->user()->hasPermission('manage_settings'))
                        <li class="nav-item">
                            <a class="nav-link py-2 {{ request()->routeIs('admin.settings') ? 'active' : '' }}" href="{{ route('admin.settings') }}" data-title="Settings">
                                <i class="fas fa-cog me-2"></i>
                                <span class="sidebar-text">Settings</span>
                            </a>
                        </li>
                    @endif
                </ul>
            </div>
        </div>
        
        <!-- Sidebar Footer - Compact -->
        <div class="px-3 py-2 border-top border-default mt-auto sidebar-footer">
            <div class="d-flex align-items-center mb-2 sidebar-status">
                <div class="bg-success rounded-circle me-2" style="width: 6px; height: 6px;"></div>
                <div class="small sidebar-text">
                    <span class="text-secondary" style="font-size: 0.75rem;">System Online</span>
                </div>
            </div>
            <form method="POST" action="{{ route('logout') }}">
                @csrf
                <button type="submit" class="btn btn-outline-danger w-100 rounded py-1" data-title="Logout" style="font-size: 0.875rem;">
                    <i class="fas fa-sign-out-alt me-2"></i>
                    <span class="sidebar-text">Logout</span>
                </button>
            </form>
        </div>
    </div>
</nav>

<style>
/* Custom thin scrollbar */
.scrollbar-thin::-webkit-scrollbar {
    width: 4px;
}

.scrollbar-thin::-webkit-scrollbar-track {
    background: transparent;
}

.scrollbar-thin::-webkit-scrollbar-thumb {
    background: rgba(0, 0, 0, 0.2);
    border-radius: 2px;
}

.scrollbar-thin::-webkit-scrollbar-thumb:hover {
    background: rgba(0, 0, 0, 0.3);
}

/* Firefox */
.scrollbar-thin {
    scrollbar-width: thin;
    scrollbar-color: rgba(0, 0, 0, 0.2) transparent;
}
</style>
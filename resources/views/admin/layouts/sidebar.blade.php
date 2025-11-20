<!-- Sidebar -->
<nav id="sidebar" class="col-md-3 col-lg-2 d-md-block bg-surface sidebar collapse">
    <div class="position-sticky pt-3 d-flex flex-column vh-100">
        <div class="px-3 pb-3 border-bottom border-default">
            <div class="d-flex align-items-center mb-3">
                @if(setting('header_logo'))
                    <img src="{{ asset('storage/' . setting('header_logo')) }}" alt="{{ setting('site_title', 'Admin Panel') }}" class="me-2 rounded" height="48">
                @else
                    <div class="bg-theme rounded-circle d-flex align-items-center justify-content-center me-2" style="width: 48px; height: 48px;">
                        <i class="fas fa-cube text-white"></i>
                    </div>
                    <h1 class="h5 mb-0 fw-bold">{{ setting('site_title', 'Admin Panel') }}</h1>
                @endif
            </div>
        </div>
        
        <ul class="nav flex-column px-2 py-3 flex-grow-1">
            <li class="nav-item mb-1">
                <a class="nav-link {{ request()->routeIs('dashboard') ? 'active bg-theme text-white' : 'hover-bg' }} rounded-pill d-flex align-items-center py-2 px-3" href="{{ route('dashboard') }}">
                    <i class="fas fa-home me-3"></i>
                    <span class="sidebar-text">Dashboard</span>
                </a>
            </li>
            
            <!-- Product Section -->
            @if(auth()->user()->hasPermission('viewAny_product') || 
                auth()->user()->hasPermission('create_product') || 
                auth()->user()->hasPermission('update_product') || 
                auth()->user()->hasPermission('delete_product'))
                <li class="nav-item mb-1">
                    <a class="nav-link {{ request()->routeIs('admin.products*') ? 'active bg-theme text-white' : 'hover-bg' }} rounded-pill d-flex align-items-center py-2 px-3" href="{{ route('admin.products.index') }}">
                        <i class="fas fa-box me-3"></i>
                        <span class="sidebar-text">Product</span>
                    </a>
                </li>
            @endif
            
            <!-- Category Section -->
            @if(auth()->user()->hasPermission('viewAny_category') || 
                auth()->user()->hasPermission('create_category') || 
                auth()->user()->hasPermission('update_category') || 
                auth()->user()->hasPermission('delete_category'))
                <li class="nav-item mb-1">
                    <a class="nav-link {{ request()->routeIs('admin.categories*') ? 'active bg-theme text-white' : 'hover-bg' }} rounded-pill d-flex align-items-center py-2 px-3" href="{{ route('admin.categories.index') }}">
                        <i class="fas fa-tags me-3"></i>
                        <span class="sidebar-text">Category</span>
                    </a>
                </li>
            @endif
                
                @if(auth()->user()->hasPermission('manage_settings'))
                    <li class="nav-item mb-1">
                        <a class="nav-link {{ request()->routeIs('admin.settings') ? 'active bg-theme text-white' : 'hover-bg' }} rounded-pill d-flex align-items-center py-2 px-3" href="{{ route('admin.settings') }}">
                            <i class="fas fa-cog me-3"></i>
                            <span class="sidebar-text">Settings</span>
                        </a>
                    </li>
                @endif
                
                <!-- Staff Section -->
                @php 
                    $hasStaffPermission = auth()->user()->hasPermission('show_staff') ||
                                        auth()->user()->hasPermission('add_staff') || 
                                        auth()->user()->hasPermission('edit_staff') || 
                                        auth()->user()->hasPermission('delete_staff'); 
                @endphp
                @if($hasStaffPermission)
                    <li class="nav-item mb-1">
                        <a class="nav-link {{ request()->routeIs('admin.users.staff*') ? 'active bg-theme text-white' : 'hover-bg' }} rounded-pill d-flex align-items-center py-2 px-3" href="{{ route('admin.users.staff') }}">
                            <i class="fas fa-user-tie me-3"></i>
                            <span class="sidebar-text">Staff</span>
                        </a>
                    </li>
                @endif
                
                <!-- Users Section -->
                @php 
                    $hasUserPermission = auth()->user()->hasPermission('show_user') ||
                                        auth()->user()->hasPermission('add_user') || 
                                        auth()->user()->hasPermission('edit_user') || 
                                        auth()->user()->hasPermission('delete_user'); 
                @endphp
                @if($hasUserPermission)
                    <li class="nav-item mb-1">
                        <a class="nav-link {{ request()->routeIs('admin.users.index') && !request()->routeIs('admin.users.staff*') ? 'active bg-theme text-white' : 'hover-bg' }} rounded-pill d-flex align-items-center py-2 px-3" href="{{ route('admin.users.index') }}">
                            <i class="fas fa-users me-3"></i>
                            <span class="sidebar-text">Users</span>
                        </a>
                    </li>
                @endif
                
                <!-- User Groups Section -->
                @if($hasUserPermission)
                    <li class="nav-item mb-1">
                        <a class="nav-link {{ request()->routeIs('admin.user-groups*') ? 'active bg-theme text-white' : 'hover-bg' }} rounded-pill d-flex align-items-center py-2 px-3" href="{{ route('admin.user-groups.index') }}">
                            <i class="fas fa-users-cog me-3"></i>
                            <span class="sidebar-text">User Groups</span>
                        </a>
                    </li>
                @endif
                
                <!-- User Role and Permission Section (Only visible to users with manage_roles permission) -->
                @if(auth()->user()->hasPermission('manage_roles'))
                    <li class="nav-item mb-1">
                        <a class="nav-link {{ request()->routeIs('admin.roles*') || request()->routeIs('admin.permissions*') ? 'active bg-theme text-white' : 'hover-bg' }} rounded-pill d-flex align-items-center py-2 px-3" href="{{ route('admin.roles.index') }}">
                            <i class="fas fa-user-shield me-3"></i>
                            <span class="sidebar-text">User Role & Permission</span>
                        </a>
                    </li>
                @endif

                <!-- Here i want media library link -->
                @if(auth()->user()->hasPermission('viewAny_media'))
                    <li class="nav-item mb-1">
                        <a class="nav-link {{ request()->routeIs('admin.media*') ? 'active bg-theme text-white' : 'hover-bg' }} rounded-pill d-flex align-items-center py-2 px-3" href="{{ route('admin.media.index') }}">
                            <i class="fas fa-photo-video me-3"></i>
                            <span class="sidebar-text">Media Library</span>
                        </a>
                    </li>
                @endif
                
                <!-- Proforma Invoice Section -->
                @if(auth()->user()->hasPermission('manage_proforma_invoices'))
                    <li class="nav-item mb-1">
                        <a class="nav-link {{ request()->routeIs('admin.proforma-invoice*') ? 'active bg-theme text-white' : 'hover-bg' }} rounded-pill d-flex align-items-center py-2 px-3" href="{{ route('admin.proforma-invoice.index') }}">
                            <i class="fas fa-file-invoice me-3"></i>
                            <span class="sidebar-text">Invoice</span>
                        </a>
                    </li>
                @endif

            </ul>
            
            <div class="px-3 py-3 border-top border-default mt-auto">
                <div class="d-flex align-items-center mb-3">
                    <div class="bg-success rounded-circle d-flex align-items-center justify-content-center me-2" style="width: 12px; height: 12px;">
                        <i class="fas fa-circle text-success fs-7"></i>
                    </div>
                    <div class="small">
                        <div class="fw-medium">System Status</div>
                        <div class="text-secondary">Operational</div>
                    </div>
                </div>
                <form method="POST" action="{{ route('logout') }}">
                    @csrf
                    <button type="submit" class="btn btn-outline-danger w-100 rounded-pill py-2">
                        <i class="fas fa-sign-out-alt me-2"></i>
                        <span class="sidebar-text">Logout</span>
                    </button>
                </form>
            </div>
        </div>
    </nav>
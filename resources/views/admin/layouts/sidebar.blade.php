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
            <li class="nav-item mb-1">
                <a class="nav-link {{ request()->routeIs('admin.settings') ? 'active bg-theme text-white' : 'hover-bg' }} rounded-pill d-flex align-items-center py-2 px-3" href="{{ route('admin.settings') }}">
                    <i class="fas fa-cog me-3"></i>
                    <span class="sidebar-text">Settings</span>
                </a>
            </li>
            <li class="nav-item mb-1">
                <a class="nav-link {{ request()->routeIs('admin.users.*') ? 'active bg-theme text-white' : 'hover-bg' }} rounded-pill d-flex align-items-center py-2 px-3" href="{{ route('admin.users.index') }}">
                    <i class="fas fa-users me-3"></i>
                    <span class="sidebar-text">Users</span>
                </a>
            </li>
            <li class="nav-item mb-1">
                <a class="nav-link hover-bg rounded-pill d-flex align-items-center py-2 px-3" href="#">
                    <i class="fas fa-chart-bar me-3"></i>
                    <span class="sidebar-text">Analytics</span>
                </a>
            </li>
            <li class="nav-item mb-1">
                <a class="nav-link hover-bg rounded-pill d-flex align-items-center py-2 px-3" href="#">
                    <i class="fas fa-shopping-cart me-3"></i>
                    <span class="sidebar-text">Orders</span>
                </a>
            </li>
            <li class="nav-item mb-1">
                <a class="nav-link hover-bg rounded-pill d-flex align-items-center py-2 px-3" href="#">
                    <i class="fas fa-box me-3"></i>
                    <span class="sidebar-text">Products</span>
                </a>
            </li>
            <li class="nav-item mb-1">
                <a class="nav-link hover-bg rounded-pill d-flex align-items-center py-2 px-3" href="{{ route('admin.color-palette') }}">
                    <i class="fas fa-palette me-3"></i>
                    <span class="sidebar-text">Color Palette</span>
                </a>
            </li>
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
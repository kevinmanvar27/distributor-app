<!-- Header -->
<header class="bg-surface border-bottom border-default shadow-sm py-3">
    <div class="container-fluid">
        <div class="d-flex justify-content-between align-items-center">
            <div class="d-flex align-items-center">
                <button id="sidebar-toggle" class="btn btn-outline-secondary me-3 d-md-none rounded-circle" type="button">
                    <i class="fas fa-bars"></i>
                </button>
                
                <div>
                    <h1 class="h4 mb-0 fw-semibold">@yield('page-title', 'Dashboard')</h1>
                    <!-- Breadcrumbs -->
                    @if (isset($breadcrumbs) && is_array($breadcrumbs))
                        <nav aria-label="breadcrumb">
                            <ol class="breadcrumb mb-0 small">
                                <li class="breadcrumb-item"><a href="{{ route('dashboard') }}">Home</a></li>
                                @foreach ($breadcrumbs as $label => $url)
                                    @if (is_string($label) && $url)
                                        <li class="breadcrumb-item"><a href="{{ $url }}">{{ $label }}</a></li>
                                    @else
                                        <li class="breadcrumb-item active" aria-current="page">{{ $url }}</li>
                                    @endif
                                @endforeach
                            </ol>
                        </nav>
                    @endif
                </div>
            </div>
            
            <div class="d-flex align-items-center">
                <!-- Search Bar -->
                <div class="input-group me-3 d-none d-lg-flex" style="max-width: 250px;">
                    <span class="input-group-text bg-surface border-default rounded-start-pill">
                        <i class="fas fa-search text-secondary"></i>
                    </span>
                    <input type="text" class="form-control border-default rounded-end-pill ps-2" placeholder="Search..." style="font-size: 0.9rem;">
                </div>
                
                <!-- Theme Toggle -->
                <button id="theme-toggle" class="btn btn-outline-secondary me-2 rounded-circle" type="button" data-bs-toggle="tooltip" data-bs-placement="bottom" title="Toggle Theme">
                    <i id="theme-icon" class="fas fa-moon"></i>
                </button>
                
                <!-- Notifications -->
                <div class="dropdown me-2">
                    <button class="btn btn-outline-secondary position-relative rounded-circle" type="button" id="notificationsDropdown" data-bs-toggle="dropdown" aria-expanded="false">
                        <i class="fas fa-bell"></i>
                        <span class="position-absolute top-0 start-100 translate-middle badge rounded-pill bg-danger">3</span>
                    </button>
                    <ul class="dropdown-menu dropdown-menu-end shadow-sm mt-2" aria-labelledby="notificationsDropdown">
                        <li><h6 class="dropdown-header fw-semibold">Notifications</h6></li>
                        <li>
                            <a class="dropdown-item d-flex align-items-start py-2" href="#">
                                <div class="bg-primary bg-opacity-10 p-2 rounded-circle me-3">
                                    <i class="fas fa-user-plus text-primary"></i>
                                </div>
                                <div>
                                    <div class="fw-medium">New user registered</div>
                                    <small class="text-secondary">2 hours ago</small>
                                </div>
                            </a>
                        </li>
                        <li>
                            <a class="dropdown-item d-flex align-items-start py-2" href="#">
                                <div class="bg-success bg-opacity-10 p-2 rounded-circle me-3">
                                    <i class="fas fa-cog text-success"></i>
                                </div>
                                <div>
                                    <div class="fw-medium">Settings updated</div>
                                    <small class="text-secondary">5 hours ago</small>
                                </div>
                            </a>
                        </li>
                        <li>
                            <a class="dropdown-item d-flex align-items-start py-2" href="#">
                                <div class="bg-info bg-opacity-10 p-2 rounded-circle me-3">
                                    <i class="fas fa-user-edit text-info"></i>
                                </div>
                                <div>
                                    <div class="fw-medium">Profile updated</div>
                                    <small class="text-secondary">1 day ago</small>
                                </div>
                            </a>
                        </li>
                        <li><hr class="dropdown-divider"></li>
                        <li><a class="dropdown-item text-center fw-medium" href="#">View all notifications</a></li>
                    </ul>
                </div>
                
                <!-- User Profile -->
                <div class="dropdown">
                    <button class="btn btn-outline-secondary dropdown-toggle d-flex align-items-center py-1 px-2" type="button" id="userDropdown" data-bs-toggle="dropdown" aria-expanded="false">
                        <img class="rounded-circle me-2" src="{{ Auth::user()->avatar ? asset('storage/avatars/' . Auth::user()->avatar) : 'https://ui-avatars.com/api/?name=' . urlencode(Auth::user()->name) . '&background=random' }}" alt="{{ Auth::user()->name }}" width="32" height="32">
                        <div class="d-none d-md-block text-start">
                            <div class="fw-medium small mb-0">{{ Auth::user()->name }}</div>
                            <small>{{ ucfirst(str_replace('_', ' ', Auth::user()->user_role)) }}</small>
                        </div>
                    </button>
                    <ul class="dropdown-menu dropdown-menu-end shadow-sm mt-2" aria-labelledby="userDropdown">
                        <li><h6 class="dropdown-header fw-semibold">{{ Auth::user()->name }}</h6></li>
                        <li><a class="dropdown-item" href="{{ route('admin.profile') }}"><i class="fas fa-user-circle me-2"></i>Profile</a></li>
                        <li><a class="dropdown-item" href="{{ route('admin.settings') }}"><i class="fas fa-cog me-2"></i>Settings</a></li>
                        <li><hr class="dropdown-divider"></li>
                        <li>
                            <form method="POST" action="{{ route('logout') }}">
                                @csrf
                                <button type="submit" class="dropdown-item"><i class="fas fa-sign-out-alt me-2"></i>Logout</button>
                            </form>
                        </li>
                    </ul>
                </div>
            </div>
        </div>
    </div>
</header>
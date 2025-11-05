@extends('admin.layouts.app')

@section('title', 'Dashboard - ' . config('app.name', 'Laravel'))

@section('content')
<div class="container-fluid h-100">
    <div class="row h-100">
        @include('admin.layouts.sidebar')
        
        <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4 main-content">
            @include('admin.layouts.header', ['pageTitle' => 'Dashboard'])
            
            <div class="pt-4 pb-2 mb-3">
                <!-- Welcome Card -->
                <div class="card border-0 shadow-sm mb-4">
                    <div class="card-body">
                        <div class="d-flex justify-content-between align-items-start">
                            <div>
                                <h2 class="card-title mb-2">Welcome back, {{ Auth::user()->name }}!</h2>
                                <p class="text-secondary mb-0">Here's what's happening with your store today.</p>
                            </div>
                            <div class="d-flex">
                                <button class="btn btn-sm btn-outline-secondary rounded-pill me-2">
                                    <i class="fas fa-download me-1"></i> Generate Report
                                </button>
                                <button class="btn btn-sm btn-theme rounded-pill">
                                    <i class="fas fa-plus me-1"></i> New Order
                                </button>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Stats Cards -->
                <div class="row g-4 mb-4">
                    <div class="col-md-6 col-lg-3">
                        <div class="card border-0 shadow-sm h-100">
                            <div class="card-body">
                                <div class="d-flex justify-content-between align-items-center mb-3">
                                    <div class="bg-primary bg-opacity-10 p-3 rounded-circle">
                                        <i class="fas fa-users text-primary"></i>
                                    </div>
                                    <div class="text-end">
                                        <h3 class="h5 text-secondary mb-1">Total Users</h3>
                                        <p class="h3 mb-0 fw-bold">{{ $userCount }}</p>
                                    </div>
                                </div>
                                <div class="d-flex justify-content-between align-items-center">
                                    <span class="text-success fw-medium"><i class="fas fa-arrow-up me-1"></i> 12.5%</span>
                                    <span class="text-secondary small">Since last month</span>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-md-6 col-lg-3">
                        <div class="card border-0 shadow-sm h-100">
                            <div class="card-body">
                                <div class="d-flex justify-content-between align-items-center mb-3">
                                    <div class="bg-info bg-opacity-10 p-3 rounded-circle">
                                        <i class="fas fa-users-cog text-info"></i>
                                    </div>
                                    <div class="text-end">
                                        <h3 class="h5 text-secondary mb-1">User Groups</h3>
                                        <p class="h3 mb-0 fw-bold">{{ $userGroupCount }}</p>
                                    </div>
                                </div>
                                <div class="d-flex justify-content-between align-items-center">
                                    <span class="text-success fw-medium"><i class="fas fa-arrow-up me-1"></i> 8.3%</span>
                                    <span class="text-secondary small">Since last month</span>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-md-6 col-lg-3">
                        <div class="card border-0 shadow-sm h-100">
                            <div class="card-body">
                                <div class="d-flex justify-content-between align-items-center mb-3">
                                    <div class="bg-success bg-opacity-10 p-3 rounded-circle">
                                        <i class="fas fa-boxes text-success"></i>
                                    </div>
                                    <div class="text-end">
                                        <h3 class="h5 text-secondary mb-1">Products</h3>
                                        <p class="h3 mb-0 fw-bold">{{ $productCount }}</p>
                                    </div>
                                </div>
                                <div class="d-flex justify-content-between align-items-center">
                                    <span class="text-success fw-medium"><i class="fas fa-arrow-up me-1"></i> 5.2%</span>
                                    <span class="text-secondary small">Since last month</span>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-md-6 col-lg-3">
                        <div class="card border-0 shadow-sm h-100">
                            <div class="card-body">
                                <div class="d-flex justify-content-between align-items-center mb-3">
                                    <div class="bg-warning bg-opacity-10 p-3 rounded-circle">
                                        <i class="fas fa-tags text-warning"></i>
                                    </div>
                                    <div class="text-end">
                                        <h3 class="h5 text-secondary mb-1">Categories</h3>
                                        <p class="h3 mb-0 fw-bold">{{ $categoryCount }}</p>
                                    </div>
                                </div>
                                <div class="d-flex justify-content-between align-items-center">
                                    <span class="text-success fw-medium"><i class="fas fa-arrow-up me-1"></i> 3.1%</span>
                                    <span class="text-secondary small">Since last month</span>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Charts and Recent Activity -->
                <div class="row g-4">
                    <!-- Chart -->
                    <div class="col-lg-12">
                        <div class="card border-0 shadow-sm">
                            <div class="card-header bg-transparent border-0 d-flex justify-content-between align-items-center">
                                <h3 class="h5 mb-0 fw-semibold">Performance Overview</h3>
                                <div class="dropdown">
                                    <button class="btn btn-sm btn-outline-secondary dropdown-toggle rounded-pill" type="button" id="chartDropdown" data-bs-toggle="dropdown" aria-expanded="false">
                                        Last 7 Days
                                    </button>
                                    <ul class="dropdown-menu dropdown-menu-end" aria-labelledby="chartDropdown">
                                        <li><a class="dropdown-item" href="#">Last 7 Days</a></li>
                                        <li><a class="dropdown-item" href="#">Last 30 Days</a></li>
                                        <li><a class="dropdown-item" href="#">Last 90 Days</a></li>
                                    </ul>
                                </div>
                            </div>
                            <div class="card-body">
                                <div class="d-flex align-items-center justify-content-center" style="height: 300px;">
                                    <div class="text-center">
                                        <div class="bg-primary bg-opacity-10 p-4 rounded-circle d-inline-block mb-3">
                                            <i class="fas fa-chart-bar text-primary fs-1"></i>
                                        </div>
                                        <h4 class="fw-semibold">Performance Chart</h4>
                                        <p class="text-secondary">Visual representation of your data will appear here</p>
                                        <button class="btn btn-sm btn-theme rounded-pill">View Detailed Report</button>
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
            
            @include('admin.layouts.footer')
        </main>
    </div>
</div>
@endsection

@section('scripts')
<script>
    // Initialize tooltips
    var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
    var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
        return new bootstrap.Tooltip(tooltipTriggerEl)
    })
</script>
@endsection

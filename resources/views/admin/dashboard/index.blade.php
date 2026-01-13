@extends('admin.layouts.app')

@section('title', 'Dashboard - ' . config('app.name', 'Laravel'))

@section('styles')
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script>
<style>
    .stat-card {
        transition: transform 0.2s ease, box-shadow 0.2s ease;
    }
    .stat-card:hover {
        transform: translateY(-2px);
        box-shadow: 0 0.5rem 1rem rgba(0, 0, 0, 0.1) !important;
    }
    .stat-icon {
        width: 48px;
        height: 48px;
        display: flex;
        align-items: center;
        justify-content: center;
        font-size: 1.25rem;
    }
    .chart-container {
        position: relative;
        height: 300px;
    }
    .progress-thin {
        height: 6px;
    }
    .table-hover tbody tr:hover {
        background-color: rgba(var(--bs-primary-rgb), 0.05);
    }
    .status-badge {
        font-size: 0.75rem;
        padding: 0.35em 0.65em;
    }
    .quick-action-btn {
        transition: all 0.2s ease;
    }
    .quick-action-btn:hover {
        transform: scale(1.05);
    }
    .lead-stat-item {
        padding: 0.5rem;
        border-radius: 0.5rem;
        transition: background-color 0.2s ease;
    }
    .lead-stat-item:hover {
        background-color: rgba(var(--bs-primary-rgb), 0.05);
    }
</style>
@endsection

@section('content')
@php
    $user = Auth::user();
    // Define permission checks
    $canViewProducts = $user->hasPermission('viewAny_product') || $user->hasPermission('create_product') || $user->hasPermission('update_product') || $user->hasPermission('delete_product');
    $canCreateProduct = $user->hasPermission('create_product');
    $canViewOrders = $user->hasPermission('manage_proforma_invoices');
    $canViewPendingBills = $user->hasPermission('manage_pending_bills');
    $canViewLeads = $user->hasPermission('viewAny_lead') || $user->hasPermission('create_lead') || $user->hasPermission('update_lead') || $user->hasPermission('delete_lead');
    $canViewUsers = $user->hasPermission('show_user') || $user->hasPermission('add_user') || $user->hasPermission('edit_user') || $user->hasPermission('delete_user');
@endphp
<div class="container-fluid h-100">
    <div class="row h-100">
        @include('admin.layouts.sidebar')
        
        <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4 main-content">
            @include('admin.layouts.header', ['pageTitle' => 'Dashboard'])
            
            <div class="pt-4 pb-2 mb-3">
                <!-- Welcome Card with Today's Summary -->
                <div class="card border-0 shadow-sm mb-4">
                    <div class="card-body">
                        <div class="row align-items-center">
                            <div class="col-lg-6">
                                <h2 class="card-title mb-2">Welcome back, {{ Auth::user()->name }}!</h2>
                                <p class="text-secondary mb-3">Here's what's happening with your store today.</p>
                                <div class="d-flex gap-4">
                                    @if($canViewOrders)
                                    <div>
                                        <span class="text-secondary small">Today's Orders</span>
                                        <h4 class="mb-0 text-primary">{{ $todayOrders }}</h4>
                                    </div>
                                    <div>
                                        <span class="text-secondary small">Today's Revenue</span>
                                        <h4 class="mb-0 text-success">₹{{ number_format($todayRevenue, 2) }}</h4>
                                    </div>
                                    <div>
                                        <span class="text-secondary small">Pending Orders</span>
                                        <h4 class="mb-0 text-warning">{{ $pendingOrders }}</h4>
                                    </div>
                                    @endif
                                </div>
                            </div>
                            <div class="col-lg-6 text-lg-end mt-3 mt-lg-0">
                                @if($canViewOrders)
                                <a href="{{ route('admin.proforma-invoice.index') }}" class="btn btn-sm btn-outline-secondary rounded-pill me-2">
                                    <i class="fas fa-file-invoice me-1"></i> View Orders
                                </a>
                                @endif
                                @if($canViewProducts)
                                <a href="{{ route('admin.products.low-stock') }}" class="btn btn-sm btn-outline-warning rounded-pill me-2">
                                    <i class="fas fa-exclamation-triangle me-1"></i> Low Stock ({{ $lowStockProducts->count() }})
                                </a>
                                @endif
                                @if($canCreateProduct)
                                <a href="{{ route('admin.products.create') }}" class="btn btn-sm btn-theme rounded-pill">
                                    <i class="fas fa-plus me-1"></i> Add Product
                                </a>
                                @endif
                            </div>
                        </div>
                    </div>
                </div>
                
                <!-- Revenue Stats Cards -->
                <div class="row g-4 mb-4">
                    @if($canViewOrders)
                    <div class="col-md-6 col-lg-3">
                        <div class="card border-0 shadow-sm h-100 stat-card">
                            <div class="card-body">
                                <div class="d-flex justify-content-between align-items-start mb-3">
                                    <div class="stat-icon bg-success bg-opacity-10 rounded-circle">
                                        <i class="fas fa-indian-rupee-sign text-success"></i>
                                    </div>
                                    <span class="badge {{ $revenueGrowth >= 0 ? 'bg-success' : 'bg-danger' }} bg-opacity-10 {{ $revenueGrowth >= 0 ? 'text-success' : 'text-danger' }}">
                                        <i class="fas fa-arrow-{{ $revenueGrowth >= 0 ? 'up' : 'down' }} me-1"></i>{{ abs($revenueGrowth) }}%
                                    </span>
                                </div>
                                <h3 class="h6 text-secondary mb-1">Total Revenue</h3>
                                <p class="h4 mb-0 fw-bold">₹{{ number_format($totalRevenue, 2) }}</p>
                                <small class="text-muted">This month: ₹{{ number_format($monthlyRevenue, 2) }}</small>
                            </div>
                        </div>
                    </div>
                    
                    <div class="col-md-6 col-lg-3">
                        <div class="card border-0 shadow-sm h-100 stat-card">
                            <div class="card-body">
                                <div class="d-flex justify-content-between align-items-start mb-3">
                                    <div class="stat-icon bg-primary bg-opacity-10 rounded-circle">
                                        <i class="fas fa-shopping-cart text-primary"></i>
                                    </div>
                                    <span class="badge bg-primary bg-opacity-10 text-primary">
                                        {{ $pendingOrders }} pending
                                    </span>
                                </div>
                                <h3 class="h6 text-secondary mb-1">Total Orders</h3>
                                <p class="h4 mb-0 fw-bold">{{ $totalOrders }}</p>
                                <small class="text-muted">Delivered: {{ $deliveredOrders }}</small>
                            </div>
                        </div>
                    </div>
                    @endif
                    
                    @if($canViewUsers)
                    <div class="col-md-6 col-lg-3">
                        <div class="card border-0 shadow-sm h-100 stat-card">
                            <div class="card-body">
                                <div class="d-flex justify-content-between align-items-start mb-3">
                                    <div class="stat-icon bg-info bg-opacity-10 rounded-circle">
                                        <i class="fas fa-users text-info"></i>
                                    </div>
                                    <span class="badge bg-info bg-opacity-10 text-info">
                                        {{ $userGroupCount }} groups
                                    </span>
                                </div>
                                <h3 class="h6 text-secondary mb-1">Total Users</h3>
                                <p class="h4 mb-0 fw-bold">{{ $userCount }}</p>
                                <small class="text-muted">Active customers</small>
                            </div>
                        </div>
                    </div>
                    @endif
                    
                    @if($canViewProducts)
                    <div class="col-md-6 col-lg-3">
                        <div class="card border-0 shadow-sm h-100 stat-card">
                            <div class="card-body">
                                <div class="d-flex justify-content-between align-items-start mb-3">
                                    <div class="stat-icon bg-warning bg-opacity-10 rounded-circle">
                                        <i class="fas fa-boxes text-warning"></i>
                                    </div>
                                    @if($outOfStockCount > 0)
                                    <span class="badge bg-danger bg-opacity-10 text-danger">
                                        {{ $outOfStockCount }} out of stock
                                    </span>
                                    @else
                                    <span class="badge bg-success bg-opacity-10 text-success">
                                        All in stock
                                    </span>
                                    @endif
                                </div>
                                <h3 class="h6 text-secondary mb-1">Products</h3>
                                <p class="h4 mb-0 fw-bold">{{ $productCount }}</p>
                                <small class="text-muted">{{ $categoryCount }} categories</small>
                            </div>
                        </div>
                    </div>
                    @endif
                </div>
                
                <!-- Charts Row -->
                @if($canViewOrders)
                <div class="row g-4 mb-4">
                    <!-- Revenue Chart -->
                    <div class="col-lg-8">
                        <div class="card border-0 shadow-sm h-100">
                            <div class="card-header bg-transparent border-0 d-flex justify-content-between align-items-center">
                                <h3 class="h5 mb-0 fw-semibold">Revenue Overview</h3>
                                <div class="btn-group btn-group-sm" role="group">
                                    <button type="button" class="btn btn-outline-secondary active" id="weeklyBtn" onclick="switchChart('weekly')">Weekly</button>
                                    <button type="button" class="btn btn-outline-secondary" id="monthlyBtn" onclick="switchChart('monthly')">Monthly</button>
                                </div>
                            </div>
                            <div class="card-body">
                                <div class="chart-container">
                                    <canvas id="revenueChart"></canvas>
                                </div>
                            </div>
                        </div>
                    </div>
                    
                    <!-- Order Status Distribution -->
                    <div class="col-lg-4">
                        <div class="card border-0 shadow-sm h-100">
                            <div class="card-header bg-transparent border-0">
                                <h3 class="h5 mb-0 fw-semibold">Order Status</h3>
                            </div>
                            <div class="card-body">
                                <div class="chart-container" style="height: 200px;">
                                    <canvas id="orderStatusChart"></canvas>
                                </div>
                                <div class="mt-3">
                                    @foreach($orderStatusData as $status)
                                    @if($status['count'] > 0)
                                    <div class="d-flex justify-content-between align-items-center mb-2">
                                        <div class="d-flex align-items-center">
                                            <span class="rounded-circle me-2" style="width: 10px; height: 10px; background-color: {{ $status['color'] }}; display: inline-block;"></span>
                                            <span class="small">{{ $status['status'] }}</span>
                                        </div>
                                        <span class="badge bg-light text-dark">{{ $status['count'] }}</span>
                                    </div>
                                    @endif
                                    @endforeach
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
                @endif
                
                <!-- Second Row: Recent Orders, Top Products, Leads -->
                <div class="row g-4 mb-4">
                    <!-- Recent Orders -->
                    @if($canViewOrders)
                    <div class="col-lg-6">
                        <div class="card border-0 shadow-sm h-100">
                            <div class="card-header bg-transparent border-0 d-flex justify-content-between align-items-center">
                                <h3 class="h5 mb-0 fw-semibold">Recent Orders</h3>
                                <a href="{{ route('admin.proforma-invoice.index') }}" class="btn btn-sm btn-link text-decoration-none">View All</a>
                            </div>
                            <div class="card-body p-0">
                                <div class="table-responsive">
                                    <table class="table table-hover mb-0">
                                        <thead class="table-light">
                                            <tr>
                                                <th class="border-0 ps-3">Invoice</th>
                                                <th class="border-0">Customer</th>
                                                <th class="border-0">Amount</th>
                                                <th class="border-0">Status</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            @forelse($recentOrders as $order)
                                            <tr>
                                                <td class="ps-3">
                                                    <a href="{{ route('admin.proforma-invoice.show', $order->id) }}" class="text-decoration-none fw-medium">
                                                        {{ $order->invoice_number }}
                                                    </a>
                                                    <br>
                                                    <small class="text-muted">{{ $order->created_at->format('M d, Y') }}</small>
                                                </td>
                                                <td>{{ $order->user->name ?? 'Guest' }}</td>
                                                <td class="fw-medium">₹{{ number_format($order->total_amount, 2) }}</td>
                                                <td>
                                                    @php
                                                        $statusColors = [
                                                            'Draft' => 'secondary',
                                                            'Approved' => 'primary',
                                                            'Dispatch' => 'info',
                                                            'Out for Delivery' => 'warning',
                                                            'Delivered' => 'success',
                                                            'Return' => 'danger'
                                                        ];
                                                        $color = $statusColors[$order->status] ?? 'secondary';
                                                    @endphp
                                                    <span class="badge bg-{{ $color }} status-badge">{{ $order->status }}</span>
                                                </td>
                                            </tr>
                                            @empty
                                            <tr>
                                                <td colspan="4" class="text-center py-4 text-muted">
                                                    <i class="fas fa-inbox fa-2x mb-2 d-block"></i>
                                                    No orders yet
                                                </td>
                                            </tr>
                                            @endforelse
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </div>
                    </div>
                    @endif
                    
                    <!-- Top Selling Products -->
                    @if($canViewProducts)
                    <div class="col-lg-6">
                        <div class="card border-0 shadow-sm h-100">
                            <div class="card-header bg-transparent border-0 d-flex justify-content-between align-items-center">
                                <h3 class="h5 mb-0 fw-semibold">Top Selling Products</h3>
                                <a href="{{ route('admin.products.index') }}" class="btn btn-sm btn-link text-decoration-none">View All</a>
                            </div>
                            <div class="card-body">
                                @forelse($topProducts as $index => $product)
                                <div class="d-flex justify-content-between align-items-center {{ !$loop->last ? 'mb-3 pb-3 border-bottom' : '' }}">
                                    <div class="d-flex align-items-center">
                                        <span class="badge bg-{{ $index < 3 ? 'primary' : 'secondary' }} rounded-circle me-3" style="width: 28px; height: 28px; display: flex; align-items: center; justify-content: center;">
                                            {{ $index + 1 }}
                                        </span>
                                        <div>
                                            <h6 class="mb-0">{{ Str::limit($product['name'], 30) }}</h6>
                                            <small class="text-muted">{{ $product['quantity'] }} units sold</small>
                                        </div>
                                    </div>
                                    <div class="text-end">
                                        <span class="fw-bold text-success">₹{{ number_format($product['revenue'], 2) }}</span>
                                    </div>
                                </div>
                                @empty
                                <div class="text-center py-4 text-muted">
                                    <i class="fas fa-chart-line fa-2x mb-2 d-block"></i>
                                    No sales data yet
                                </div>
                                @endforelse
                            </div>
                        </div>
                    </div>
                    @endif
                </div>
                
                <!-- Third Row: Low Stock & Leads -->
                <div class="row g-4 mb-4">
                    <!-- Low Stock Alert -->
                    @if($canViewProducts)
                    <div class="col-lg-6">
                        <div class="card border-0 shadow-sm h-100">
                            <div class="card-header bg-transparent border-0 d-flex justify-content-between align-items-center">
                                <h3 class="h5 mb-0 fw-semibold">
                                    <i class="fas fa-exclamation-triangle text-warning me-2"></i>Low Stock Alert
                                </h3>
                                <a href="{{ route('admin.products.low-stock') }}" class="btn btn-sm btn-link text-decoration-none">View All</a>
                            </div>
                            <div class="card-body">
                                @forelse($lowStockProducts as $product)
                                <div class="d-flex justify-content-between align-items-center {{ !$loop->last ? 'mb-3 pb-3 border-bottom' : '' }}">
                                    <div>
                                        <h6 class="mb-1">{{ Str::limit($product->name, 35) }}</h6>
                                        <div class="progress progress-thin" style="width: 150px;">
                                            @php
                                                $percentage = $product->low_quantity_threshold > 0 
                                                    ? min(100, ($product->stock_quantity / $product->low_quantity_threshold) * 100)
                                                    : 0;
                                                $progressColor = $percentage <= 25 ? 'danger' : ($percentage <= 50 ? 'warning' : 'success');
                                            @endphp
                                            <div class="progress-bar bg-{{ $progressColor }}" style="width: {{ $percentage }}%"></div>
                                        </div>
                                    </div>
                                    <div class="text-end">
                                        <span class="badge bg-{{ $product->stock_quantity <= 5 ? 'danger' : 'warning' }}">
                                            {{ $product->stock_quantity }} left
                                        </span>
                                        <br>
                                        <small class="text-muted">Min: {{ $product->low_quantity_threshold }}</small>
                                    </div>
                                </div>
                                @empty
                                <div class="text-center py-4 text-muted">
                                    <i class="fas fa-check-circle fa-2x mb-2 d-block text-success"></i>
                                    All products are well stocked
                                </div>
                                @endforelse
                            </div>
                        </div>
                    </div>
                    @endif
                    
                    <!-- Lead Statistics -->
                    @if($canViewLeads)
                    <div class="col-lg-6">
                        <div class="card border-0 shadow-sm h-100">
                            <div class="card-header bg-transparent border-0 d-flex justify-content-between align-items-center">
                                <h3 class="h5 mb-0 fw-semibold">
                                    <i class="fas fa-user-plus text-primary me-2"></i>Lead Statistics
                                </h3>
                                <a href="{{ route('admin.leads.index') }}" class="btn btn-sm btn-link text-decoration-none">View All</a>
                            </div>
                            <div class="card-body">
                                <div class="row g-3">
                                    <div class="col-6">
                                        <div class="lead-stat-item text-center p-3 bg-light rounded">
                                            <h3 class="mb-1 text-primary">{{ $leadStats['total'] }}</h3>
                                            <small class="text-muted">Total Leads</small>
                                        </div>
                                    </div>
                                    <div class="col-6">
                                        <div class="lead-stat-item text-center p-3 bg-light rounded">
                                            <h3 class="mb-1 text-info">{{ $leadStats['new'] }}</h3>
                                            <small class="text-muted">New Leads</small>
                                        </div>
                                    </div>
                                    <div class="col-4">
                                        <div class="lead-stat-item text-center p-2 rounded border">
                                            <h5 class="mb-0 text-warning">{{ $leadStats['contacted'] }}</h5>
                                            <small class="text-muted" style="font-size: 0.7rem;">Contacted</small>
                                        </div>
                                    </div>
                                    <div class="col-4">
                                        <div class="lead-stat-item text-center p-2 rounded border">
                                            <h5 class="mb-0 text-success">{{ $leadStats['converted'] }}</h5>
                                            <small class="text-muted" style="font-size: 0.7rem;">Converted</small>
                                        </div>
                                    </div>
                                    <div class="col-4">
                                        <div class="lead-stat-item text-center p-2 rounded border">
                                            <h5 class="mb-0 text-danger">{{ $leadStats['lost'] }}</h5>
                                            <small class="text-muted" style="font-size: 0.7rem;">Lost</small>
                                        </div>
                                    </div>
                                </div>
                                @if($leadStats['total'] > 0)
                                <div class="mt-3">
                                    <small class="text-muted">Conversion Rate</small>
                                    <div class="progress progress-thin mt-1">
                                        @php
                                            $conversionRate = $leadStats['total'] > 0 
                                                ? round(($leadStats['converted'] / $leadStats['total']) * 100, 1) 
                                                : 0;
                                        @endphp
                                        <div class="progress-bar bg-success" style="width: {{ $conversionRate }}%"></div>
                                    </div>
                                    <small class="text-success fw-medium">{{ $conversionRate }}%</small>
                                </div>
                                @endif
                            </div>
                        </div>
                    </div>
                    @endif
                </div>
                
                <!-- Pending Payments Alert -->
                @if($canViewPendingBills && $pendingPayments > 0)
                <div class="alert alert-warning border-0 shadow-sm d-flex align-items-center mb-4" role="alert">
                    <i class="fas fa-exclamation-circle me-3 fa-lg"></i>
                    <div class="flex-grow-1">
                        <strong>Pending Payments:</strong> You have ₹{{ number_format($pendingPayments, 2) }} in pending payments.
                    </div>
                    <a href="{{ route('admin.pending-bills.index') }}" class="btn btn-warning btn-sm">View Details</a>
                </div>
                @endif
            </div>
            
            @include('admin.layouts.footer')
        </main>
    </div>
</div>
@endsection

@section('scripts')
<script>
    @if($canViewOrders)
    // Chart.js configuration
    const weeklyData = @json($weeklyRevenueData);
    const monthlyData = @json($monthlyRevenueData);
    const orderStatusData = @json($orderStatusData);
    
    let revenueChart;
    let currentView = 'weekly';
    
    // Initialize Revenue Chart
    function initRevenueChart(data, isWeekly = true) {
        const chartElement = document.getElementById('revenueChart');
        if (!chartElement) return;
        
        const ctx = chartElement.getContext('2d');
        
        if (revenueChart) {
            revenueChart.destroy();
        }
        
        const labels = isWeekly ? data.map(d => d.day) : data.map(d => d.short_month);
        const revenues = data.map(d => d.revenue);
        
        const gradient = ctx.createLinearGradient(0, 0, 0, 300);
        gradient.addColorStop(0, 'rgba(13, 110, 253, 0.3)');
        gradient.addColorStop(1, 'rgba(13, 110, 253, 0.01)');
        
        revenueChart = new Chart(ctx, {
            type: 'line',
            data: {
                labels: labels,
                datasets: [{
                    label: 'Revenue (₹)',
                    data: revenues,
                    borderColor: '#0d6efd',
                    backgroundColor: gradient,
                    borderWidth: 3,
                    fill: true,
                    tension: 0.4,
                    pointBackgroundColor: '#0d6efd',
                    pointBorderColor: '#fff',
                    pointBorderWidth: 2,
                    pointRadius: 5,
                    pointHoverRadius: 7
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                plugins: {
                    legend: {
                        display: false
                    },
                    tooltip: {
                        backgroundColor: 'rgba(0, 0, 0, 0.8)',
                        titleColor: '#fff',
                        bodyColor: '#fff',
                        padding: 12,
                        displayColors: false,
                        callbacks: {
                            label: function(context) {
                                return '₹' + context.parsed.y.toLocaleString('en-IN');
                            }
                        }
                    }
                },
                scales: {
                    y: {
                        beginAtZero: true,
                        grid: {
                            color: 'rgba(0, 0, 0, 0.05)'
                        },
                        ticks: {
                            callback: function(value) {
                                if (value >= 100000) {
                                    return '₹' + (value / 100000).toFixed(1) + 'L';
                                } else if (value >= 1000) {
                                    return '₹' + (value / 1000).toFixed(1) + 'K';
                                }
                                return '₹' + value;
                            }
                        }
                    },
                    x: {
                        grid: {
                            display: false
                        }
                    }
                }
            }
        });
    }
    
    // Initialize Order Status Chart
    function initOrderStatusChart() {
        const chartElement = document.getElementById('orderStatusChart');
        if (!chartElement) return;
        
        const ctx = chartElement.getContext('2d');
        
        const filteredData = orderStatusData.filter(d => d.count > 0);
        
        if (filteredData.length === 0) {
            ctx.font = '14px Arial';
            ctx.fillStyle = '#6c757d';
            ctx.textAlign = 'center';
            ctx.fillText('No order data available', ctx.canvas.width / 2, ctx.canvas.height / 2);
            return;
        }
        
        new Chart(ctx, {
            type: 'doughnut',
            data: {
                labels: filteredData.map(d => d.status),
                datasets: [{
                    data: filteredData.map(d => d.count),
                    backgroundColor: filteredData.map(d => d.color),
                    borderWidth: 0,
                    hoverOffset: 4
                }]
            },
            options: {
                responsive: true,
                maintainAspectRatio: false,
                cutout: '65%',
                plugins: {
                    legend: {
                        display: false
                    },
                    tooltip: {
                        backgroundColor: 'rgba(0, 0, 0, 0.8)',
                        padding: 12
                    }
                }
            }
        });
    }
    
    // Switch between weekly and monthly view
    function switchChart(view) {
        currentView = view;
        
        const weeklyBtn = document.getElementById('weeklyBtn');
        const monthlyBtn = document.getElementById('monthlyBtn');
        
        if (weeklyBtn) weeklyBtn.classList.toggle('active', view === 'weekly');
        if (monthlyBtn) monthlyBtn.classList.toggle('active', view === 'monthly');
        
        if (view === 'weekly') {
            initRevenueChart(weeklyData, true);
        } else {
            initRevenueChart(monthlyData, false);
        }
    }
    
    // Initialize charts on page load
    document.addEventListener('DOMContentLoaded', function() {
        initRevenueChart(weeklyData, true);
        initOrderStatusChart();
    });
    @endif
    
    // Initialize tooltips
    var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
    var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
        return new bootstrap.Tooltip(tooltipTriggerEl)
    })
</script>
@endsection

@extends('admin.layouts.app')

@section('title', 'Salary Details - ' . $user->name)

@section('content')
<div class="container-fluid h-100">
    <div class="row h-100">
        @include('admin.layouts.sidebar')
        
        <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4 main-content">
            @include('admin.layouts.header', ['pageTitle' => 'Salary Details'])
            
            <div class="pt-4 pb-2 mb-3">
                <!-- User Info Card - Enhanced Design -->
                <div class="card border-0 shadow-sm mb-4" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);">
                    <div class="card-body p-4">
                        <div class="row align-items-center">
                            <div class="col-auto">
                                <div class="position-relative">
                                    <img src="{{ $user->avatar_url }}" class="rounded-circle border border-4 border-white shadow" width="100" height="100" alt="{{ $user->name }}" style="object-fit: cover;">
                                    <span class="position-absolute bottom-0 end-0 bg-success border border-3 border-white rounded-circle" style="width: 24px; height: 24px;"></span>
                                </div>
                            </div>
                            <div class="col">
                                <h3 class="mb-1 text-white fw-bold">{{ $user->name }}</h3>
                                <p class="text-white-50 mb-2"><i class="fas fa-envelope me-2"></i>{{ $user->email }}</p>
                                <span class="badge bg-white text-dark rounded-pill px-3 py-2">
                                    <i class="fas fa-user-tag me-1"></i>{{ ucfirst(str_replace('_', ' ', $user->user_role)) }}
                                </span>
                            </div>
                            <div class="col-auto">
                                @if(auth()->user()->hasPermission('update_salary') || auth()->user()->hasPermission('create_salary') || auth()->user()->isSuperAdmin())
                                <a href="{{ route('admin.salary.create', ['user_id' => $user->id]) }}" class="btn btn-light rounded-pill px-4 shadow-sm">
                                    <i class="fas fa-edit me-2"></i> Update Salary
                                </a>
                                @endif
                                <a href="{{ route('admin.salary.index') }}" class="btn btn-outline-light rounded-pill px-4 ms-2">
                                    <i class="fas fa-arrow-left me-2"></i> Back
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
                
                <div class="row">
                    <!-- Current Salary - Enhanced Design -->
                    <div class="col-lg-6 mb-4">
                        <div class="card border-0 shadow-sm h-100">
                            <div class="card-header bg-gradient text-white py-3" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);">
                                <h5 class="card-title mb-0 fw-bold">
                                    <i class="fas fa-money-bill-wave me-2"></i>Current Salary Information
                                </h5>
                            </div>
                            <div class="card-body p-4">
                                @if($activeSalary)
                                    <!-- Salary Cards -->
                                    <div class="row g-3 mb-4">
                                        <div class="col-12">
                                            <div class="card border-0 shadow-sm" style="background: linear-gradient(135deg, #11998e 0%, #38ef7d 100%);">
                                                <div class="card-body text-center text-white p-4">
                                                    <div class="mb-2">
                                                        <i class="fas fa-rupee-sign fa-2x opacity-75"></i>
                                                    </div>
                                                    <h2 class="mb-1 fw-bold">₹{{ number_format($activeSalary->base_salary, 2) }}</h2>
                                                    <p class="mb-0 opacity-75">Monthly Salary</p>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="col-6">
                                            <div class="card border-0 bg-primary bg-opacity-10 h-100">
                                                <div class="card-body text-center p-3">
                                                    <div class="mb-2">
                                                        <i class="fas fa-calendar-day text-primary fa-lg"></i>
                                                    </div>
                                                    <h4 class="text-primary mb-1 fw-bold">₹{{ number_format($activeSalary->daily_rate, 2) }}</h4>
                                                    <small class="text-muted">Daily Rate</small>
                                                </div>
                                            </div>
                                        </div>
                                        <div class="col-6">
                                            <div class="card border-0 bg-warning bg-opacity-10 h-100">
                                                <div class="card-body text-center p-3">
                                                    <div class="mb-2">
                                                        <i class="fas fa-clock text-warning fa-lg"></i>
                                                    </div>
                                                    <h4 class="text-warning mb-1 fw-bold">₹{{ number_format($activeSalary->half_day_rate, 2) }}</h4>
                                                    <small class="text-muted">Half Day Rate</small>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    
                                    <!-- Details Table -->
                                    <div class="table-responsive">
                                        <table class="table table-borderless mb-0">
                                            <tbody>
                                                <tr class="border-bottom">
                                                    <td class="py-3">
                                                        <i class="fas fa-calendar-check text-primary me-2"></i>
                                                        <span class="text-muted">Working Days/Month</span>
                                                    </td>
                                                    <td class="py-3 text-end">
                                                        <span class="badge bg-primary-subtle text-primary-emphasis rounded-pill px-3">
                                                            {{ $activeSalary->working_days_per_month }} days
                                                        </span>
                                                    </td>
                                                </tr>
                                                <tr class="border-bottom">
                                                    <td class="py-3">
                                                        <i class="fas fa-calendar-alt text-success me-2"></i>
                                                        <span class="text-muted">Effective From</span>
                                                    </td>
                                                    <td class="py-3 text-end fw-medium">
                                                        {{ $activeSalary->effective_from->format('d M Y') }}
                                                    </td>
                                                </tr>
                                                <tr class="border-bottom">
                                                    <td class="py-3">
                                                        <i class="fas fa-check-circle text-success me-2"></i>
                                                        <span class="text-muted">Status</span>
                                                    </td>
                                                    <td class="py-3 text-end">
                                                        <span class="badge bg-success rounded-pill px-3">
                                                            <i class="fas fa-circle-notch fa-spin me-1"></i>Active
                                                        </span>
                                                    </td>
                                                </tr>
                                                @if($activeSalary->notes)
                                                <tr>
                                                    <td class="py-3" colspan="2">
                                                        <div class="alert alert-info mb-0 rounded-3">
                                                            <i class="fas fa-info-circle me-2"></i>
                                                            <strong>Notes:</strong> {{ $activeSalary->notes }}
                                                        </div>
                                                    </td>
                                                </tr>
                                                @endif
                                            </tbody>
                                        </table>
                                    </div>
                                @else
                                    <div class="text-center py-5">
                                        <div class="mb-4">
                                            <i class="fas fa-exclamation-circle fa-4x text-warning opacity-50"></i>
                                        </div>
                                        <h5 class="fw-bold mb-2">No Active Salary</h5>
                                        <p class="text-muted mb-4">Salary has not been set for this staff member.</p>
                                        @if(auth()->user()->hasPermission('create_salary') || auth()->user()->isSuperAdmin())
                                        <a href="{{ route('admin.salary.create', ['user_id' => $user->id]) }}" class="btn btn-theme rounded-pill px-4">
                                            <i class="fas fa-plus me-2"></i> Set Salary
                                        </a>
                                        @endif
                                    </div>
                                @endif
                            </div>
                        </div>
                    </div>
                    
                    <!-- Salary History - Enhanced Design -->
                    <div class="col-lg-6 mb-4">
                        <div class="card border-0 shadow-sm h-100">
                            <div class="card-header bg-gradient text-white py-3" style="background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);">
                                <h5 class="card-title mb-0 fw-bold">
                                    <i class="fas fa-history me-2"></i>Salary History Timeline
                                </h5>
                            </div>
                            <div class="card-body p-4" style="max-height: 600px; overflow-y: auto;">
                                @if($salaryHistory->count() > 0)
                                    <div class="timeline position-relative">
                                        @foreach($salaryHistory as $index => $salary)
                                        <div class="timeline-item position-relative ps-4 pb-4 {{ !$loop->last ? 'border-start border-3' : '' }} {{ $salary->is_active ? 'border-success' : 'border-secondary' }}">
                                            <!-- Timeline Dot -->
                                            <div class="position-absolute bg-white" style="left: -10px; top: 0;">
                                                <div class="rounded-circle {{ $salary->is_active ? 'bg-success' : 'bg-secondary' }} d-flex align-items-center justify-content-center" style="width: 20px; height: 20px;">
                                                    <i class="fas {{ $salary->is_active ? 'fa-check' : 'fa-circle' }} text-white" style="font-size: 10px;"></i>
                                                </div>
                                            </div>
                                            
                                            <!-- Timeline Content -->
                                            <div class="card border-0 {{ $salary->is_active ? 'shadow-sm' : 'bg-light' }} mb-3">
                                                <div class="card-body p-3">
                                                    <div class="d-flex justify-content-between align-items-start mb-2">
                                                        <div>
                                                            <h5 class="mb-1 {{ $salary->is_active ? 'text-success' : 'text-muted' }} fw-bold">
                                                                ₹{{ number_format($salary->base_salary, 2) }}
                                                            </h5>
                                                            <small class="text-muted">per month</small>
                                                        </div>
                                                        @if($salary->is_active)
                                                            <span class="badge bg-success rounded-pill px-3">
                                                                <i class="fas fa-star me-1"></i>Current
                                                            </span>
                                                        @else
                                                            <span class="badge bg-secondary rounded-pill px-3">Inactive</span>
                                                        @endif
                                                    </div>
                                                    
                                                    <div class="small mb-2">
                                                        <div class="d-flex align-items-center mb-1">
                                                            <i class="fas fa-calendar-alt text-primary me-2" style="width: 16px;"></i>
                                                            <span class="text-muted">From:</span>
                                                            <span class="ms-2 fw-medium">{{ $salary->effective_from->format('d M Y') }}</span>
                                                        </div>
                                                        <div class="d-flex align-items-center mb-1">
                                                            <i class="fas fa-calendar-times text-danger me-2" style="width: 16px;"></i>
                                                            <span class="text-muted">To:</span>
                                                            <span class="ms-2 fw-medium">
                                                                @if($salary->effective_to)
                                                                    {{ $salary->effective_to->format('d M Y') }}
                                                                @else
                                                                    <span class="text-success">Present</span>
                                                                @endif
                                                            </span>
                                                        </div>
                                                    </div>
                                                    
                                                    <div class="d-flex gap-3 small text-muted border-top pt-2 mt-2">
                                                        <div>
                                                            <i class="fas fa-sun text-warning me-1"></i>
                                                            Daily: <strong>₹{{ number_format($salary->daily_rate, 2) }}</strong>
                                                        </div>
                                                        <div>
                                                            <i class="fas fa-adjust text-info me-1"></i>
                                                            Half: <strong>₹{{ number_format($salary->half_day_rate, 2) }}</strong>
                                                        </div>
                                                    </div>
                                                    
                                                    @if($salary->notes)
                                                        <div class="alert alert-light border-0 mt-2 mb-0 small">
                                                            <i class="fas fa-sticky-note text-warning me-1"></i>
                                                            {{ $salary->notes }}
                                                        </div>
                                                    @endif
                                                    
                                                    <!-- Calculate percentage change from previous -->
                                                    @if($index < $salaryHistory->count() - 1)
                                                        @php
                                                            $previousSalary = $salaryHistory[$index + 1];
                                                            $percentageChange = (($salary->base_salary - $previousSalary->base_salary) / $previousSalary->base_salary) * 100;
                                                        @endphp
                                                        @if($percentageChange != 0)
                                                        <div class="mt-2 pt-2 border-top">
                                                            <small>
                                                                @if($percentageChange > 0)
                                                                    <span class="badge bg-success-subtle text-success-emphasis">
                                                                        <i class="fas fa-arrow-up me-1"></i>
                                                                        {{ number_format($percentageChange, 2) }}% Hike
                                                                    </span>
                                                                @else
                                                                    <span class="badge bg-danger-subtle text-danger-emphasis">
                                                                        <i class="fas fa-arrow-down me-1"></i>
                                                                        {{ number_format(abs($percentageChange), 2) }}% Decrease
                                                                    </span>
                                                                @endif
                                                                <span class="text-muted ms-2">from ₹{{ number_format($previousSalary->base_salary, 2) }}</span>
                                                            </small>
                                                        </div>
                                                        @endif
                                                    @endif
                                                </div>
                                            </div>
                                        </div>
                                        @endforeach
                                    </div>
                                @else
                                    <div class="text-center py-5">
                                        <div class="mb-4">
                                            <i class="fas fa-history fa-4x text-muted opacity-25"></i>
                                        </div>
                                        <h6 class="text-muted mb-1">No salary history available</h6>
                                        <small class="text-muted">History will appear once salary is set</small>
                                    </div>
                                @endif
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

@section('styles')
<style>
    .timeline-item:last-child {
        border-left: none !important;
    }
</style>
@endsection

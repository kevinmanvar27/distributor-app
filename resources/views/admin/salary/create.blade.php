@extends('admin.layouts.app')

@section('title', 'Set/Update Salary')

@section('content')
<div class="container-fluid h-100">
    <div class="row h-100">
        @include('admin.layouts.sidebar')
        
        <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4 main-content">
            @include('admin.layouts.header', ['pageTitle' => 'Set/Update Salary'])
            
            <div class="pt-4 pb-2 mb-3">
                <div class="row">
                    <div class="col-lg-8">
                        <div class="card border-0 shadow-sm">
                            <div class="card-header bg-gradient text-white border-0 py-3" style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);">
                                <div class="d-flex justify-content-between align-items-center">
                                    <div>
                                        <h4 class="card-title mb-0 fw-bold text-white">
                                            <i class="fas fa-money-bill-wave me-2"></i>
                                            {{ $user ? 'Update Salary for ' . $user->name : 'Set New Salary' }}
                                        </h4>
                                        <p class="text-white-50 mb-0 mt-1 small">Configure salary rates and working days</p>
                                    </div>
                                    <a href="{{ route('admin.salary.index') }}" class="btn btn-light rounded-pill px-4">
                                        <i class="fas fa-arrow-left me-2"></i> Back
                                    </a>
                                </div>
                            </div>
                            
                            <div class="card-body p-4">
                                @if(session('success'))
                                    <div class="alert alert-success alert-dismissible fade show rounded-3 px-4 py-3" role="alert">
                                        <i class="fas fa-check-circle me-2"></i>{{ session('success') }}
                                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                                    </div>
                                @endif
                                
                                @if($errors->any())
                                    <div class="alert alert-danger alert-dismissible fade show rounded-3" role="alert">
                                        <ul class="mb-0">
                                            @foreach($errors->all() as $error)
                                                <li>{{ $error }}</li>
                                            @endforeach
                                        </ul>
                                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                                    </div>
                                @endif
                                
                                @if(!(auth()->user()->hasPermission('create_salary') || auth()->user()->hasPermission('update_salary') || auth()->user()->isSuperAdmin()))
                                    <div class="alert alert-warning rounded-3">
                                        <i class="fas fa-exclamation-triangle me-2"></i>You don't have permission to set or update salary.
                                    </div>
                                @else
                                <form method="POST" action="{{ route('admin.salary.store') }}">
                                    @csrf
                                    
                                    <!-- User Selection -->
                                    <div class="mb-4">
                                        <label class="form-label fw-medium">
                                            <i class="fas fa-user me-2 text-primary"></i>Select Staff Member 
                                            <span class="text-danger">*</span>
                                        </label>
                                        <select class="form-select form-select-lg" name="user_id" id="userSelect" required onchange="loadCurrentSalary(this.value)">
                                            <option value="">-- Select Staff Member --</option>
                                            @foreach($staffUsers as $staffUser)
                                                <option value="{{ $staffUser->id }}" 
                                                        data-current-salary="{{ $staffUser->salaries->first()->base_salary ?? 0 }}"
                                                        {{ $user && $user->id == $staffUser->id ? 'selected' : '' }}>
                                                    {{ $staffUser->name }} ({{ ucfirst(str_replace('_', ' ', $staffUser->user_role)) }})
                                                </option>
                                            @endforeach
                                        </select>
                                    </div>
                                    
                                    <!-- Current Salary Display -->
                                    <div id="currentSalaryDisplay" class="mb-4" style="display: {{ $user && $salaryHistory->count() > 0 ? 'block' : 'none' }};">
                                        <div class="card border-0 bg-light">
                                            <div class="card-body p-3">
                                                <div class="row align-items-center">
                                                    <div class="col-auto">
                                                        <div class="bg-primary bg-opacity-10 rounded-circle d-flex align-items-center justify-content-center" style="width: 50px; height: 50px;">
                                                            <i class="fas fa-rupee-sign text-primary fa-lg"></i>
                                                        </div>
                                                    </div>
                                                    <div class="col">
                                                        <small class="text-muted d-block mb-1">Current Monthly Salary</small>
                                                        <h4 class="mb-0 text-primary fw-bold" id="currentSalaryAmount">
                                                            @if($user && $salaryHistory->count() > 0)
                                                                ₹{{ number_format($salaryHistory->first()->base_salary, 2) }}
                                                            @endif
                                                        </h4>
                                                    </div>
                                                    <div class="col-auto">
                                                        <span class="badge bg-success-subtle text-success-emphasis px-3 py-2">
                                                            <i class="fas fa-check-circle me-1"></i>Active
                                                        </span>
                                                    </div>
                                                </div>
                                            </div>
                                        </div>
                                    </div>
                                    
                                    <!-- New Salary Input -->
                                    <div class="row">
                                        <div class="col-md-6 mb-4">
                                            <label class="form-label fw-medium">
                                                <i class="fas fa-money-bill-wave me-2 text-success"></i>New Base Salary (Monthly) 
                                                <span class="text-danger">*</span>
                                            </label>
                                            <div class="input-group input-group-lg">
                                                <span class="input-group-text bg-success text-white">₹</span>
                                                <input type="number" class="form-control" name="base_salary" id="baseSalary" 
                                                       step="0.01" min="0" required placeholder="Enter new monthly salary"
                                                       onchange="calculateRates()" oninput="calculateHike()">
                                            </div>
                                            <!-- Hike Percentage Display -->
                                            <div id="hikeDisplay" class="mt-2" style="display: none;">
                                                <div class="alert mb-0 py-2 px-3" id="hikeAlert">
                                                    <small>
                                                        <i class="fas fa-chart-line me-1"></i>
                                                        <strong>Salary Change:</strong>
                                                        <span id="hikePercentage"></span>
                                                        <span id="hikeAmount" class="ms-2"></span>
                                                    </small>
                                                </div>
                                            </div>
                                        </div>
                                        
                                        <div class="col-md-6 mb-4">
                                            <label class="form-label fw-medium">
                                                <i class="fas fa-calendar-check me-2 text-info"></i>Working Days per Month 
                                                <span class="text-danger">*</span>
                                            </label>
                                            <input type="number" class="form-control form-control-lg" name="working_days_per_month" id="workingDays" 
                                                   min="1" max="31" value="26" required onchange="calculateRates()">
                                            <small class="text-muted">
                                                <i class="fas fa-info-circle me-1"></i>Standard is 26 days (excluding Sundays)
                                            </small>
                                        </div>
                                    </div>
                                    
                                    <!-- Auto-calculated Rates -->
                                    <div class="row">
                                        <div class="col-md-6 mb-4">
                                            <label class="form-label fw-medium">
                                                <i class="fas fa-sun me-2 text-warning"></i>Daily Rate (Auto-calculated)
                                            </label>
                                            <div class="input-group input-group-lg">
                                                <span class="input-group-text bg-warning text-white">₹</span>
                                                <input type="text" class="form-control bg-light" id="dailyRateDisplay" readonly>
                                            </div>
                                            <small class="text-muted">
                                                <i class="fas fa-calculator me-1"></i>Base Salary ÷ Working Days
                                            </small>
                                        </div>
                                        
                                        <div class="col-md-6 mb-4">
                                            <label class="form-label fw-medium">
                                                <i class="fas fa-adjust me-2 text-secondary"></i>Half Day Rate (Auto-calculated)
                                            </label>
                                            <div class="input-group input-group-lg">
                                                <span class="input-group-text bg-secondary text-white">₹</span>
                                                <input type="text" class="form-control bg-light" id="halfDayRateDisplay" readonly>
                                            </div>
                                            <small class="text-muted">
                                                <i class="fas fa-calculator me-1"></i>Daily Rate ÷ 2
                                            </small>
                                        </div>
                                    </div>
                                    
                                    <!-- Effective Date -->
                                    <div class="mb-4">
                                        <label class="form-label fw-medium">
                                            <i class="fas fa-calendar-alt me-2 text-danger"></i>Effective From 
                                            <span class="text-danger">*</span>
                                        </label>
                                        <input type="date" class="form-control form-control-lg" name="effective_from" required 
                                               value="{{ old('effective_from', date('Y-m-d')) }}">
                                        <small class="text-muted">
                                            <i class="fas fa-info-circle me-1"></i>The date from which this salary will be applicable. Previous salary will be marked as inactive.
                                        </small>
                                    </div>
                                    
                                    <!-- Notes -->
                                    <div class="mb-4">
                                        <label class="form-label fw-medium">
                                            <i class="fas fa-sticky-note me-2 text-warning"></i>Notes
                                        </label>
                                        <textarea class="form-control" name="notes" rows="3" placeholder="Optional notes about this salary change (e.g., Annual increment, Promotion, Performance bonus)...">{{ old('notes') }}</textarea>
                                    </div>
                                    
                                    <!-- Info Alert -->
                                    <div class="alert alert-info rounded-3 border-0">
                                        <div class="d-flex">
                                            <div class="flex-shrink-0">
                                                <i class="fas fa-info-circle fa-2x text-info"></i>
                                            </div>
                                            <div class="flex-grow-1 ms-3">
                                                <h6 class="alert-heading mb-2">Important Information</h6>
                                                <p class="mb-0 small">
                                                    When you update the salary, the new rates will apply from the effective date. 
                                                    Salary calculations for days before the effective date will use the previous rates, 
                                                    and days after will use the new rates.
                                                </p>
                                            </div>
                                        </div>
                                    </div>
                                    
                                    <!-- Submit Button -->
                                    <div class="text-end">
                                        <button type="submit" class="btn btn-lg btn-theme rounded-pill px-5 shadow">
                                            <i class="fas fa-save me-2"></i> Save Salary
                                        </button>
                                    </div>
                                </form>
                                @endif
                            </div>
                        </div>
                    </div>
                    
                    <!-- Salary History Sidebar -->
                    <div class="col-lg-4">
                        <div class="card border-0 shadow-sm sticky-top" style="top: 20px;">
                            <div class="card-header bg-gradient text-white border-0 py-3" style="background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);">
                                <h5 class="card-title mb-0 fw-bold text-white">
                                    <i class="fas fa-history me-2"></i>Salary History
                                </h5>
                            </div>
                            <div class="card-body p-3" id="salaryHistoryContainer" style="max-height: 600px; overflow-y: auto;">
                                @if($salaryHistory->count() > 0)
                                    @foreach($salaryHistory as $index => $salary)
                                    <div class="card border-0 mb-3 {{ $salary->is_active ? 'shadow-sm bg-success bg-opacity-10' : 'bg-light' }}">
                                        <div class="card-body p-3">
                                            <div class="d-flex justify-content-between align-items-start mb-2">
                                                <div>
                                                    <h5 class="mb-0 {{ $salary->is_active ? 'text-success' : 'text-muted' }} fw-bold">
                                                        ₹{{ number_format($salary->base_salary, 2) }}
                                                    </h5>
                                                    <small class="text-muted">per month</small>
                                                </div>
                                                @if($salary->is_active)
                                                    <span class="badge bg-success rounded-pill">
                                                        <i class="fas fa-check me-1"></i>Active
                                                    </span>
                                                @else
                                                    <span class="badge bg-secondary rounded-pill">Inactive</span>
                                                @endif
                                            </div>
                                            
                                            <div class="small text-muted mb-2">
                                                <div class="mb-1">
                                                    <i class="fas fa-calendar-alt me-1"></i> 
                                                    From: <strong>{{ $salary->effective_from->format('d M Y') }}</strong>
                                                </div>
                                                @if($salary->effective_to)
                                                    <div class="mb-1">
                                                        <i class="fas fa-calendar-times me-1"></i> 
                                                        To: <strong>{{ $salary->effective_to->format('d M Y') }}</strong>
                                                    </div>
                                                @endif
                                            </div>
                                            
                                            <div class="d-flex gap-2 small border-top pt-2">
                                                <span class="badge bg-warning-subtle text-warning-emphasis">
                                                    <i class="fas fa-sun me-1"></i>₹{{ number_format($salary->daily_rate, 2) }}/day
                                                </span>
                                                <span class="badge bg-info-subtle text-info-emphasis">
                                                    <i class="fas fa-adjust me-1"></i>₹{{ number_format($salary->half_day_rate, 2) }}/half
                                                </span>
                                            </div>
                                            
                                            @if($salary->notes)
                                                <div class="small text-muted mt-2 pt-2 border-top">
                                                    <i class="fas fa-sticky-note me-1"></i> {{ Str::limit($salary->notes, 50) }}
                                                </div>
                                            @endif
                                            
                                            <!-- Show percentage change -->
                                            @if($index < $salaryHistory->count() - 1)
                                                @php
                                                    $previousSalary = $salaryHistory[$index + 1];
                                                    $percentageChange = (($salary->base_salary - $previousSalary->base_salary) / $previousSalary->base_salary) * 100;
                                                @endphp
                                                @if($percentageChange != 0)
                                                <div class="mt-2 pt-2 border-top">
                                                    @if($percentageChange > 0)
                                                        <span class="badge bg-success-subtle text-success-emphasis w-100">
                                                            <i class="fas fa-arrow-up me-1"></i>
                                                            {{ number_format($percentageChange, 2) }}% Hike
                                                        </span>
                                                    @else
                                                        <span class="badge bg-danger-subtle text-danger-emphasis w-100">
                                                            <i class="fas fa-arrow-down me-1"></i>
                                                            {{ number_format(abs($percentageChange), 2) }}% Decrease
                                                        </span>
                                                    @endif
                                                </div>
                                                @endif
                                            @endif
                                        </div>
                                    </div>
                                    @endforeach
                                @else
                                    <div class="text-center text-muted py-5">
                                        <i class="fas fa-history fa-3x mb-3 opacity-25"></i>
                                        <p class="mb-0 fw-medium">No salary history</p>
                                        <small>Select a staff member to view history</small>
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

@section('scripts')
<script>
    let currentSalary = {{ $user && $salaryHistory->count() > 0 ? $salaryHistory->first()->base_salary : 0 }};
    
    function calculateRates() {
        const baseSalary = parseFloat(document.getElementById('baseSalary').value) || 0;
        const workingDays = parseInt(document.getElementById('workingDays').value) || 26;
        
        const dailyRate = baseSalary / workingDays;
        const halfDayRate = dailyRate / 2;
        
        document.getElementById('dailyRateDisplay').value = dailyRate.toFixed(2);
        document.getElementById('halfDayRateDisplay').value = halfDayRate.toFixed(2);
        
        calculateHike();
    }
    
    function calculateHike() {
        const newSalary = parseFloat(document.getElementById('baseSalary').value) || 0;
        const hikeDisplay = document.getElementById('hikeDisplay');
        const hikeAlert = document.getElementById('hikeAlert');
        const hikePercentage = document.getElementById('hikePercentage');
        const hikeAmount = document.getElementById('hikeAmount');
        
        if (currentSalary > 0 && newSalary > 0) {
            const difference = newSalary - currentSalary;
            const percentageChange = (difference / currentSalary) * 100;
            
            hikeDisplay.style.display = 'block';
            
            if (percentageChange > 0) {
                hikeAlert.className = 'alert alert-success mb-0 py-2 px-3';
                hikePercentage.innerHTML = '<span class="badge bg-success"><i class="fas fa-arrow-up me-1"></i>' + 
                    percentageChange.toFixed(2) + '% Hike</span>';
                hikeAmount.innerHTML = '<span class="text-success">(+₹' + 
                    difference.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",") + ')</span>';
            } else if (percentageChange < 0) {
                hikeAlert.className = 'alert alert-danger mb-0 py-2 px-3';
                hikePercentage.innerHTML = '<span class="badge bg-danger"><i class="fas fa-arrow-down me-1"></i>' + 
                    Math.abs(percentageChange).toFixed(2) + '% Decrease</span>';
                hikeAmount.innerHTML = '<span class="text-danger">(-₹' + 
                    Math.abs(difference).toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",") + ')</span>';
            } else {
                hikeAlert.className = 'alert alert-info mb-0 py-2 px-3';
                hikePercentage.innerHTML = '<span class="badge bg-info">No Change</span>';
                hikeAmount.innerHTML = '';
            }
        } else {
            hikeDisplay.style.display = 'none';
        }
    }
    
    function loadCurrentSalary(userId) {
        if (userId) {
            // Get current salary from data attribute
            const select = document.getElementById('userSelect');
            const selectedOption = select.options[select.selectedIndex];
            const salary = parseFloat(selectedOption.getAttribute('data-current-salary')) || 0;
            
            currentSalary = salary;
            
            const currentSalaryDisplay = document.getElementById('currentSalaryDisplay');
            const currentSalaryAmount = document.getElementById('currentSalaryAmount');
            
            if (salary > 0) {
                currentSalaryDisplay.style.display = 'block';
                currentSalaryAmount.textContent = '₹' + salary.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",");
            } else {
                currentSalaryDisplay.style.display = 'none';
            }
            
            // Reload page to show history
            window.location.href = `{{ route('admin.salary.create') }}?user_id=${userId}`;
        }
    }
    
    // Initialize on page load
    document.addEventListener('DOMContentLoaded', function() {
        calculateRates();
        
        // Set current salary from selected user
        const userSelect = document.getElementById('userSelect');
        if (userSelect.value) {
            const selectedOption = userSelect.options[userSelect.selectedIndex];
            currentSalary = parseFloat(selectedOption.getAttribute('data-current-salary')) || 0;
        }
    });
</script>
@endsection

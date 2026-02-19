@extends('admin.layouts.app')

@section('title', 'My Tasks')

@section('content')
<div class="container-fluid h-100">
    <div class="row h-100">
        @include('admin.layouts.sidebar')
        
        <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4 main-content">
            @include('admin.layouts.header', ['pageTitle' => 'My Tasks'])
            
            <div class="pt-4 pb-2 mb-3">
                <!-- Statistics Cards -->
                <div class="row mb-4">
                    <div class="col-md-3">
                        <div class="card border-0 shadow-sm">
                            <div class="card-body text-center">
                                <h6 class="text-muted mb-1">Total</h6>
                                <h3 class="mb-0">{{ $stats['total'] ?? 0 }}</h3>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card border-0 shadow-sm bg-warning text-white">
                            <div class="card-body text-center">
                                <h6 class="text-muted mb-1">Pending</h6>
                                <h3 class="mb-0">{{ $stats['pending'] ?? 0 }}</h3>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card border-0 shadow-sm bg-info text-white">
                            <div class="card-body text-center">
                                <h6 class="text-muted mb-1">In Progress</h6>
                                <h3 class="mb-0">{{ $stats['in_progress'] ?? 0 }}</h3>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-3">
                        <div class="card border-0 shadow-sm bg-success">
                            <div class="card-body text-center">
                                <h6 class="text-muted mb-1">Completed</h6>
                                <h3 class="mb-0 text-success">{{ $stats['done'] ?? 0 }}</h3>
                            </div>
                        </div>
                    </div>
                </div>

                <!-- Tasks Table -->
                <div class="card border-0 shadow-sm">
                    <div class="card-header bg-white border-0 py-3">
                        <h4 class="card-title mb-0 fw-bold">
                            <i class="fas fa-tasks me-2"></i>My Tasks
                        </h4>
                    </div>
                    <div class="card-body">
                        @if(session('success'))
                            <div class="alert-theme alert-success alert-dismissible fade show rounded-pill px-4 py-3" role="alert">
                                <i class="fas fa-check-circle me-2"></i>{{ session('success') }}
                                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                            </div>
                        @endif

                        <!-- Filter Tabs -->
                        <ul class="nav nav-pills mb-3" role="tablist">
                            <li class="nav-item" role="presentation">
                                <a class="nav-link {{ request('status') == '' ? 'active' : '' }}" 
                                   href="{{ route('staff.tasks.index') }}">
                                    All Tasks
                                </a>
                            </li>
                            <li class="nav-item" role="presentation">
                                <a class="nav-link {{ request('status') == 'pending' ? 'active' : '' }}" 
                                   href="{{ route('staff.tasks.index', ['status' => 'pending']) }}">
                                    Pending
                                </a>
                            </li>
                            <li class="nav-item" role="presentation">
                                <a class="nav-link {{ request('status') == 'in_progress' ? 'active' : '' }}" 
                                   href="{{ route('staff.tasks.index', ['status' => 'in_progress']) }}">
                                    In Progress
                                </a>
                            </li>
                            <li class="nav-item" role="presentation">
                                <a class="nav-link {{ request('status') == 'done' ? 'active' : '' }}" 
                                   href="{{ route('staff.tasks.index', ['status' => 'done']) }}">
                                    Done
                                </a>
                            </li>
                            <li class="nav-item" role="presentation">
                                <a class="nav-link {{ request('status') == 'verified' ? 'active' : '' }}" 
                                   href="{{ route('staff.tasks.index', ['status' => 'verified']) }}">
                                    Verified
                                </a>
                            </li>
                        </ul>

                        <div class="table-responsive">
                            <table class="table table-hover">
                                <thead>
                                    <tr>
                                        <th>Task</th>
                                        <th>Assigned By</th>
                                        <th>Status</th>
                                        <th>Created</th>
                                        <th>Actions</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    @forelse($tasks as $task)
                                        <tr>
                                            <td>
                                                <strong>{{ $task->title }}</strong>
                                                @if($task->attachment)
                                                    <i class="fas fa-paperclip text-muted ms-1"></i>
                                                @endif
                                            </td>
                                            <td>{{ $task->assignedBy->name ?? 'N/A' }}</td>
                                            <td>
                                                @php
                                                    $statusColors = [
                                                        'pending' => 'warning',
                                                        'in_progress' => 'info',
                                                        'question' => 'danger',
                                                        'done' => 'secondary',
                                                        'verified' => 'success'
                                                    ];
                                                    $statusColor = $statusColors[$task->status] ?? 'secondary';
                                                @endphp
                                                <span class="badge bg-{{ $statusColor }} rounded-pill">
                                                    {{ ucwords(str_replace('_', ' ', $task->status)) }}
                                                </span>
                                            </td>
                                            <td>{{ $task->created_at->format('M d, Y') }}</td>
                                            <td>
                                                <a href="{{ route('staff.tasks.show', $task->id) }}" 
                                                   class="btn btn-sm btn-outline-primary rounded-pill">
                                                    <i class="fas fa-eye me-1"></i>View
                                                </a>
                                            </td>
                                        </tr>
                                    @empty
                                        <tr>
                                            <td colspan="5" class="text-center py-4">
                                                <i class="fas fa-inbox fa-3x text-muted mb-3 d-block"></i>
                                                <p class="text-muted">No tasks found</p>
                                            </td>
                                        </tr>
                                    @endforelse
                                </tbody>
                            </table>
                        </div>

                        <!-- Pagination -->
                        @if($tasks->hasPages())
                            <div class="d-flex justify-content-center mt-4">
                                {{ $tasks->links() }}
                            </div>
                        @endif
                    </div>
                </div>
            </div>
        </main>
    </div>
</div>
@endsection

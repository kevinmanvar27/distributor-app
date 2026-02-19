@extends('admin.layouts.app')

@section('title', 'Tasks Management')

@section('content')
<div class="container-fluid h-100">
    <div class="row h-100">
        @include('admin.layouts.sidebar')
        
        <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4 main-content">
            @include('admin.layouts.header', ['pageTitle' => 'Tasks Management'])
            
            <div class="pt-4 pb-2 mb-3">
                <!-- Statistics Cards -->
                <div class="row mb-4">
                    <div class="col-md-2">
                        <div class="card border-0 shadow-sm">
                            <div class="card-body text-center">
                                <h6 class="text-muted mb-1">Total</h6>
                                <h3 class="mb-0">{{ $stats['total'] ?? 0 }}</h3>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-2">
                        <div class="card border-0 shadow-sm bg-warning">
                            <div class="card-body text-center">
                                <h6 class="text-white mb-1">Pending</h6>
                                <h3 class="mb-0 text-white">{{ $stats['pending'] ?? 0 }}</h3>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-2">
                        <div class="card border-0 shadow-sm bg-info">
                            <div class="card-body text-center">
                                <h6 class="text-white mb-1">In Progress</h6>
                                <h3 class="mb-0 text-white">{{ $stats['in_progress'] ?? 0 }}</h3>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-2">
                        <div class="card border-0 shadow-sm bg-danger">
                            <div class="card-body text-center">
                                <h6 class="text-white mb-1">Questions</h6>
                                <h3 class="mb-0 text-white">{{ $stats['with_questions'] ?? 0 }}</h3>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-2">
                        <div class="card border-0 shadow-sm bg-success">
                            <div class="card-body text-center">
                                <h6 class="text-white mb-1">Done</h6>
                                <h3 class="mb-0 text-white">{{ $stats['done'] ?? 0 }}</h3>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-2">
                        <div class="card border-0 shadow-sm bg-primary">
                            <div class="card-body text-center">
                                <h6 class="text-white mb-1">Verified</h6>
                                <h3 class="mb-0 text-white">{{ $stats['verified'] ?? 0 }}</h3>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="row">
                    <div class="col-12">
                        <div class="card border-0 shadow-sm">
                            <div class="card-header bg-white border-0 py-3">
                                <div class="d-flex flex-column flex-md-row justify-content-between align-items-start align-items-md-center gap-2 gap-md-0">
                                    <div class="mb-2 mb-md-0">
                                        <h4 class="card-title mb-0 fw-bold h5 h4-md">Tasks Management</h4>
                                        <p class="mb-0 text-muted small">Manage and assign tasks to staff members</p>
                                    </div>
                                    @if(auth()->user()->hasPermission('manage_tasks'))
                                    <a href="{{ route('admin.tasks.create') }}" class="btn btn-sm btn-md-normal btn-theme rounded-pill px-3 px-md-4">
                                        <i class="fas fa-plus me-1 me-md-2"></i><span class="d-none d-sm-inline">Create New Task</span><span class="d-sm-none">Create</span>
                                    </a>
                                    @endif
                                </div>
                            </div>
                            
                            <div class="card-body">
                                @if(session('success'))
                                    <div class="alert-theme alert-success alert-dismissible fade show rounded-pill px-4 py-3" role="alert">
                                        <i class="fas fa-check-circle me-2"></i>{{ session('success') }}
                                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                                    </div>
                                @endif
                                
                                @if(session('error'))
                                    <div class="alert-theme alert-danger alert-dismissible fade show rounded-pill px-4 py-3" role="alert">
                                        <i class="fas fa-exclamation-circle me-2"></i>{{ session('error') }}
                                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                                    </div>
                                @endif

                                <!-- Filters -->
                                <form method="GET" action="{{ route('admin.tasks.index') }}" class="mb-4">
                                    <div class="row g-3">
                                        <div class="col-md-4">
                                            <select name="status" class="form-select">
                                                <option value="">All Statuses</option>
                                                @foreach($statuses as $key => $label)
                                                    <option value="{{ $key }}" {{ request('status') == $key ? 'selected' : '' }}>{{ $label }}</option>
                                                @endforeach
                                            </select>
                                        </div>
                                        <div class="col-md-4">
                                            <select name="assigned_to" class="form-select">
                                                <option value="">All Staff</option>
                                                @foreach($staff as $member)
                                                    <option value="{{ $member->id }}" {{ request('assigned_to') == $member->id ? 'selected' : '' }}>{{ $member->name }}</option>
                                                @endforeach
                                            </select>
                                        </div>
                                        <div class="col-md-4">
                                            <div class="input-group">
                                                <input type="text" name="search" class="form-control" placeholder="Search tasks..." value="{{ request('search') }}">
                                                <button type="submit" class="btn btn-theme">
                                                    <i class="fas fa-search"></i>
                                                </button>
                                            </div>
                                        </div>
                                    </div>
                                </form>
                                
                                <div class="table-responsive">
                                    <table class="table table-hover align-middle">
                                        <thead class="table-light">
                                            <tr>
                                                <th>#</th>
                                                <th>Title</th>
                                                <th>Assigned To</th>
                                                <th>Status</th>
                                                <th>Created</th>
                                                <th>Actions</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            @forelse($tasks as $task)
                                                <tr>
                                                    <td>{{ $task->id }}</td>
                                                    <td>
                                                        <strong>{{ $task->title }}</strong>
                                                        @if($task->attachment)
                                                            <i class="fas fa-paperclip text-muted ms-1"></i>
                                                        @endif
                                                    </td>
                                                    <td>{{ $task->assignedTo->name ?? 'N/A' }}</td>
                                                    <td>
                                                        <span class="badge bg-{{ $task->status_color }}">{{ $task->status_label }}</span>
                                                    </td>
                                                    <td>{{ $task->created_at->format('M d, Y') }}</td>
                                                    <td>
                                                        <a href="{{ route('admin.tasks.show', $task->id) }}" class="btn btn-sm btn-info" title="View">
                                                            <i class="fas fa-eye"></i>
                                                        </a>
                                                        @if(auth()->user()->hasPermission('manage_tasks'))
                                                        <a href="{{ route('admin.tasks.edit', $task->id) }}" class="btn btn-sm btn-warning" title="Edit">
                                                            <i class="fas fa-edit"></i>
                                                        </a>
                                                        <form action="{{ route('admin.tasks.destroy', $task->id) }}" method="POST" class="d-inline" onsubmit="return confirm('Are you sure you want to delete this task?');">
                                                            @csrf
                                                            @method('DELETE')
                                                            <button type="submit" class="btn btn-sm btn-danger" title="Delete">
                                                                <i class="fas fa-trash"></i>
                                                            </button>
                                                        </form>
                                                        @endif
                                                    </td>
                                                </tr>
                                            @empty
                                                <tr>
                                                    <td colspan="6" class="text-center py-4">
                                                        <i class="fas fa-tasks fa-3x text-muted mb-3"></i>
                                                        <p class="text-muted">No tasks found</p>
                                                    </td>
                                                </tr>
                                            @endforelse
                                        </tbody>
                                    </table>
                                </div>

                                <!-- Pagination -->
                                <div class="d-flex justify-content-center mt-4">
                                    {{ $tasks->links() }}
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>
</div>
@endsection

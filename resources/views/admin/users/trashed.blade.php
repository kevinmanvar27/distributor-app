@extends('admin.layouts.app')

@section('title', 'Deleted Users')

@section('content')
<div class="container-fluid h-100">
    <div class="row h-100">
        @include('admin.layouts.sidebar')
        
        <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4 main-content">
            @include('admin.layouts.header', ['pageTitle' => 'User Management'])
            
            <div class="pt-4 pb-2 mb-3">
                <div class="row">
                    <div class="col-12">
                        <div class="card border-0 shadow-sm">
                            <div class="card-header bg-white border-0 py-3">
                                <div class="d-flex flex-column flex-md-row justify-content-between align-items-start align-items-md-center gap-2 gap-md-0">
                                    <div class="mb-2 mb-md-0">
                                        <h4 class="card-title mb-0 fw-bold h5 h4-md">Deleted Users</h4>
                                        <p class="mb-0 text-muted small">View and restore deleted users</p>
                                    </div>
                                    <div class="d-flex gap-2">
                                        <a href="{{ route('admin.users.index') }}" class="btn btn-sm btn-md-normal btn-primary rounded-pill px-3 px-md-4">
                                            <i class="fas fa-arrow-left me-1 me-md-2"></i><span class="d-none d-sm-inline">Back to Active Users</span><span class="d-sm-none">Back</span>
                                        </a>
                                    </div>
                                </div>
                            </div>
                            
                            <div class="card-body">
                                @if(session('success'))
                                    <div class="alert alert-success alert-dismissible fade show rounded-pill px-4 py-3" role="alert">
                                        <i class="fas fa-check-circle me-2"></i>{{ session('success') }}
                                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                                    </div>
                                @endif
                                
                                @if(session('error'))
                                    <div class="alert alert-danger alert-dismissible fade show rounded-pill px-4 py-3" role="alert">
                                        <i class="fas fa-exclamation-circle me-2"></i>{{ session('error') }}
                                        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                                    </div>
                                @endif
                                
                                <div class="table-responsive">
                                    <table class="table table-hover align-middle" id="usersTable">
                                        <thead class="table-light">
                                            <tr>
                                                <th>#</th>
                                                <th>User</th>
                                                <th>Email</th>
                                                <th>Role</th>
                                                <th>Status</th>
                                                <th>Deleted Date</th>
                                                <th>Actions</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            @forelse($users as $user)
                                                <tr>
                                                    <td class="fw-bold">{{ $user->id }}</td>
                                                    <td>
                                                        <div class="d-flex align-items-center">
                                                            <img src="{{ $user->avatar_url }}" 
                                                                 class="rounded-circle me-3" width="40" height="40" alt="{{ $user->name }}">
                                                            <div>
                                                                <div class="fw-medium">{{ $user->name }}</div>
                                                            </div>
                                                        </div>
                                                    </td>
                                                    <td>{{ $user->email }}</td>
                                                    <td>
                                                        @php
                                                            $roleClass = [
                                                                'super_admin' => 'bg-danger-subtle text-danger-emphasis',
                                                                'admin' => 'bg-primary-subtle text-primary-emphasis',
                                                                'editor' => 'bg-warning-subtle text-warning-emphasis',
                                                                'user' => 'bg-secondary-subtle text-secondary-emphasis'
                                                            ][$user->user_role] ?? 'bg-secondary-subtle text-secondary-emphasis';
                                                        @endphp
                                                        <span class="badge {{ $roleClass }} rounded-pill px-3 py-2">
                                                            {{ ucfirst(str_replace('_', ' ', $user->user_role)) }}
                                                        </span>
                                                    </td>
                                                    <td>
                                                        {!! $user->status_badge !!}
                                                    </td>
                                                    <td>
                                                        <span class="text-muted">{{ $user->deleted_at?->format('M d, Y h:i A') ?? 'N/A' }}</span>
                                                    </td>
                                                    <td>
                                                        <div class="btn-group btn-group-sm" role="group">
                                                            <!-- Restore Button -->
                                                            <form action="{{ route('admin.users.restore', $user->id) }}" method="POST" class="d-inline" onsubmit="return confirm('Are you sure you want to restore this user?');">
                                                                @csrf
                                                                <button type="submit" class="btn btn-outline-success rounded-start-pill px-3">
                                                                    <i class="fas fa-undo"></i> Restore
                                                                </button>
                                                            </form>
                                                            
                                                            <!-- Permanently Delete Button -->
                                                            <form action="{{ route('admin.users.force-delete', $user->id) }}" method="POST" class="d-inline" onsubmit="return confirm('⚠️ WARNING: This will PERMANENTLY delete this user and cannot be undone. Are you absolutely sure?');">
                                                                @csrf
                                                                @method('DELETE')
                                                                <button type="submit" class="btn btn-outline-danger rounded-end-pill px-3">
                                                                    <i class="fas fa-trash-alt"></i> Delete Forever
                                                                </button>
                                                            </form>
                                                        </div>
                                                    </td>
                                                </tr>
                                            @empty
                                                <tr>
                                                    <td colspan="7" class="text-center py-5">
                                                        <div class="text-muted">
                                                            <i class="fas fa-trash-restore fa-2x mb-3"></i>
                                                            <p class="mb-0">No deleted users found</p>
                                                            <p class="small">All users are active</p>
                                                        </div>
                                                    </td>
                                                </tr>
                                            @endforelse
                                        </tbody>
                                    </table>
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
    $(document).ready(function() {
        // Initialize DataTable
        $('#usersTable').DataTable({
            "pageLength": 10,
            "lengthMenu": [[10, 25, 50, -1], [10, 25, 50, "All"]],
            "ordering": true,
            "searching": true,
            "info": true,
            "paging": true,
            "columnDefs": [
                { "orderable": false, "targets": [5] } // Disable sorting on Actions column
            ],
            "language": {
                "search": "Search:",
                "lengthMenu": "Show _MENU_ entries per page",
                "info": "Showing _START_ to _END_ of _TOTAL_ deleted users",
                "infoEmpty": "Showing 0 to 0 of 0 deleted users",
                "infoFiltered": "(filtered from _MAX_ total deleted users)",
                "paginate": {
                    "first": "First",
                    "last": "Last",
                    "next": "Next",
                    "previous": "Previous"
                }
            },
            "aoColumns": [
                null, // #
                null, // User
                null, // Email
                null, // Role
                null, // Deleted Date
                null  // Actions
            ],
            "preDrawCallback": function(settings) {
                // Ensure consistent column count
                if ($('#usersTable tbody tr').length === 0) {
                    $('#usersTable tbody').html('<tr><td colspan="6" class="text-center py-5"><div class="text-muted"><i class="fas fa-trash-restore fa-2x mb-3"></i><p class="mb-0">No deleted users found</p><p class="small">All users are active</p></div></td></tr>');
                }
            }
        });
        // Adjust select width after DataTable initializes
        $('.dataTables_length select').css('width', '80px');
    });
</script>
@endsection
@extends('admin.layouts.app')

@section('title', 'Users')

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
                                        <h4 class="card-title mb-0 fw-bold h5 h4-md">User Management</h4>
                                        <p class="mb-0 text-muted small">Manage all users and their roles</p>
                                    </div>
                                    <div class="d-flex gap-2">
                                        <a href="{{ route('admin.users.trashed') }}" class="btn btn-sm btn-md-normal btn-outline-danger rounded-pill px-3 px-md-4">
                                            <i class="fas fa-trash me-1 me-md-2"></i><span class="d-none d-sm-inline">Deleted Users</span><span class="d-sm-none">Deleted</span>
                                        </a>
                                        <a href="{{ route('admin.users.create') }}" class="btn btn-sm btn-md-normal btn-theme rounded-pill px-3 px-md-4">
                                            <i class="fas fa-plus me-1 me-md-2"></i><span class="d-none d-sm-inline">Add New User</span><span class="d-sm-none">Add</span>
                                        </a>
                                    </div>
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
                                
                                <div class="table-responsive">
                                    <table class="table align-middle" id="usersTable">
                                        <thead class="table-light">
                                            <tr>
                                                <th>#</th>
                                                <th>User</th>
                                                <th>Email</th>
                                                <th>Role</th>
                                                <th>Status</th>
                                                <th>Actions</th>
                                            </tr>
                                        </thead>
                                        <tbody>
                                            @foreach($users as $user)
                                                <tr>
                                                    <td class="fw-bold">{{ $user->id }}</td>
                                                    <td>
                                                        <div class="d-flex align-items-center">
                                                            <img src="{{ $user->avatar_url }}" 
                                                                 class="rounded-circle me-3" width="40" height="40" alt="{{ $user->name }}">
                                                            <div>
                                                                <div class="fw-medium">{{ $user->name }}</div>
                                                                @if(Auth::user()->id == $user->id)
                                                                    <span class="badge bg-success-subtle text-success-emphasis rounded-pill">You</span>
                                                                @endif
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
                                                        <div class="btn-group btn-group-sm" role="group">
                                                            <!-- View Button -->
                                                            <button type="button" class="btn btn-outline-info rounded-start-pill px-3 view-user-btn" data-user-id="{{ $user->id }}" data-bs-toggle="modal" data-bs-target="#userModal">
                                                                <i class="fas fa-eye"></i>
                                                            </button>
                                                            <!-- Edit Button -->
                                                            <a href="{{ route('admin.users.edit', $user) }}" class="btn btn-outline-primary px-3">
                                                                <i class="fas fa-edit"></i>
                                                            </a>
                                                            <!-- Delete Button -->
                                                            @if(Auth::user()->id != $user->id)
                                                                <form action="{{ route('admin.users.destroy', $user) }}" method="POST" class="d-inline" onsubmit="return confirm('Are you sure you want to delete this user? This action cannot be undone.');">
                                                                    @csrf
                                                                    @method('DELETE')
                                                                    <button type="submit" class="btn btn-outline-danger rounded-end-pill px-3">
                                                                        <i class="fas fa-trash"></i>
                                                                    </button>
                                                                </form>
                                                            @else
                                                                <button type="button" class="btn btn-outline-secondary rounded-end-pill px-3" disabled title="Cannot delete yourself">
                                                                    <i class="fas fa-trash"></i>
                                                                </button>
                                                            @endif
                                                        </div>
                                                    </td>
                                                </tr>
                                            @endforeach
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

<!-- User Details Modal -->
<div class="modal fade" id="userModal" tabindex="-1" aria-labelledby="userModalLabel" aria-hidden="true">
    <div class="modal-dialog modal-lg">
        <div class="modal-content">
            <div class="modal-header">
                <h5 class="modal-title" id="userModalLabel">User Details</h5>
                <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
            </div>
            <div class="modal-body" id="userModalBody">
                <!-- User details will be loaded here via AJAX -->
                <div class="text-center">
                    <div class="spinner-border" role="status">
                        <span class="visually-hidden">Loading...</span>
                    </div>
                </div>
            </div>
            <div class="modal-footer">
                <button type="button" class="btn btn-secondary rounded-pill px-4" data-bs-dismiss="modal">Close</button>
            </div>
        </div>
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
            "autoWidth": false,
            "columnDefs": [
                { "orderable": false, "targets": [5] }, // Disable sorting on Actions column
                { "width": "5%", "targets": 0 },
                { "width": "25%", "targets": 1 },
                { "width": "20%", "targets": 2 },
                { "width": "15%", "targets": 3 },
                { "width": "15%", "targets": 4 },
                { "width": "20%", "targets": 5 }
            ],
            "language": {
                "search": "Search:",
                "lengthMenu": "Show _MENU_ entries per page",
                "info": "Showing _START_ to _END_ of _TOTAL_ users",
                "infoEmpty": "Showing 0 to 0 of 0 users",
                "infoFiltered": "(filtered from _MAX_ total users)",
                "emptyTable": '<div class="text-center py-5"><div class="text-muted"><i class="fas fa-users fa-2x mb-3"></i><p class="mb-0">No users found</p><p class="small">Try creating a new user</p></div></div>',
                "zeroRecords": '<div class="text-center py-5"><div class="text-muted"><i class="fas fa-search fa-2x mb-3"></i><p class="mb-0">No matching users found</p><p class="small">Try adjusting your search</p></div></div>',
                "paginate": {
                    "first": "First",
                    "last": "Last",
                    "next": "Next",
                    "previous": "Previous"
                }
            }
        });
        
        // Adjust select width after DataTable initializes
        $('.dataTables_length select').css('width', '80px');
        
        // Handle view user button click - use event delegation for dynamically rendered rows
        $(document).on('click', '.view-user-btn', function() {
            var userId = $(this).data('user-id');
            
            // Show loading indicator
            $('#userModalBody').html('<div class="text-center"><div class="spinner-border" role="status"><span class="visually-hidden">Loading...</span></div></div>');
            
            // Load user details via AJAX
            $.ajax({
                url: '/admin/users/' + userId,
                type: 'GET',
                success: function(data) {
                    $('#userModalBody').html(data);
                },
                error: function() {
                    $('#userModalBody').html('<div class="alert-theme alert-danger">Failed to load user details.</div>');
                }
            });
        });
    });
</script>
@endsection
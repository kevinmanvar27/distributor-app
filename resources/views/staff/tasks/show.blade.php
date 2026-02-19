@extends('admin.layouts.app')

@section('title', 'Task Details')

@section('content')
<div class="container-fluid h-100">
    <div class="row h-100">
        @include('admin.layouts.sidebar')
        
        <main class="col-md-9 ms-sm-auto col-lg-10 px-md-4 main-content">
            @include('admin.layouts.header', ['pageTitle' => 'Task Details'])
            
            <div class="pt-4 pb-2 mb-3">
                <div class="row">
                    <div class="col-12">
                        @if(session('success'))
                            <div class="alert-theme alert-success alert-dismissible fade show rounded-pill px-4 py-3" role="alert">
                                <i class="fas fa-check-circle me-2"></i>{{ session('success') }}
                                <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
                            </div>
                        @endif

                        <div class="card border-0 shadow-sm">
                            <div class="card-header bg-white border-0 py-3 d-flex justify-content-between align-items-center">
                                <div>
                                    <h4 class="card-title mb-0 fw-bold">{{ $task->title }}</h4>
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
                                    <span class="badge bg-{{ $statusColor }} rounded-pill mt-1">
                                        {{ ucwords(str_replace('_', ' ', $task->status)) }}
                                    </span>
                                </div>
                                <a href="{{ route('staff.tasks.index') }}" class="btn btn-outline-secondary rounded-pill px-4">
                                    <i class="fas fa-arrow-left me-2"></i>Back
                                </a>
                            </div>
                            <div class="card-body">
                                <div class="row">
                                    <div class="col-md-8">
                                        <!-- Task Description -->
                                        <div class="mb-4">
                                            <h5 class="fw-bold mb-3">
                                                <i class="fas fa-align-left text-primary me-2"></i>Description
                                            </h5>
                                            <p class="text-muted">{{ $task->description }}</p>
                                        </div>

                                        <!-- Attachment -->
                                        @if($task->attachment)
                                            <div class="mb-4">
                                                <h5 class="fw-bold mb-3">
                                                    <i class="fas fa-paperclip text-primary me-2"></i>Attachment
                                                </h5>
                                                <div class="card border-0 bg-light">
                                                    <div class="card-body d-flex justify-content-between align-items-center">
                                                        <div>
                                                            <i class="fas fa-file text-primary me-2"></i>
                                                            <span>{{ $task->attachment }}</span>
                                                        </div>
                                                        <a href="{{ asset('storage/tasks/' . $task->attachment) }}" 
                                                           target="_blank" 
                                                           class="btn btn-sm btn-primary rounded-pill">
                                                            <i class="fas fa-download me-1"></i>Download
                                                        </a>
                                                    </div>
                                                </div>
                                            </div>
                                        @endif

                                        <!-- Comments Section -->
                                        <div class="mb-4">
                                            <h5 class="fw-bold mb-3">
                                                <i class="fas fa-comments text-primary me-2"></i>Conversation
                                                <span class="badge bg-secondary rounded-pill">{{ $task->comments->count() }}</span>
                                            </h5>

                                            @php
                                                $allComments = $task->comments->sortBy('created_at');
                                                $currentUserId = Auth::id();
                                            @endphp

                                            <!-- Chat Container -->
                                            <div class="chat-container card border-0 shadow-sm mb-3">
                                                <div class="chat-messages p-3" id="chatMessages" style="height: 400px; overflow-y: auto; background-color: #f8f9fa;">
                                                    @if($allComments->count() > 0)
                                                        @foreach($allComments as $comment)
                                                            @php
                                                                $isCurrentUser = $comment->user_id == $currentUserId;
                                                            @endphp
                                                            
                                                            <div class="chat-message mb-3 {{ $isCurrentUser ? 'text-end' : '' }}">
                                                                <div class="d-inline-block {{ $isCurrentUser ? 'text-end' : '' }}" style="max-width: 70%;">
                                                                    <!-- User Name & Time -->
                                                                    <div class="mb-1">
                                                                        <small class="text-muted">
                                                                            <strong>{{ $comment->user->name ?? 'Unknown User' }}</strong>
                                                                            <span class="mx-1">•</span>
                                                                            {{ $comment->created_at->format('M d, h:i A') }}
                                                                        </small>
                                                                    </div>
                                                                    
                                                                    <!-- Message Bubble -->
                                                                    <div class="message-bubble {{ $isCurrentUser ? 'bg-primary text-white' : 'bg-white' }} p-3 rounded-3 shadow-sm">
                                                                        <p class="mb-0" style="word-wrap: break-word; white-space: pre-wrap;">{{ $comment->comment }}</p>
                                                                    </div>
                                                                </div>
                                                            </div>
                                                        @endforeach
                                                    @else
                                                        <div class="text-center py-5">
                                                            <i class="fas fa-comments fa-3x text-muted mb-3"></i>
                                                            <p class="text-muted">No messages yet. Start the conversation!</p>
                                                        </div>
                                                    @endif
                                                </div>

                                                <!-- Chat Input Form -->
                                                @if($task->status !== 'verified' && auth()->user()->hasPermission('update_task_status'))
                                                    <div class="chat-input border-top bg-white p-3">
                                                        <form action="{{ route('staff.tasks.comment', $task->id) }}" method="POST" id="chatForm">
                                                            @csrf
                                                            <div class="input-group">
                                                                <textarea class="form-control @error('comment') is-invalid @enderror" 
                                                                          name="comment" 
                                                                          id="commentInput"
                                                                          rows="2" 
                                                                          placeholder="Type your message..." 
                                                                          required
                                                                          style="resize: none;"></textarea>
                                                                <button type="submit" class="btn btn-primary px-4">
                                                                    <i class="fas fa-paper-plane"></i>
                                                                </button>
                                                            </div>
                                                            @error('comment')
                                                                <div class="text-danger small mt-1">{{ $message }}</div>
                                                            @enderror
                                                        </form>
                                                    </div>
                                                @else
                                                    <div class="chat-input-locked border-top bg-light p-3">
                                                        <div class="alert alert-secondary mb-0 text-center">
                                                            <i class="fas fa-lock me-2"></i>
                                                            <strong>{{ $task->status === 'verified' ? 'Task Verified & Locked' : 'No Permission' }}</strong>
                                                            <p class="mb-0 small mt-1">
                                                                {{ $task->status === 'verified' ? 'This task is verified and cannot be modified.' : 'You do not have permission to add comments.' }}
                                                            </p>
                                                        </div>
                                                    </div>
                                                @endif
                                                            <strong>Task Verified & Locked</strong>
                                                            <p class="mb-0 small mt-1">This task is verified and cannot be modified.</p>
                                                        </div>
                                                    </div>
                                                @endif
                                            </div>
                                        </div>
                                    </div>

                                    <div class="col-md-4">
                                        <!-- Task Information -->
                                        <div class="card border-0 bg-light mb-3">
                                            <div class="card-body">
                                                <h5 class="card-title fw-bold mb-3">
                                                    <i class="fas fa-info-circle text-primary me-2"></i>Task Information
                                                </h5>

                                                <div class="mb-3">
                                                    <strong>Assigned By:</strong><br>
                                                    <span class="text-muted">{{ $task->assignedBy->name ?? 'N/A' }}</span>
                                                </div>

                                                <div class="mb-3">
                                                    <strong>Created:</strong><br>
                                                    <span class="text-muted">{{ $task->created_at->format('M d, Y h:i A') }}</span>
                                                </div>

                                                <div class="mb-3">
                                                    <strong>Last Updated:</strong><br>
                                                    <span class="text-muted">{{ $task->updated_at->format('M d, Y h:i A') }}</span>
                                                </div>
                                            </div>
                                        </div>

                                        <!-- Status Update Actions -->
                                        @if($task->status !== 'verified' && auth()->user()->hasPermission('update_task_status'))
                                            <div class="card border-0 bg-light">
                                                <div class="card-body">
                                                    <h5 class="card-title fw-bold mb-3">
                                                        <i class="fas fa-bolt text-primary me-2"></i>Update Status
                                                    </h5>

                                                    <div class="d-grid gap-2">
                                                        @if($task->status === 'pending')
                                                            <form action="{{ route('staff.tasks.status', $task->id) }}" method="POST">
                                                                @csrf
                                                                <input type="hidden" name="status" value="in_progress">
                                                                <button type="submit" class="btn btn-info rounded-pill w-100">
                                                                    <i class="fas fa-play me-2"></i>Start Working
                                                                </button>
                                                            </form>
                                                        @endif

                                                        @if(in_array($task->status, ['pending', 'in_progress']))
                                                            <form action="{{ route('staff.tasks.status', $task->id) }}" method="POST">
                                                                @csrf
                                                                <input type="hidden" name="status" value="question">
                                                                <button type="submit" class="btn btn-warning rounded-pill w-100">
                                                                    <i class="fas fa-question-circle me-2"></i>Ask Question
                                                                </button>
                                                            </form>
                                                        @endif

                                                        @if(in_array($task->status, ['in_progress', 'question']))
                                                            <form action="{{ route('staff.tasks.status', $task->id) }}" method="POST">
                                                                @csrf
                                                                <input type="hidden" name="status" value="done">
                                                                <button type="submit" class="btn btn-success rounded-pill w-100">
                                                                    <i class="fas fa-check me-2"></i>Mark as Done
                                                                </button>
                                                            </form>
                                                        @endif

                                                        @if($task->status === 'done')
                                                            <div class="alert-theme alert-success mb-0">
                                                                <i class="fas fa-check-circle me-2"></i>
                                                                <strong>Task Completed</strong>
                                                                <p class="mb-0 small mt-1">Waiting for verification</p>
                                                            </div>
                                                        @endif
                                                    </div>
                                                </div>
                                            </div>
                                        @else
                                            <div class="card border-0 bg-light">
                                                <div class="card-body">
                                                    <div class="alert-theme alert-success mb-0">
                                                        <div class="d-flex align-items-center">
                                                            <i class="fas fa-check-double fa-2x me-3"></i>
                                                            <div>
                                                                <strong>Task Verified</strong>
                                                                <p class="mb-0 small mt-1">This task has been completed and verified.</p>
                                                            </div>
                                                        </div>
                                                    </div>
                                                </div>
                                            </div>
                                        @endif
                                    </div>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </main>
    </div>
</div>

<style>
.gap-2 {
    gap: 0.5rem !important;
}
.d-grid.gap-2 {
    gap: 0.5rem !important;
}

/* Chat Styles */
.chat-container {
    border-radius: 12px;
    overflow: hidden;
}

.chat-messages {
    background: linear-gradient(to bottom, #f8f9fa 0%, #e9ecef 100%);
    background-image: 
        repeating-linear-gradient(45deg, transparent, transparent 10px, rgba(255,255,255,.05) 10px, rgba(255,255,255,.05) 20px),
        linear-gradient(to bottom, #f8f9fa, #e9ecef);
}

.chat-messages::-webkit-scrollbar {
    width: 6px;
}

.chat-messages::-webkit-scrollbar-track {
    background: #f1f1f1;
}

.chat-messages::-webkit-scrollbar-thumb {
    background: #888;
    border-radius: 3px;
}

.chat-messages::-webkit-scrollbar-thumb:hover {
    background: #555;
}

.chat-message {
    animation: fadeIn 0.3s ease-in;
}

@keyframes fadeIn {
    from {
        opacity: 0;
        transform: translateY(10px);
    }
    to {
        opacity: 1;
        transform: translateY(0);
    }
}

.message-bubble {
    position: relative;
    box-shadow: 0 2px 8px rgba(0,0,0,0.1);
    transition: transform 0.2s ease;
}

.message-bubble:hover {
    transform: translateY(-2px);
    box-shadow: 0 4px 12px rgba(0,0,0,0.15);
}

.chat-input textarea {
    border: 2px solid #e9ecef;
    border-radius: 8px 0 0 8px;
    transition: border-color 0.3s ease;
}

.chat-input textarea:focus {
    border-color: #0d6efd;
    box-shadow: none;
}

.chat-input .btn {
    border-radius: 0 8px 8px 0;
    min-width: 60px;
}
</style>

<script>
document.addEventListener('DOMContentLoaded', function() {
    // Auto-scroll to bottom of chat
    const chatMessages = document.getElementById('chatMessages');
    if (chatMessages) {
        chatMessages.scrollTop = chatMessages.scrollHeight;
    }

    // Handle Enter key to submit (Shift+Enter for new line)
    const commentInput = document.getElementById('commentInput');
    const chatForm = document.getElementById('chatForm');
    
    if (commentInput && chatForm) {
        commentInput.addEventListener('keydown', function(e) {
            if (e.key === 'Enter' && !e.shiftKey) {
                e.preventDefault();
                chatForm.submit();
            }
        });

        // Auto-resize textarea
        commentInput.addEventListener('input', function() {
            this.style.height = 'auto';
            this.style.height = Math.min(this.scrollHeight, 120) + 'px';
        });
    }

    // Focus on input when page loads
    if (commentInput) {
        commentInput.focus();
    }
});
</script>
@endsection

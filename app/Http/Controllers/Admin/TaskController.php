<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\Task;
use App\Models\TaskComment;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Storage;
use Illuminate\Support\Facades\Validator;

class TaskController extends Controller
{
    /**
     * Display a listing of tasks
     */
    public function index(Request $request)
    {
        // Check permission (additional layer of security)
        if (!Auth::user()->hasPermission('view_tasks')) {
            abort(403, 'Unauthorized action.');
        }

        $query = Task::with(['assignedBy', 'assignedTo'])
            ->orderBy('created_at', 'desc');

        // Filter by status
        if ($request->has('status') && $request->status !== '') {
            $query->where('status', $request->status);
        }

        // Filter by assigned user
        if ($request->has('assigned_to') && $request->assigned_to !== '') {
            $query->where('assigned_to', $request->assigned_to);
        }

        // Search
        if ($request->has('search') && $request->search !== '') {
            $search = $request->search;
            $query->where(function($q) use ($search) {
                $q->where('title', 'like', "%{$search}%")
                  ->orWhere('description', 'like', "%{$search}%");
            });
        }

        $tasks = $query->paginate(15);
        $statuses = Task::getStatuses();
        
        // Get all staff users for assignment
        $staff = User::whereIn('user_role', ['staff', 'editor', 'admin'])->get();

        // Get statistics
        $stats = [
            'total' => Task::count(),
            'pending' => Task::pending()->count(),
            'in_progress' => Task::inProgress()->count(),
            'with_questions' => Task::withQuestions()->count(),
            'done' => Task::done()->count(),
            'verified' => Task::verified()->count(),
        ];

        // Return view for web requests, JSON for API
        if ($request->expectsJson()) {
            return response()->json([
                'success' => true,
                'tasks' => $tasks,
                'statuses' => $statuses,
                'staff' => $staff,
                'stats' => $stats,
            ]);
        }

        return view('admin.tasks.index', compact('tasks', 'statuses', 'staff', 'stats'));
    }

    /**
     * Show the form for creating a new task
     */
    public function create()
    {
        // Check permission
        if (!Auth::user()->hasPermission('manage_tasks')) {
            abort(403, 'Unauthorized action.');
        }

        // Get all staff users
        $staff = User::whereIn('user_role', ['staff', 'editor', 'admin'])->get();

        // Return view for web requests, JSON for API
        if (request()->expectsJson()) {
            return response()->json([
                'success' => true,
                'staff' => $staff,
            ]);
        }

        return view('admin.tasks.create', compact('staff'));
    }

    /**
     * Store a newly created task
     */
    public function store(Request $request)
    {
        // Check permission
        if (!Auth::user()->hasPermission('manage_tasks')) {
            abort(403, 'Unauthorized action.');
        }

        $validator = Validator::make($request->all(), [
            'title' => 'required|string|max:255',
            'description' => 'required|string',
            'assigned_to' => 'required|exists:users,id',
            'attachment' => 'nullable|file|mimes:jpg,jpeg,png,pdf,doc,docx,xls,xlsx|max:10240', // 10MB max
        ]);

        if ($validator->fails()) {
            // Return JSON for API requests
            if ($request->expectsJson()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validation failed',
                    'errors' => $validator->errors(),
                ], 422);
            }
            
            // Redirect back with errors for web requests
            return redirect()->back()
                ->withErrors($validator)
                ->withInput();
        }

        // Handle file upload
        $attachmentPath = null;
        if ($request->hasFile('attachment')) {
            $file = $request->file('attachment');
            $filename = time() . '_' . $file->getClientOriginalName();
            $attachmentPath = $file->storeAs('tasks', $filename, 'public');
            $attachmentPath = $filename; // Store only filename
        }

        // Create task
        $task = Task::create([
            'title' => $request->title,
            'description' => $request->description,
            'attachment' => $attachmentPath,
            'assigned_by' => Auth::id(),
            'assigned_to' => $request->assigned_to,
            'status' => Task::STATUS_PENDING,
        ]);

        // Load relationships
        $task->load(['assignedBy', 'assignedTo']);

        // Return JSON for API requests
        if ($request->expectsJson()) {
            return response()->json([
                'success' => true,
                'message' => 'Task created successfully',
                'task' => $task,
            ], 201);
        }

        // Redirect for web requests
        return redirect()->route('admin.tasks.index')
            ->with('success', 'Task created successfully.');
    }

    /**
     * Display the specified task
     */
    public function show($id)
    {
        // Check permission
        if (!Auth::user()->hasPermission('view_tasks')) {
            abort(403, 'Unauthorized action.');
        }

        $task = Task::with(['assignedBy', 'assignedTo', 'comments.user'])
            ->findOrFail($id);

        // Return JSON for API requests
        if (request()->expectsJson()) {
            return response()->json([
                'success' => true,
                'task' => $task,
            ]);
        }

        // Return view for web requests
        return view('admin.tasks.show', compact('task'));
    }

    /**
     * Show the form for editing the specified task
     */
    public function edit($id)
    {
        // Check permission
        if (!Auth::user()->hasPermission('manage_tasks')) {
            abort(403, 'Unauthorized action.');
        }

        $task = Task::with(['assignedBy', 'assignedTo'])->findOrFail($id);
        
        // Get all staff users
        $staff = User::whereIn('user_role', ['staff', 'editor', 'admin'])->get();

        // Return JSON for API requests
        if (request()->expectsJson()) {
            return response()->json([
                'success' => true,
                'task' => $task,
                'staff' => $staff,
            ]);
        }

        // Return view for web requests
        return view('admin.tasks.edit', compact('task', 'staff'));
    }

    /**
     * Update the specified task
     */
    public function update(Request $request, $id)
    {
        // Check permission
        if (!Auth::user()->hasPermission('manage_tasks')) {
            abort(403, 'Unauthorized action.');
        }

        $task = Task::findOrFail($id);

        $validator = Validator::make($request->all(), [
            'title' => 'required|string|max:255',
            'description' => 'required|string',
            'assigned_to' => 'required|exists:users,id',
            'attachment' => 'nullable|file|mimes:jpg,jpeg,png,pdf,doc,docx,xls,xlsx|max:10240',
        ]);

        if ($validator->fails()) {
            // Return JSON for API requests
            if ($request->expectsJson()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validation failed',
                    'errors' => $validator->errors(),
                ], 422);
            }
            
            // Redirect back with errors for web requests
            return redirect()->back()
                ->withErrors($validator)
                ->withInput();
        }

        // Handle file upload
        if ($request->hasFile('attachment')) {
            // Delete old attachment
            if ($task->attachment) {
                Storage::disk('public')->delete('tasks/' . $task->attachment);
            }

            $file = $request->file('attachment');
            $filename = time() . '_' . $file->getClientOriginalName();
            $attachmentPath = $file->storeAs('tasks', $filename, 'public');
            $task->attachment = $filename;
        }

        // Update task
        $task->update([
            'title' => $request->title,
            'description' => $request->description,
            'assigned_to' => $request->assigned_to,
        ]);

        // Load relationships
        $task->load(['assignedBy', 'assignedTo']);

        // Return JSON for API requests
        if ($request->expectsJson()) {
            return response()->json([
                'success' => true,
                'message' => 'Task updated successfully',
                'task' => $task,
            ]);
        }

        // Redirect for web requests
        return redirect()->route('admin.tasks.index')
            ->with('success', 'Task updated successfully.');
    }

    /**
     * Remove the specified task
     */
    public function destroy($id)
    {
        // Check permission
        if (!Auth::user()->hasPermission('manage_tasks')) {
            abort(403, 'Unauthorized action.');
        }

        $task = Task::findOrFail($id);

        // Delete attachment if exists
        if ($task->attachment) {
            Storage::disk('public')->delete('tasks/' . $task->attachment);
        }

        $task->delete();

        // Return JSON for API requests
        if (request()->expectsJson()) {
            return response()->json([
                'success' => true,
                'message' => 'Task deleted successfully',
            ]);
        }

        // Redirect for web requests
        return redirect()->route('admin.tasks.index')
            ->with('success', 'Task deleted successfully.');
    }

    /**
     * Add a comment to the task
     */
    public function addComment(Request $request, $id)
    {
        // Check permission
        if (!Auth::user()->hasPermission('update_task_status')) {
            abort(403, 'Unauthorized action.');
        }

        $task = Task::findOrFail($id);

        // Prevent comments on verified tasks
        if ($task->status === Task::STATUS_VERIFIED) {
            // Return JSON for API requests
            if ($request->expectsJson()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Cannot add comment. This task is verified and locked.',
                ], 403);
            }
            
            // Redirect back with error for web requests
            return redirect()->back()
                ->with('error', 'Cannot add comment. This task is verified and locked.');
        }

        $validator = Validator::make($request->all(), [
            'comment' => 'required|string',
        ]);

        if ($validator->fails()) {
            // Return JSON for API requests
            if ($request->expectsJson()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validation failed',
                    'errors' => $validator->errors(),
                ], 422);
            }
            
            // Redirect back with errors for web requests
            return redirect()->back()
                ->withErrors($validator)
                ->withInput();
        }

        $comment = TaskComment::create([
            'task_id' => $task->id,
            'user_id' => Auth::id(),
            'comment' => $request->comment,
        ]);

        $comment->load('user');

        // Return JSON for API requests
        if ($request->expectsJson()) {
            return response()->json([
                'success' => true,
                'message' => 'Comment added successfully',
                'comment' => $comment,
            ], 201);
        }

        // Redirect for web requests
        return redirect()->route('admin.tasks.show', $task->id)
            ->with('success', 'Comment added successfully.');
    }

    /**
     * Update task status
     */
    public function updateStatus(Request $request, $id)
    {
        // Check permission
        if (!Auth::user()->hasPermission('update_task_status')) {
            abort(403, 'Unauthorized action.');
        }

        $task = Task::findOrFail($id);

        // Prevent status changes on verified tasks
        if ($task->status === Task::STATUS_VERIFIED) {
            // Return JSON for API requests
            if ($request->expectsJson()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Cannot update status. This task is verified and locked.',
                ], 403);
            }
            
            // Redirect back with error for web requests
            return redirect()->back()
                ->with('error', 'Cannot update status. This task is verified and locked.');
        }

        $validator = Validator::make($request->all(), [
            'status' => 'required|in:pending,in_progress,question,done,verified',
        ]);

        if ($validator->fails()) {
            // Return JSON for API requests
            if ($request->expectsJson()) {
                return response()->json([
                    'success' => false,
                    'message' => 'Validation failed',
                    'errors' => $validator->errors(),
                ], 422);
            }
            
            // Redirect back with errors for web requests
            return redirect()->back()
                ->withErrors($validator)
                ->withInput();
        }

        $oldStatus = $task->status;
        $task->status = $request->status;
        $task->save();

        // Return JSON for API requests
        if ($request->expectsJson()) {
            return response()->json([
                'success' => true,
                'message' => 'Task status updated successfully',
                'task' => $task->load(['assignedBy', 'assignedTo']),
            ]);
        }

        // Redirect for web requests
        return redirect()->route('admin.tasks.show', $task->id)
            ->with('success', 'Task status updated successfully.');
    }

    /**
     * Get task statistics
     */
    public function statistics()
    {
        // Check permission
        if (!Auth::user()->hasPermission('view_tasks')) {
            abort(403, 'Unauthorized action.');
        }

        $stats = [
            'total' => Task::count(),
            'pending' => Task::pending()->count(),
            'in_progress' => Task::inProgress()->count(),
            'with_questions' => Task::withQuestions()->count(),
            'done' => Task::done()->count(),
            'verified' => Task::verified()->count(),
        ];

        return response()->json([
            'success' => true,
            'statistics' => $stats,
        ]);
    }
}

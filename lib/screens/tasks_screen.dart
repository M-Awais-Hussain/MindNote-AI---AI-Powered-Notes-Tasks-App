import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';

import 'add_edit_task_screen.dart';
import '../widgets/glass_card.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF00BCD4),
      appBar: AppBar(
        backgroundColor: Color(0xFFFFF9C4),
        title: const Text('Tasks'),
        actions: [
          Consumer<TaskProvider>(
            builder: (context, taskProvider, child) {
              return PopupMenuButton<String>(
                onSelected: (value) {
                  switch (value) {
                    case 'clear_completed':
                      _showClearCompletedDialog(context, taskProvider);
                      break;
                    case 'filter_priority':
                      _showPriorityFilterDialog(context, taskProvider);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'filter_priority',
                    child: Row(
                      children: [
                        Icon(Icons.filter_list),
                        SizedBox(width: 8),
                        Text('Filter by Priority'),
                      ],
                    ),
                  ),
                  if (taskProvider.completedTasksCount > 0)
                    const PopupMenuItem(
                      value: 'clear_completed',
                      child: Row(
                        children: [
                          Icon(Icons.clear_all),
                          SizedBox(width: 8),
                          Text('Clear Completed'),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilter(context),
          Expanded(
            child: Consumer<TaskProvider>(
              builder: (context, taskProvider, child) {
                if (taskProvider.tasks.isEmpty) {
                  return _buildEmptyState(context);
                }
                return _buildTasksList(context, taskProvider);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _navigateToAddTask(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSearchAndFilter(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search tasks...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: taskProvider.isLoading
                      ? const Padding(
                          padding: EdgeInsets.all(12.0),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                      : null,
                  border: const OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.search,
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    taskProvider.performAISearch(value);
                  }
                },
                onChanged: (value) {
                  if (value.isEmpty) {
                    taskProvider.setSearchQuery('');
                  }
                },
              ),
              const SizedBox(height: AppConstants.paddingMedium),
              Row(
                children: [
                  Expanded(
                    child: _buildFilterChip(
                      context,
                      'All',
                      taskProvider.filterPriority == null,
                      () => taskProvider.setFilterPriority(null),
                    ),
                  ),
                  const SizedBox(width: AppConstants.paddingSmall),
                  Expanded(
                    child: _buildFilterChip(
                      context,
                      'High',
                      taskProvider.filterPriority == Priority.high,
                      () => taskProvider.setFilterPriority(Priority.high),
                    ),
                  ),
                  const SizedBox(width: AppConstants.paddingSmall),
                  Expanded(
                    child: _buildFilterChip(
                      context,
                      'Medium',
                      taskProvider.filterPriority == Priority.medium,
                      () => taskProvider.setFilterPriority(Priority.medium),
                    ),
                  ),
                  const SizedBox(width: AppConstants.paddingSmall),
                  Expanded(
                    child: _buildFilterChip(
                      context,
                      'Low',
                      taskProvider.filterPriority == Priority.low,
                      () => taskProvider.setFilterPriority(Priority.low),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
        ),
        child: Center(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.task_alt, size: 80, color: Colors.grey[400]),
          const SizedBox(height: AppConstants.paddingLarge),
          Text(
            'No tasks found',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.black),
          ),
          const SizedBox(height: AppConstants.paddingSmall),
          Text(
            'Create your first task to get started!',
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: Colors.black),
          ),
          const SizedBox(height: AppConstants.paddingLarge),
          ElevatedButton.icon(
            onPressed: () => _navigateToAddTask(context),
            icon: const Icon(Icons.add),
            label: const Text('Add Task'),
          ),
        ],
      ),
    );
  }

  Widget _buildTasksList(BuildContext context, TaskProvider taskProvider) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.paddingMedium,
      ),
      itemCount: taskProvider.tasks.length,
      itemBuilder: (context, index) {
        final task = taskProvider.tasks[index];
        return _buildTaskCard(context, task, taskProvider);
      },
    );
  }

  Widget _buildTaskCard(
    BuildContext context,
    Task task,
    TaskProvider taskProvider,
  ) {
    final isOverdue = AppHelpers.isTaskOverdue(task);

    return GlassCard(
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (value) {
            taskProvider.toggleTaskCompletion(task.id);
          },
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
            fontWeight: task.isCompleted ? FontWeight.normal : FontWeight.w500,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  task.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            if (task.subtasks.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    const Icon(
                      Icons.subdirectory_arrow_right,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${task.subtasks.length} subtasks',
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            Wrap(
              spacing: AppConstants.paddingSmall,
              runSpacing: 4,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingSmall,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppHelpers.getPriorityColor(
                      task.priority,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusSmall,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        AppHelpers.getPriorityIcon(task.priority),
                        size: 16,
                        color: AppHelpers.getPriorityColor(task.priority),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        task.priority.displayName,
                        style: TextStyle(
                          color: AppHelpers.getPriorityColor(task.priority),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                if (task.dueDate != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.paddingSmall,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isOverdue
                          ? AppConstants.errorColor.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusSmall,
                      ),
                    ),
                    child: Text(
                      'Due: ${AppHelpers.formatDate(task.dueDate!)}',
                      style: TextStyle(
                        color: isOverdue
                            ? AppConstants.errorColor
                            : Colors.grey[600],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            switch (value) {
              case 'edit':
                _navigateToEditTask(context, task);
                break;
              case 'delete':
                _showDeleteDialog(context, task, taskProvider);
                break;
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [Icon(Icons.edit), SizedBox(width: 8), Text('Edit')],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete),
                  SizedBox(width: 8),
                  Text('Delete'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToAddTask(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const AddEditTaskScreen()));
  }

  void _navigateToEditTask(BuildContext context, Task task) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => AddEditTaskScreen(task: task)),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    Task task,
    TaskProvider taskProvider,
  ) {
    AppHelpers.showConfirmationDialog(
      context,
      title: 'Delete Task',
      content: 'Are you sure you want to delete "${task.title}"?',
      onConfirm: () {
        taskProvider.deleteTask(task.id);
        AppHelpers.showSnackBar(context, 'Task deleted successfully');
      },
    );
  }

  void _showClearCompletedDialog(
    BuildContext context,
    TaskProvider taskProvider,
  ) {
    AppHelpers.showConfirmationDialog(
      context,
      title: 'Clear Completed Tasks',
      content: 'Are you sure you want to delete all completed tasks?',
      onConfirm: () {
        taskProvider.clearCompletedTasks();
        AppHelpers.showSnackBar(context, 'Completed tasks cleared');
      },
    );
  }

  void _showPriorityFilterDialog(
    BuildContext context,
    TaskProvider taskProvider,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Priority'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('All'),
              onTap: () {
                taskProvider.setFilterPriority(null);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('High'),
              onTap: () {
                taskProvider.setFilterPriority(Priority.high);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('Medium'),
              onTap: () {
                taskProvider.setFilterPriority(Priority.medium);
                Navigator.of(context).pop();
              },
            ),
            ListTile(
              title: const Text('Low'),
              onTap: () {
                taskProvider.setFilterPriority(Priority.low);
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      ),
    );
  }
}

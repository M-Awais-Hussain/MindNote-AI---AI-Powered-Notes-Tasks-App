import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../providers/note_provider.dart';
import '../providers/user_provider.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../models/task.dart';
import '../services/ai_assistant_service.dart';
import 'add_edit_task_screen.dart';
import 'add_edit_note_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF00796B),
      appBar: AppBar(
        backgroundColor: Color(0xFFE8F5E9),
        title: const Text('Dashboard'),
        actions: [
          Consumer<UserProvider>(
            builder: (context, userProvider, child) {
              return IconButton(
                icon: Icon(
                  userProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
                ),
                onPressed: () => userProvider.toggleDarkMode(),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWelcomeCard(context),
            const SizedBox(height: AppConstants.paddingLarge),
            _buildQuickStats(context),
            const SizedBox(height: AppConstants.paddingLarge),
            _buildRecentTasks(context),
            const SizedBox(height: AppConstants.paddingLarge),
            _buildQuickActions(context),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return Consumer3<UserProvider, TaskProvider, NoteProvider>(
      builder: (context, userProvider, taskProvider, noteProvider, child) {
        final userName = userProvider.userProfile?.name ?? 'User';

        return Card(
          elevation: 4,
          shadowColor: AppConstants.primaryColor.withOpacity(0.2),
          child: Padding(
            padding: const EdgeInsets.all(AppConstants.paddingLarge),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Welcome back, $userName! 👋',
                      style: Theme.of(context)
                          .textTheme
                          .headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: AppConstants.paddingMedium),
                FutureBuilder<String>(
                  future: _getDailyBriefing(taskProvider, noteProvider),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Row(
                        children: [
                          SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppConstants.primaryColor,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text('Generating daily briefing...'),
                        ],
                      );
                    }
                    if (snapshot.hasError) {
                      return const Text('Ready to conquer the day?');
                    }
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppConstants.accentColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            color: AppConstants.accentColor,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              snapshot.data ?? 'Plan your day!',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                    color: Colors.black87,
                                    fontStyle: FontStyle.italic,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<String> _getDailyBriefing(
    TaskProvider taskProvider,
    NoteProvider noteProvider,
  ) async {
    // Only generate if we have data to analyze
    if (taskProvider.allTasks.isEmpty && noteProvider.allNotes.isEmpty) {
      return "Start by adding some tasks or notes to get AI insights!";
    }

    // Check if we have recent data updates or cache the briefing (simplified for now)
    final aiService = AIAssistantService();
    final tasks = taskProvider.allTasks
        .where((t) => !t.isCompleted)
        .take(3)
        .map((t) => t.title)
        .toList();
    final notes = noteProvider.allNotes.take(3).map((n) => n.title).toList();

    return await aiService.analyzeDailyBriefing(tasks, notes);
  }

  Widget _buildQuickStats(BuildContext context) {
    return Consumer2<TaskProvider, NoteProvider>(
      builder: (context, taskProvider, noteProvider, child) {
        if (taskProvider.isLoading || noteProvider.isLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(AppConstants.paddingLarge),
              child: CircularProgressIndicator(),
            ),
          );
        }
        return Row(
          children: [
            Expanded(
              child: _buildStatCard(
                context,
                'Tasks',
                '${taskProvider.pendingTasksCount} pending',
                Icons.task_alt,
                AppConstants.primaryColor,
              ),
            ),
            const SizedBox(width: AppConstants.paddingMedium),
            Expanded(
              child: _buildStatCard(
                context,
                'Completed',
                '${taskProvider.completedTasksCount} done',
                Icons.check_circle,
                AppConstants.successColor,
              ),
            ),
            const SizedBox(width: AppConstants.paddingMedium),
            Expanded(
              child: _buildStatCard(
                context,
                'Notes',
                '${noteProvider.allNotes.length} total',
                Icons.note,
                AppConstants.accentColor,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTasks(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, child) {
        final recentTasks = taskProvider.allTasks
            .where((task) => !task.isCompleted)
            .take(3)
            .toList();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Tasks',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    // Navigate to tasks screen - this will be handled by the bottom navigation
                    // For now, we'll just show a message
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Switch to Tasks tab to view all tasks'),
                      ),
                    );
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            if (recentTasks.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingLarge),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(Icons.task_alt, size: 48, color: Colors.grey[400]),
                        const SizedBox(height: AppConstants.paddingMedium),
                        Text(
                          'No pending tasks',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(color: Colors.grey[600]),
                        ),
                        const SizedBox(height: AppConstants.paddingSmall),
                        Text(
                          'Create your first task to get started!',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: Colors.grey[500]),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ...recentTasks.map((task) => _buildTaskItem(context, task)),
          ],
        );
      },
    );
  }

  Widget _buildTaskItem(BuildContext context, Task task) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingSmall),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (value) {
            context.read<TaskProvider>().toggleTaskCompletion(task.id);
          },
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty)
              Text(
                task.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            if (task.dueDate != null)
              Text(
                'Due: ${AppHelpers.formatDate(task.dueDate!)}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppHelpers.isTaskOverdue(task)
                          ? AppConstants.errorColor
                          : Colors.grey[600],
                    ),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
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
                borderRadius: BorderRadius.circular(AppConstants.radiusSmall),
              ),
              child: Text(
                task.priority.displayName,
                style: TextStyle(
                  color: AppHelpers.getPriorityColor(task.priority),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppConstants.paddingMedium),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AddEditTaskScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.add_task),
                label: const Text('Add Task'),
              ),
            ),
            const SizedBox(width: AppConstants.paddingMedium),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const AddEditNoteScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.note_add),
                label: const Text('Add Note'),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';
import '../utils/constants.dart';
import '../utils/helpers.dart';
import '../services/ai_assistant_service.dart';

class AddEditTaskScreen extends StatefulWidget {
  final Task? task;

  const AddEditTaskScreen({super.key, this.task});

  @override
  State<AddEditTaskScreen> createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  Priority _selectedPriority = Priority.medium;
  DateTime? _selectedDueDate;
  bool _isLoading = false;
  bool _isAILoading = false;
  List<String> _subtasks = [];

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _selectedPriority = widget.task!.priority;
      _selectedDueDate = widget.task!.dueDate;
      _subtasks = List.from(widget.task!.subtasks);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.task == null ? 'Add Task' : 'Edit Task'),
        actions: [
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingMedium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTitleField(),
              const SizedBox(height: AppConstants.paddingLarge),
              _buildDescriptionField(),
              const SizedBox(height: AppConstants.paddingLarge),
              _buildPrioritySelector(),
              const SizedBox(height: AppConstants.paddingLarge),
              _buildDueDateSelector(),
              const SizedBox(height: AppConstants.paddingLarge),
              _buildSubtasksSection(),
              const SizedBox(height: AppConstants.paddingXLarge),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitleField() {
    return TextFormField(
      controller: _titleController,
      decoration: const InputDecoration(
        labelText: 'Task Title',
        hintText: 'Enter task title',
        border: OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'Please enter a task title';
        }
        return null;
      },
      textInputAction: TextInputAction.next,
    );
  }

  Widget _buildDescriptionField() {
    return TextFormField(
      controller: _descriptionController,
      decoration: const InputDecoration(
        labelText: 'Description',
        hintText: 'Enter task description (optional)',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
      textInputAction: TextInputAction.done,
    );
  }

  Widget _buildPrioritySelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Priority',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        Row(
          children: Priority.values.map((priority) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(
                  right: AppConstants.paddingSmall,
                ),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPriority = priority;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppConstants.paddingMedium,
                    ),
                    decoration: BoxDecoration(
                      color: _selectedPriority == priority
                          ? AppHelpers.getPriorityColor(
                              priority,
                            ).withOpacity(0.1)
                          : Colors.grey[100],
                      border: Border.all(
                        color: _selectedPriority == priority
                            ? AppHelpers.getPriorityColor(priority)
                            : Colors.grey[300]!,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(
                        AppConstants.radiusSmall,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          AppHelpers.getPriorityIcon(priority),
                          color: AppHelpers.getPriorityColor(priority),
                          size: 24,
                        ),
                        const SizedBox(height: AppConstants.paddingSmall),
                        Text(
                          priority.displayName,
                          style: TextStyle(
                            color: AppHelpers.getPriorityColor(priority),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDueDateSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Due Date',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: AppConstants.paddingSmall),
        Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: _selectDueDate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.paddingMedium,
                    vertical: AppConstants.paddingMedium,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(
                      AppConstants.radiusSmall,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today, color: Colors.grey[600]),
                      const SizedBox(width: AppConstants.paddingSmall),
                      Text(
                        _selectedDueDate != null
                            ? AppHelpers.formatDate(_selectedDueDate!)
                            : 'Select due date (optional)',
                        style: TextStyle(
                          color: _selectedDueDate != null
                              ? Colors.black87
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_selectedDueDate != null)
              IconButton(
                onPressed: () {
                  setState(() {
                    _selectedDueDate = null;
                  });
                },
                icon: const Icon(Icons.clear),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildSubtasksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Subtasks',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            if (!_isAILoading)
              TextButton.icon(
                onPressed: _titleController.text.isEmpty
                    ? null
                    : _breakdownTask,
                icon: const Icon(Icons.auto_awesome, size: 16),
                label: const Text('AI Breakdown'),
              ),
          ],
        ),
        if (_isAILoading)
          const Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: LinearProgressIndicator(),
          ),
        const SizedBox(height: AppConstants.paddingSmall),
        ..._subtasks.asMap().entries.map((entry) {
          final index = entry.key;
          final subtask = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Row(
              children: [
                const Icon(
                  Icons.subdirectory_arrow_right,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(subtask, style: const TextStyle(fontSize: 14)),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.remove_circle_outline,
                    size: 20,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    setState(() {
                      _subtasks.removeAt(index);
                    });
                  },
                ),
              ],
            ),
          );
        }).toList(),
        if (!_isAILoading)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: OutlinedButton.icon(
              onPressed: _showAddSubtaskDialog,
              icon: const Icon(Icons.add_circle_outline, size: 18),
              label: const Text('Add Subtask'),
            ),
          ),
      ],
    );
  }

  void _showAddSubtaskDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Subtask'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Enter subtask name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                setState(() {
                  _subtasks.add(controller.text.trim());
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _breakdownTask() async {
    setState(() {
      _isAILoading = true;
    });

    try {
      final aiService = AIAssistantService();
      final breakdown = await aiService.breakdownTask(
        _titleController.text.trim(),
        _descriptionController.text.trim(),
      );
      setState(() {
        _subtasks.addAll(breakdown);
        AppHelpers.showSnackBar(
          context,
          'Task broken down by AI',
          backgroundColor: AppConstants.successColor,
        );
      });
    } catch (e) {
      AppHelpers.showSnackBar(
        context,
        'AI Error: $e',
        backgroundColor: AppConstants.errorColor,
      );
    } finally {
      setState(() {
        _isAILoading = false;
      });
    }
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveTask,
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(widget.task == null ? 'Add Task' : 'Update Task'),
      ),
    );
  }

  Future<void> _selectDueDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDueDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (date != null) {
      setState(() {
        _selectedDueDate = date;
      });
    }
  }

  Future<void> _saveTask() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final taskProvider = context.read<TaskProvider>();

      if (widget.task == null) {
        // Add new task
        final newTask = Task(
          id: AppHelpers.generateId(),
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          priority: _selectedPriority,
          dueDate: _selectedDueDate,
          createdAt: DateTime.now(),
          subtasks: _subtasks,
        );

        taskProvider.addTask(newTask);
        AppHelpers.showSnackBar(
          context,
          'Task added successfully',
          backgroundColor: AppConstants.successColor,
        );
      } else {
        // Update existing task
        final updatedTask = widget.task!.copyWith(
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          priority: _selectedPriority,
          dueDate: _selectedDueDate,
          subtasks: _subtasks,
        );

        taskProvider.updateTask(updatedTask);
        AppHelpers.showSnackBar(
          context,
          'Task updated successfully',
          backgroundColor: AppConstants.successColor,
        );
      }

      Navigator.of(context).pop();
    } catch (e) {
      AppHelpers.showSnackBar(
        context,
        'Error saving task: $e',
        backgroundColor: AppConstants.errorColor,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

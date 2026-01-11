import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../services/database_service.dart';
import '../services/ai_assistant_service.dart';

class TaskProvider with ChangeNotifier {
  final List<Task> _tasks = [];
  List<Task> _filteredTasks = [];
  String _searchQuery = '';
  Priority? _filterPriority;
  final DatabaseService _dbService = DatabaseService();
  final AIAssistantService _aiService = AIAssistantService();
  bool _isLoading = false;

  TaskProvider() {
    _loadTasks();
  }

  List<Task> get tasks => _filteredTasks;
  List<Task> get allTasks => _tasks;
  String get searchQuery => _searchQuery;
  Priority? get filterPriority => _filterPriority;
  bool get isLoading => _isLoading;

  int get completedTasksCount =>
      _tasks.where((task) => task.isCompleted).length;
  int get pendingTasksCount => _tasks.where((task) => !task.isCompleted).length;

  Future<void> _loadTasks() async {
    _isLoading = true;
    notifyListeners();
    _tasks.clear();
    _tasks.addAll(await _dbService.getTasks());
    _applyFilters();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTask(Task task) async {
    await _dbService.insertTask(task);
    _tasks.add(task);
    _applyFilters();
    notifyListeners();
  }

  Future<void> updateTask(Task updatedTask) async {
    final index = _tasks.indexWhere((task) => task.id == updatedTask.id);
    if (index != -1) {
      await _dbService.updateTask(updatedTask);
      _tasks[index] = updatedTask;
      _applyFilters();
      notifyListeners();
    }
  }

  Future<void> deleteTask(String taskId) async {
    await _dbService.deleteTask(taskId);
    _tasks.removeWhere((task) => task.id == taskId);
    _applyFilters();
    notifyListeners();
  }

  Future<void> toggleTaskCompletion(String taskId) async {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      final updatedTask = _tasks[index].copyWith(
        isCompleted: !_tasks[index].isCompleted,
      );
      await updateTask(updatedTask);
    }
  }

  // AI Features
  Future<void> breakdownTask(String taskId) async {
    final index = _tasks.indexWhere((task) => task.id == taskId);
    if (index != -1) {
      _isLoading = true;
      notifyListeners();
      try {
        final subtasks = await _aiService.breakdownTask(
          _tasks[index].title,
          _tasks[index].description,
        );
        final updatedTask = _tasks[index].copyWith(subtasks: subtasks);
        await updateTask(updatedTask);
      } catch (e) {
        debugPrint('AI Error: $e');
      } finally {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  Future<void> performAISearch(String query) async {
    _isLoading = true;
    notifyListeners();

    try {
      final resultMap = await _aiService.analyzeSearchQuery(query);
      final keywords = List<String>.from(resultMap['keywords'] ?? []);
      final priorityStr = resultMap['priority'] as String?;

      Priority? priority;
      if (priorityStr != null) {
        if (priorityStr.toLowerCase().contains('high'))
          priority = Priority.high;
        else if (priorityStr.toLowerCase().contains('medium'))
          priority = Priority.medium;
        else if (priorityStr.toLowerCase().contains('low'))
          priority = Priority.low;
      }

      _filteredTasks = _tasks.where((task) {
        final matchesKeywords =
            keywords.isEmpty ||
            keywords.any((k) {
              return task.title.toLowerCase().contains(k.toLowerCase()) ||
                  task.description.toLowerCase().contains(k.toLowerCase());
            });

        final matchesPriority = priority == null || task.priority == priority;

        return matchesKeywords && matchesPriority;
      }).toList();

      if (_filteredTasks.isEmpty && keywords.isEmpty && priority == null) {
        setSearchQuery(query);
      }
    } catch (e) {
      debugPrint('AI Search Error: $e');
      setSearchQuery(query);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  void setFilterPriority(Priority? priority) {
    _filterPriority = priority;
    _applyFilters();
    notifyListeners();
  }

  void _applyFilters() {
    _filteredTasks = _tasks.where((task) {
      final matchesSearch =
          _searchQuery.isEmpty ||
          task.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          task.description.toLowerCase().contains(_searchQuery.toLowerCase());

      final matchesPriority =
          _filterPriority == null || task.priority == _filterPriority;

      return matchesSearch && matchesPriority;
    }).toList();

    _filteredTasks.sort((a, b) {
      if (a.priority != b.priority) {
        return b.priority.index.compareTo(a.priority.index);
      }
      if (a.dueDate != null && b.dueDate != null) {
        return a.dueDate!.compareTo(b.dueDate!);
      }
      if (a.dueDate != null) return -1;
      if (b.dueDate != null) return 1;
      return a.createdAt.compareTo(b.createdAt);
    });
  }

  Future<void> clearCompletedTasks() async {
    final completedTaskIds = _tasks
        .where((t) => t.isCompleted)
        .map((t) => t.id)
        .toList();
    for (final id in completedTaskIds) {
      await _dbService.deleteTask(id);
    }
    _tasks.removeWhere((task) => task.isCompleted);
    _applyFilters();
    notifyListeners();
  }
}

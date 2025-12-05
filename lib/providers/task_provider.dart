import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/task.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];

  List<Task> get tasks => List.from(_tasks);
  List<Task> get completedTasks => _tasks.where((task) => task.isCompleted).toList();
  List<Task> get pendingTasks => _tasks.where((task) => !task.isCompleted).toList();
  List<Task> get highPriorityTasks => _tasks.where((task) => task.priority == 3 && !task.isCompleted).toList();

  TaskProvider() {
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksString = prefs.getString('tasks');

    if (tasksString != null && tasksString.isNotEmpty) {
      try {
        List<dynamic> decodedList = jsonDecode(tasksString);
        _tasks = decodedList.map((item) => Task.fromJson(item)).toList();
        notifyListeners();
      } catch (e) {
        print('Error loading tasks: $e');
        _tasks = [];
      }
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> tasksJson = _tasks.map((task) => task.toJson()).toList();
    await prefs.setString('tasks', jsonEncode(tasksJson));
  }

  void addTask(Task task) {
    _tasks.add(task);
    _saveTasks();
    notifyListeners();
  }

  void toggleTaskCompletion(String taskId) {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      _tasks[taskIndex].isCompleted = !_tasks[taskIndex].isCompleted;
      _saveTasks();
      notifyListeners();
    }
  }

  void deleteTask(String taskId) {
    _tasks.removeWhere((task) => task.id == taskId);
    _saveTasks();
    notifyListeners();
  }

  void updateTask(String taskId, Task updatedTask) {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      _tasks[taskIndex] = updatedTask;
      _saveTasks();
      notifyListeners();
    }
  }

  // Аналитика
  double get completionRate {
    if (_tasks.isEmpty) return 0.0;
    return (completedTasks.length / _tasks.length) * 100;
  }

  int get totalEstimatedTime {
    return pendingTasks.fold(0, (sum, task) => sum + task.estimatedMinutes);
  }

  Map<String, int> get tasksByCategory {
    Map<String, int> categoryCount = {};
    for (var task in _tasks) {
      categoryCount[task.category] = (categoryCount[task.category] ?? 0) + 1;
    }
    return categoryCount;
  }

  Map<String, int> get completedByCategory {
    Map<String, int> categoryCount = {};
    for (var task in completedTasks) {
      categoryCount[task.category] = (categoryCount[task.category] ?? 0) + 1;
    }
    return categoryCount;
  }
}
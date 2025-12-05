import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/task.dart';

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];

  List<Task> get tasks => _tasks;
  List<Task> get completedTasks => _tasks.where((task) => task.isCompleted).toList();
  List<Task> get pendingTasks => _tasks.where((task) => !task.isCompleted).toList();
  List<Task> get highPriorityTasks => _tasks.where((task) => task.priority == 3 && !task.isCompleted).toList();

  TaskProvider() {
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? tasksString = prefs.getString('tasks');

    if (tasksString != null) {
      try {
        List<dynamic> decodedList = _parseJsonList(tasksString);
        _tasks = decodedList.map((item) => Task.fromJson(item)).toList();
        notifyListeners();
      } catch (e) {
        print('Error loading tasks: $e');
      }
    }
  }

  List<dynamic> _parseJsonList(String jsonString) {
    // Простой парсинг JSON массива
    final cleanedString = jsonString.replaceAll(RegExp(r'[\n\t]'), '');
    if (cleanedString.startsWith('[') && cleanedString.endsWith(']')) {
      final content = cleanedString.substring(1, cleanedString.length - 1);
      if (content.isEmpty) return [];

      List<dynamic> result = [];
      final items = content.split('},{');
      for (int i = 0; i < items.length; i++) {
        String item = items[i];
        if (i == 0) item = '$item}';
        else if (i == items.length - 1) item = '{$item';
        else item = '{$item}';

        try {
          final map = _parseJsonObject(item);
          result.add(map);
        } catch (e) {
          print('Error parsing item: $e');
        }
      }
      return result;
    }
    return [];
  }

  Map<String, dynamic> _parseJsonObject(String jsonString) {
    final Map<String, dynamic> result = {};
    final pairs = jsonString.substring(1, jsonString.length - 1).split(',');

    for (final pair in pairs) {
      final index = pair.indexOf(':');
      if (index != -1) {
        String key = pair.substring(0, index).trim().replaceAll('"', '');
        String value = pair.substring(index + 1).trim().replaceAll('"', '');

        // Обработка разных типов данных
        if (value == 'true') {
          result[key] = true;
        } else if (value == 'false') {
          result[key] = false;
        } else if (double.tryParse(value) != null) {
          result[key] = int.tryParse(value) ?? double.parse(value);
        } else {
          result[key] = value;
        }
      }
    }
    return result;
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData = _tasks.map((task) => task.toJson()).toString();
    await prefs.setString('tasks', encodedData);
    notifyListeners();
  }

  void addTask(Task task) {
    _tasks.add(task);
    _saveTasks();
  }

  void toggleTaskCompletion(String taskId) {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      _tasks[taskIndex].isCompleted = !_tasks[taskIndex].isCompleted;
      _saveTasks();
    }
  }

  void deleteTask(String taskId) {
    _tasks.removeWhere((task) => task.id == taskId);
    _saveTasks();
  }

  void updateTask(String taskId, Task updatedTask) {
    final taskIndex = _tasks.indexWhere((task) => task.id == taskId);
    if (taskIndex != -1) {
      _tasks[taskIndex] = updatedTask;
      _saveTasks();
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
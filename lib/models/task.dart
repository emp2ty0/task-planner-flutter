import 'package:flutter/material.dart';

class Task {
  String id;
  String title;
  String description;
  DateTime createdAt;
  DateTime? deadline;
  bool isCompleted;
  String category;
  int priority; // 1-3, где 3 - высший приоритет
  int estimatedMinutes;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    required this.createdAt,
    this.deadline,
    this.isCompleted = false,
    this.category = 'Общие',
    this.priority = 2,
    this.estimatedMinutes = 30,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt.toIso8601String(),
      'deadline': deadline?.toIso8601String(),
      'isCompleted': isCompleted,
      'category': category,
      'priority': priority,
      'estimatedMinutes': estimatedMinutes,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      createdAt: DateTime.parse(json['createdAt']),
      deadline: json['deadline'] != null ? DateTime.parse(json['deadline']) : null,
      isCompleted: json['isCompleted'],
      category: json['category'],
      priority: json['priority'],
      estimatedMinutes: json['estimatedMinutes'],
    );
  }

  String get priorityText {
    switch (priority) {
      case 1: return 'Низкий';
      case 2: return 'Средний';
      case 3: return 'Высокий';
      default: return 'Средний';
    }
  }

  Color get priorityColor {
    switch (priority) {
      case 1: return Colors.green;
      case 2: return Colors.orange;
      case 3: return Colors.red;
      default: return Colors.orange;
    }
  }
}
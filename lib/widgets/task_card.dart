import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';

class TaskCard extends StatelessWidget {
  final Task task;

  const TaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          onChanged: (bool? value) {
            Provider.of<TaskProvider>(context, listen: false)
                .toggleTaskCompletion(task.id);
          },
        ),
        title: Text(
          task.title,
          style: TextStyle(
            decoration: task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
            fontWeight: task.priority == 3 ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty)
              Text(
                task.description,
                style: const TextStyle(fontSize: 12),
              ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 8.0,
              children: [
                Chip(
                  label: Text(task.category),
                  backgroundColor: Colors.blue[50],
                  labelStyle: const TextStyle(fontSize: 10),
                ),
                Chip(
                  label: Text(task.priorityText),
                  backgroundColor: task.priorityColor.withOpacity(0.2),
                  labelStyle: TextStyle(
                    fontSize: 10,
                    color: task.priorityColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (task.deadline != null)
                  Chip(
                    label: Text(
                      '${task.deadline!.day}.${task.deadline!.month}',
                    ),
                    backgroundColor: Colors.orange[50],
                    labelStyle: const TextStyle(fontSize: 10),
                  ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () {
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Удалить задачу?'),
                  content: Text('Вы уверены, что хотите удалить задачу "${task.title}"?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Отмена'),
                    ),
                    TextButton(
                      onPressed: () {
                        Provider.of<TaskProvider>(context, listen: false)
                            .deleteTask(task.id);
                        Navigator.pop(context);
                      },
                      child: const Text('Удалить', style: TextStyle(color: Colors.red)),
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
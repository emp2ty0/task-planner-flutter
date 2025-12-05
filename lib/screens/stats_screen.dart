import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final completionRate = taskProvider.completionRate;
    final totalTime = taskProvider.totalEstimatedTime;
    final tasksByCategory = taskProvider.tasksByCategory;
    final completedByCategory = taskProvider.completedByCategory;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Статистика продуктивности'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Основная статистика
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    const Text(
                      'Общая статистика',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatItem('Всего задач', taskProvider.tasks.length.toString()),
                        _buildStatItem('Выполнено', taskProvider.completedTasks.length.toString()),
                        _buildStatItem('В процессе', taskProvider.pendingTasks.length.toString()),
                      ],
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: completionRate / 100,
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        completionRate >= 70 ? Colors.green :
                        completionRate >= 40 ? Colors.orange : Colors.red,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Прогресс выполнения: ${completionRate.toStringAsFixed(1)}%',
                      style: const TextStyle(fontSize: 14),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Общее время выполнения: ${totalTime ~/ 60}ч ${totalTime % 60}мин',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Статистика по категориям
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Распределение по категориям',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    if (tasksByCategory.isEmpty)
                      const Text('Нет данных по категориям')
                    else
                      Column(
                        children: tasksByCategory.entries.map((entry) {
                          final completed = completedByCategory[entry.key] ?? 0;
                          final completionRate = entry.value > 0 ? (completed / entry.value * 100) : 0;

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(entry.key),
                                    Text('$completed/${entry.value}'),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                LinearProgressIndicator(
                                  value: completionRate / 100,
                                  backgroundColor: Colors.grey[300],
                                ),
                                Text(
                                  '${completionRate.toStringAsFixed(1)}% выполнено',
                                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Приоритеты
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Задачи по приоритетам',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildPriorityStats(taskProvider),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildPriorityStats(TaskProvider taskProvider) {
    final highPriority = taskProvider.tasks.where((t) => t.priority == 3).length;
    final mediumPriority = taskProvider.tasks.where((t) => t.priority == 2).length;
    final lowPriority = taskProvider.tasks.where((t) => t.priority == 1).length;

    return Column(
      children: [
        _buildPriorityRow('Высокий', highPriority, Colors.red),
        _buildPriorityRow('Средний', mediumPriority, Colors.orange),
        _buildPriorityRow('Низкий', lowPriority, Colors.green),
      ],
    );
  }

  Widget _buildPriorityRow(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(label)),
          Text('$count задач'),
        ],
      ),
    );
  }
}
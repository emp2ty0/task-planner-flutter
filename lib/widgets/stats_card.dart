import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';

class StatsCard extends StatelessWidget {
  const StatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final completionRate = taskProvider.completionRate;
    final totalTasks = taskProvider.tasks.length;
    final completedTasks = taskProvider.completedTasks.length;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCircle('Всего', totalTasks.toString(), Colors.blue),
                _buildStatCircle('Выполнено', completedTasks.toString(), Colors.green),
                _buildStatCircle('Прогресс', '${completionRate.toStringAsFixed(0)}%',
                    completionRate >= 70 ? Colors.green :
                    completionRate >= 40 ? Colors.orange : Colors.red),
              ],
            ),
            const SizedBox(height: 8),
            if (totalTasks > 0)
              LinearProgressIndicator(
                value: completionRate / 100,
                backgroundColor: Colors.grey[300],
                valueColor: AlwaysStoppedAnimation<Color>(
                  completionRate >= 70 ? Colors.green :
                  completionRate >= 40 ? Colors.orange : Colors.red,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCircle(String label, String value, Color color) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: Center(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}
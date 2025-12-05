import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../widgets/task_card.dart';
import '../widgets/stats_card.dart';
import 'add_task_screen.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const TaskListScreen(),
    const StatsOverviewScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Умный Планировщик Задач'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (_currentIndex == 0)
            IconButton(
              icon: const Icon(Icons.analytics),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StatsScreen()),
              ),
            ),
        ],
      ),
      body: _screens[_currentIndex],
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddTaskScreen()),
        ),
        child: const Icon(Icons.add),
      )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.list),
            label: 'Задачи',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics),
            label: 'Статистика',
          ),
        ],
      ),
    );
  }
}

class TaskListScreen extends StatelessWidget {
  const TaskListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);
    final pendingTasks = taskProvider.pendingTasks;
    final completedTasks = taskProvider.completedTasks;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Статистика в карточке
          const StatsCard(),

          const SizedBox(height: 20),

          // Задачи с высоким приоритетом
          if (taskProvider.highPriorityTasks.isNotEmpty) ...[
            const Text(
              'Высокий приоритет',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...taskProvider.highPriorityTasks.map((task) => TaskCard(task: task)),
            const SizedBox(height: 20),
          ],

          // Все задачи
          const Text(
            'Все задачи',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),

          if (pendingTasks.isEmpty && completedTasks.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  'Нет задач\nДобавьте первую задачу!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            )
          else
            Expanded(
              child: ListView(
                children: [
                  if (pendingTasks.isNotEmpty) ...[
                    ...pendingTasks.map((task) => TaskCard(task: task)),
                  ],

                  if (completedTasks.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'Выполненные',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                    const SizedBox(height: 10),
                    ...completedTasks.map((task) => TaskCard(task: task)),
                  ],
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class StatsOverviewScreen extends StatelessWidget {
  const StatsOverviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          const StatsCard(),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const StatsScreen()),
            ),
            child: const Text('Подробная статистика'),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task.dart';

class AddTaskScreen extends StatefulWidget {
  const AddTaskScreen({super.key});

  @override
  State<AddTaskScreen> createState() => _AddTaskScreenState();
}

class _AddTaskScreenState extends State<AddTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String _category = 'Общие';
  int _priority = 2;
  int _estimatedMinutes = 30;
  DateTime? _deadline;

  final List<String> _categories = [
    'Общие',
    'Работа',
    'Учеба',
    'Дом',
    'Здоровье',
    'Финансы'
  ];

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final newTask = Task(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        createdAt: DateTime.now(),
        deadline: _deadline,
        category: _category,
        priority: _priority,
        estimatedMinutes: _estimatedMinutes,
      );

      Provider.of<TaskProvider>(context, listen: false).addTask(newTask);
      Navigator.pop(context);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _deadline = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Добавить задачу'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Название задачи *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите название задачи';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Описание',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Категория',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() => _category = newValue!);
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _priority,
                      decoration: const InputDecoration(
                        labelText: 'Приоритет',
                        border: OutlineInputBorder(),
                      ),
                      items: [1, 2, 3].map((int priority) {
                        String text = '';
                        Color color = Colors.black;
                        switch (priority) {
                          case 1:
                            text = 'Низкий';
                            color = Colors.green;
                            break;
                          case 2:
                            text = 'Средний';
                            color = Colors.orange;
                            break;
                          case 3:
                            text = 'Высокий';
                            color = Colors.red;
                            break;
                        }
                        return DropdownMenuItem<int>(
                          value: priority,
                          child: Text(text, style: TextStyle(color: color)),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        setState(() => _priority = newValue!);
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _estimatedMinutes,
                      decoration: const InputDecoration(
                        labelText: 'Время (мин)',
                        border: OutlineInputBorder(),
                      ),
                      items: [15, 30, 45, 60, 90, 120].map((int minutes) {
                        return DropdownMenuItem<int>(
                          value: minutes,
                          child: Text('$minutes мин'),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        setState(() => _estimatedMinutes = newValue!);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Дедлайн',
                          border: OutlineInputBorder(),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _deadline != null
                                  ? '${_deadline!.day}.${_deadline!.month}.${_deadline!.year}'
                                  : 'Не установлен',
                            ),
                            const Icon(Icons.calendar_today),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (_deadline != null) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => setState(() => _deadline = null),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Добавить задачу'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
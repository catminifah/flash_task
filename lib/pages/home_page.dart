import 'package:flash_task/widgets/gradient_background.dart';
import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/api_service.dart';
import '../widgets/task_item.dart';
import 'task_form_page.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:uuid/uuid.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _api = ApiService();
  late Future<List<Task>> _tasksFuture;
  final TextEditingController _quickAddController = TextEditingController();
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _tasksFuture = _api.getTasks();
  }

  Future<void> _refreshTasks() async {
    setState(() {
      _tasksFuture = _api.getTasks();
    });
  }

  void _openAdd() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const TaskFormPage()),
    );
    if (result == true) _refreshTasks();
  }

  @override
  void dispose() {
    _quickAddController.dispose();
    super.dispose();
  }

  List<Task> _filterTasks(List<Task> tasks) {
    if (_searchText.trim().isEmpty) return tasks;
    final lower = _searchText.toLowerCase();
    return tasks.where((t) {
      final titleMatch = t.title.toLowerCase().contains(lower);
      final tagMatch = t.tag?.toLowerCase().contains(lower) ?? false;
      final priorityMatch = t.priority?.toLowerCase().contains(lower) ?? false;
      return titleMatch || tagMatch || priorityMatch;
    }).toList();
  }

  Future<void> _quickAddTask(String title) async {
    if (title.trim().isEmpty) return;
    final newTask = Task(
      id: const Uuid().v4(),
      title: title.trim(),
      description: '',
      createdAt: DateTime.now(),
      tag: null,
      priority: 'Medium',
      dueDate: null,
      status: 'To Do',
    );
    await _api.addTask(newTask);
    _quickAddController.clear();
    _refreshTasks();
  }

  Future<void> _updateTaskStatus(String taskId, String newStatus) async {
    try {
      final currentTasks = await _api.getTasks();
      final task = currentTasks.firstWhere((t) => t.id == taskId);
      final updatedTask = Task(
        id: task.id,
        title: task.title,
        description: task.description,
        createdAt: task.createdAt,
        tag: task.tag,
        priority: task.priority,
        dueDate: task.dueDate,
        status: newStatus,
      );
      await _api.updateTask(updatedTask);
      _refreshTasks();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Update status failed: $e')));
    }
  }

  Widget _buildHeader(List<Task> tasks) {
    final total = tasks.length;
    final high = tasks.where((t) => t.priority == 'High').length;
    final dueSoon = tasks.where((t) {
      final d = t.dueDate;
      if (d == null) return false;
      return d.isBefore(DateTime.now().add(const Duration(days: 3)));
    }).length;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Total',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$total',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text('High', style: TextStyle(color: Colors.grey.shade600)),
                    const SizedBox(height: 6),
                    Text(
                      '$high',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Due soon',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '$dueSoon',
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAdd() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _quickAddController,
              decoration: InputDecoration(
                hintText: 'Quick add task title',
                fillColor: Colors.white70,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onSubmitted: _quickAddTask,
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: const Color(0xFF8E7DBE),
            ),
            onPressed: () => _quickAddTask(_quickAddController.text),
            child: const Text('Add', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Search tasks by title, tag, or priority',
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.white70,
        ),
        onChanged: (val) {
          setState(() {
            _searchText = val;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GradientBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text('FlashTask'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.white,
          ),
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: SafeArea(
          child: FutureBuilder<List<Task>>(
            future: _tasksFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting)
                return const Center(child: CircularProgressIndicator());
              if (snapshot.hasError)
                return Center(child: Text('Error: ${snapshot.error}'));
              final tasks = snapshot.data ?? [];
              if (tasks.isEmpty)
                return Center(
                  child: Text(
                    'No tasks yet. Add one!',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                );
              final filteredTasks = _filterTasks(tasks);
              return RefreshIndicator(
                onRefresh: _refreshTasks,
                child: Column(
                  children: [
                    _buildQuickAdd(),
                    _buildSearchField(),
                    const SizedBox(height: 8),
                    _buildHeader(filteredTasks),
                    const SizedBox(height: 8),
                    Expanded(
                      child: GridView.builder(
                        padding: const EdgeInsets.all(8),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 8,
                              mainAxisSpacing: 8,
                              childAspectRatio: 0.8,
                            ),
                        itemCount: filteredTasks.length,
                        itemBuilder: (context, index) {
                          final task = filteredTasks[index];
                          return TaskItem(
                            task: task,
                            onRefresh: _refreshTasks,
                            onStatusChange: (newStatus) {
                              _updateTaskStatus(task.id, newStatus);
                            },
                            status: '${task.status}',
                          );
                        },
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        floatingActionButton: SpeedDial(
          icon: Icons.add,
          activeIcon: Icons.close,
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF8E7DBE),
          children: [
            SpeedDialChild(
              child: Icon(Icons.note_add),
              label: 'new task',
              onTap: _openAdd,
              backgroundColor: Color(0xFF8E7DBE),
              labelStyle: const TextStyle(color: Color(0xFF8E7DBE)),
              foregroundColor: Colors.white,
            ),
          ],
        ),
      ),
    );
  }
}

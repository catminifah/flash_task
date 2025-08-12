import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/api_service.dart';
import '../pages/task_form_page.dart';
import 'dart:math';

class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onRefresh;
  final ValueChanged<String> onStatusChange;
  final String status;

  TaskItem({
    required this.task,
    required this.onRefresh,
    required this.onStatusChange,
    required this.status,
    Key? key,
  }) : super(key: key);

  Color _priorityColor(String? p) {
    switch (p) {
      case 'High':
        return Colors.pinkAccent;
      case 'Medium':
        return Colors.blueAccent;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  final List<Color> noteColors = [
    //Color(0xFFFFF59D),
    Color(0xFFFFCC80),
    Color(0xFF80DEEA),
    Color(0xFFA5D6A7),
    Color(0xFFE1BEE7),
    Color(0xFFFFAB91),
  ];

  String _formatDue(DateTime? d) {
    if (d == null) return '';
    final now = DateTime.now();
    if (d.isBefore(now)) {
      return '${d.toLocal().toString().split(' ')[0]}';
    }
    return d.toLocal().toString().split(' ')[0];
  }

  void _deleteTask(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: Theme.of(context).colorScheme.surface,
        title: Row(
          children: [
            Icon(
              Icons.warning_amber_rounded,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(width: 8),
            Text(
              'Confirm delete',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete this item?',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurface.withOpacity(0.8),
          ),
        ),
        actionsPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      try {
        await ApiService().deleteTask(task.id);
        onRefresh();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Deleted')));
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Delete failed: $e')));
      }
    }
  }

  void _editTask(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => TaskFormPage(task: task)),
    );
    if (result == true) onRefresh();
  }

  @override
  Widget build(BuildContext context) {
    final randomColor = noteColors[Random().nextInt(noteColors.length)];

    return Dismissible(
      key: ValueKey(task.id),
      background: Container(
        color: Colors.redAccent,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) async {
        final ok = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Delete?'),
            content: const Text('Are you sure to delete this task?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Delete'),
              ),
            ],
          ),
        );
        return ok == true;
      },
      onDismissed: (_) =>
          ApiService().deleteTask(task.id).then((_) => onRefresh()),
      child: Container(
        decoration: BoxDecoration(
          color: randomColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  _formatDue(task.dueDate),
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.blueAccent,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.white, size: 15),
                  onPressed: () => _editTask(context),
                ),
              ],
            ),
            //const SizedBox(height: 6),
            // Task
            Text(
              task.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            //const SizedBox(height: 4),
            // Description
            if (task.description.isNotEmpty)
              SizedBox(
                height: 50,
                child: SingleChildScrollView(
                  child: Text(
                    task.description,
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ),
              ),
            const Spacer(),
            DropdownButton<String>(
              dropdownColor: Colors.white,
              value: task.status,
              items: [
                'To Do',
                'In Progress',
                'Done',
              ].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
              onChanged: (val) {
                if (val != null) {
                  onStatusChange(val);
                }
              },
            ),
            // Tag and Priority
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      if (task.tag != null && task.tag!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black12,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            task.tag!,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      if (task.tag != null && task.tag!.isNotEmpty)
                        const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: _priorityColor(
                            task.priority,
                          ).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          task.priority ?? 'No priority',
                          style: TextStyle(
                            fontSize: 12,
                            color: _priorityColor(task.priority),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

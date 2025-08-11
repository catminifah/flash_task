import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../services/api_service.dart';
import '../pages/task_form_page.dart';

class TaskItem extends StatelessWidget {
  final Task task;
  final VoidCallback onRefresh;

  TaskItem({super.key, required this.task, required this.onRefresh});

  Color _priorityColor(String? p) {
    switch (p) {
      case 'High':
        return Colors.redAccent;
      case 'Medium':
        return Colors.orangeAccent;
      case 'Low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  final List<Color> noteColors = [
    Color(0xFFEE6F57),
    Color(0xFFF3A712),
    Color(0xFF00A8E8),
    Color(0xFFA2D2FF),
    Color(0xFFFBC4AB),
    Color(0xFFD0E6A5),
  ];

  String _formatDue(DateTime? d) {
    if (d == null) return 'No due';
    final now = DateTime.now();
    if (d.isBefore(now))
      return 'Overdue ${d.toLocal().toString().split('.')[0]}';
    return d.toLocal().toString().split('.')[0];
  }

  void _deleteTask(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirm delete'),
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
    final randomColor = (noteColors..shuffle()).first;

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
      child: Card(
        color: (noteColors..shuffle()).first,
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          onTap: () => _editTask(context),
          title: Text(
            task.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (task.description.isNotEmpty)
                Text(
                  task.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.white),
                ),
              const SizedBox(height: 6),
              Row(
                children: [
                  if (task.tag != null && task.tag!.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        task.tag!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      task.priority ?? 'No priority',
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              if (task.dueDate != null)
                Row(
                  children: [
                    const Spacer(),
                    Text(
                      _formatDue(task.dueDate),
                      style: const TextStyle(fontSize: 12, color: Colors.white),
                    ),
                  ],
                ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onPressed: () => _editTask(context),
          ),
        ),
      ),
    );
  }
}

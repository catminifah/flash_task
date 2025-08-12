class Task {
  final String id;
  final String title;
  final String description;
  final DateTime createdAt;
  final String? tag;
  final String? priority;
  final DateTime? dueDate;
  final String status;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.createdAt,
    this.tag,
    this.priority,
    this.dueDate,
    this.status = 'To Do',
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      tag: json['tag'] as String?,
      priority: json['priority'] as String?,
      dueDate: json['due_date'] == null || json['due_date'] == ''
          ? null
          : DateTime.tryParse(json['due_date'] as String),
      status: json['status'] as String? ?? 'To Do',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'created_at': createdAt.toIso8601String(),
      'tag': tag ?? '',
      'priority': priority ?? '',
      'due_date': dueDate?.toIso8601String() ?? '',
      'status': status,
    };
  }
}

class Task {
  final String id;
  String title;
  String description;
  bool completed;
  String priority; // 'low', 'medium', 'high'
  DateTime createdAt;
  DateTime? dueDate;

  Task({
    required this.id,
    required this.title,
    this.description = '',
    this.completed = false,
    this.priority = 'medium',
    required this.createdAt,
    this.dueDate,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'completed': completed,
        'priority': priority,
        'createdAt': createdAt.toIso8601String(),
        'dueDate': dueDate?.toIso8601String(),
      };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
        id: json['id'],
        title: json['title'],
        description: json['description'] ?? '',
        completed: json['completed'] ?? false,
        priority: json['priority'] ?? 'medium',
        createdAt: DateTime.parse(json['createdAt']),
        dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      );
}

class Challenge {
  final String id;
  final String title;
  final String description;
  bool isCompleted;
  final DateTime timestamp;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.isCompleted,
    required this.timestamp,
  });

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      isCompleted: json['isCompleted'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}

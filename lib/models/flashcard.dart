class Flashcard {
  final String id;
  String question;
  String answer;
  String subject;
  int difficulty; // 1-3
  DateTime createdAt;

  Flashcard({
    required this.id,
    required this.question,
    required this.answer,
    this.subject = 'General',
    this.difficulty = 1,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'question': question,
        'answer': answer,
        'subject': subject,
        'difficulty': difficulty,
        'createdAt': createdAt.toIso8601String(),
      };

  factory Flashcard.fromJson(Map<String, dynamic> json) => Flashcard(
        id: json['id'],
        question: json['question'],
        answer: json['answer'],
        subject: json['subject'] ?? 'General',
        difficulty: json['difficulty'] ?? 1,
        createdAt: DateTime.parse(json['createdAt']),
      );
}

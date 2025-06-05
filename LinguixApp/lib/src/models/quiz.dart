class Quiz {
  final String question;
  final List<String> options;
  final String correct;
  final String category; // Add category field

  Quiz({
    required this.question,
    required this.options,
    required this.correct,
    required this.category,
  });

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options,
      'correct': correct,
      'category': category,
    };
  }
}
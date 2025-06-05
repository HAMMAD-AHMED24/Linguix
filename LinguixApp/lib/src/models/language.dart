class Language {
  final String query;
  final String translateTo;
  final String translation;
  final int status;
  final String message;
  final String? category;

  Language({
    required this.query,
    required this.translateTo,
    required this.translation,
    required this.status,
    required this.message,
    this.category,
  });
}
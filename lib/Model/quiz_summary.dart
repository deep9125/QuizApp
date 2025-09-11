class AdminQuizSummary {
  final String id;
  String title;
  String category;
  int questionCount;
  bool hasTimer;
  bool isRandomized;

  AdminQuizSummary({
    required this.id,
    required this.title,
    required this.category,
    this.questionCount = 0,
    this.hasTimer = false,
    this.isRandomized = false,
  });
}

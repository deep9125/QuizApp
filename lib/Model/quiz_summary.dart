class ManagerQuizSummary {
  final String id;
  String title;
  String description; // Added description
  String category;
  int questionCount;
  bool hasTimer;
  int? timerSeconds;   // Added timer duration in seconds (nullable)
  bool isRandomized;

  ManagerQuizSummary({
    required this.id,
    required this.title,
    this.description = '', // Optional with a default empty value
    required this.category,
    this.questionCount = 0,
    this.hasTimer = false,
    this.timerSeconds,     // Optional and nullable
    this.isRandomized = false,
  });
}
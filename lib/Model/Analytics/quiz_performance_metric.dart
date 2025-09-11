// lib/models/analytics/quiz_performance_metric.dart

class QuizPerformanceMetric {
  final String quizId;
  final String quizTitle;
  final int attempts;
  final double averageScore; // Expected to be 0-100
  final int totalQuestions;
  final Map<String, int> mostIncorrectAnswers; // Question Text -> Times Incorrect

  QuizPerformanceMetric({
    required this.quizId,
    required this.quizTitle,
    required this.attempts,
    required this.averageScore,
    required this.totalQuestions,
    this.mostIncorrectAnswers = const {}, // Default to an empty map
  });

  // Optional: Factory constructor for JSON deserialization
  factory QuizPerformanceMetric.fromJson(Map<String, dynamic> json) {
    return QuizPerformanceMetric(
      quizId: json['quizId'] as String,
      quizTitle: json['quizTitle'] as String,
      attempts: json['attempts'] as int,
      averageScore: (json['averageScore'] as num).toDouble(),
      totalQuestions: json['totalQuestions'] as int,
      mostIncorrectAnswers: Map<String, int>.from(json['mostIncorrectAnswers'] as Map? ?? {}),
    );
  }

  // Optional: Method for JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'quizId': quizId,
      'quizTitle': quizTitle,
      'attempts': attempts,
      'averageScore': averageScore,
      'totalQuestions': totalQuestions,
      'mostIncorrectAnswers': mostIncorrectAnswers,
    };
  }
}

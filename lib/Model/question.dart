// lib/models/admin_question.dart

// Enum for the different types of questions
enum QuestionType {
  multipleChoice,
  trueFalse,
  fillInBlank,
  numeric, // Assuming you might have a numeric input type
  // Add other types as needed
}

// Model class for an Admin Question
class ManagerQuestion {
  final String id; // Unique identifier for the question
  final String quizId; // To link this question to a specific quiz
  String text; // The question text itself
  QuestionType type; // The type of question (e.g., multipleChoice, trueFalse)
  List<String> options; // List of options for multipleChoice, empty for others
  String correctAnswer; // The correct answer
  // You could add other fields like points, explanation, difficulty, etc.

  ManagerQuestion({
    required this.id,
    required this.quizId,
    required this.text,
    required this.type,
    this.options = const [], // Default to an empty list if not provided
    required this.correctAnswer,
  });

// Optional: Add a factory constructor for JSON serialization/deserialization if needed later
// factory AdminQuestion.fromJson(Map<String, dynamic> json) { ... }
// Map<String, dynamic> toJson() { ... }

// Optional: Add a copyWith method for easier updating of immutable instances if you prefer
// AdminQuestion copyWith({ ... }) { ... }
}

// Helper function to get a display string for QuestionType (optional, can also be in UI)
String getQuestionTypeDisplayString(QuestionType type) {
  switch (type) {
    case QuestionType.multipleChoice:
      return 'Multiple Choice';
    case QuestionType.trueFalse:
      return 'True/False';
    case QuestionType.fillInBlank:
      return 'Fill in the Blank';
    case QuestionType.numeric:
      return 'Numeric Input';
    default:
      return 'Unknown Type';
  }
}

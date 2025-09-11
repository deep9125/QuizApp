// lib/services/mock_quiz_service.dart

import 'dart:math'; // For Random ID generation

// --- Data Models (Make sure these are defined, e.g., in a lib/models/ folder) ---
// These are the ONLY definitions that should be used.
import '../Model/question.dart';    // Should define AdminQuestion and QuestionType
import '../Model/quiz_summary.dart'; // Should define AdminQuizSummary with hasTimer & isRandomized

// CRITICAL: Ensure NO OTHER definitions of AdminQuizSummary, AdminQuestion, or QuestionType
// exist in THIS FILE or are being accidentally imported from somewhere else.

class MockQuizService {
  final Random _random = Random();

  // --- Mock Quiz Data ---
  // Ensure we are calling the constructor from the imported '../model/quiz_summary.dart'
  // which includes hasTimer and isRandomized.
  final List<AdminQuizSummary> _mockQuizzes = [
    AdminQuizSummary( // This MUST call the constructor with all required fields
        id: 'q1',
        title: 'Flutter Basics',
        category: 'Programming',
        questionCount: 2, // This will be updated later if needed
        hasTimer: true,     // Explicitly provide this
        isRandomized: false // Explicitly provide this
    ),
    AdminQuizSummary(
        id: 'q2',
        title: 'World Capitals',
        category: 'Geography',
        questionCount: 1,
        hasTimer: false,    // Explicitly provide this
        isRandomized: true  // Explicitly provide this
    ),
    AdminQuizSummary(
        id: 'q3',
        title: 'Basic Math',
        category: 'Mathematics',
        questionCount: 0,
        hasTimer: true,     // Explicitly provide this
        isRandomized: false // Explicitly provide this
    ),
  ];

  // --- Mock Question Data ---
  // Ensure AdminQuestion and QuestionType are from the imported ../model/question.dart
  final List<AdminQuestion> _mockQuestions = [
    AdminQuestion(quizId: 'q1', id: 'q1_qus1', text: 'What is the widget used for layout in Flutter?', type: QuestionType.multipleChoice, options: ['Container', 'Text', 'Column', 'Scaffold'], correctAnswer: 'Column'),
    AdminQuestion(quizId: 'q1', id: 'q1_qus2', text: 'Is Dart statically typed?', type: QuestionType.trueFalse, correctAnswer: 'True'),
    AdminQuestion(quizId: 'q2', id: 'q2_qus1', text: 'What is the capital of Japan?', type: QuestionType.fillInBlank, correctAnswer: 'Tokyo'),
  ];

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + _random.nextInt(9999).toString();
  }

  // --- Quiz Methods ---

  Future<List<AdminQuizSummary>> getAdminQuizzes() async {
    await Future.delayed(const Duration(milliseconds: 300));
    for (var quiz in _mockQuizzes) {
      quiz.questionCount = _mockQuestions.where((q) => q.quizId == quiz.id).length;
      // The objects in _mockQuizzes were created with hasTimer/isRandomized,
      // so they should be correct here.
    }
    return List.from(_mockQuizzes);
  }

  Future<AdminQuizSummary?> getAdminQuizById(String quizId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      // Ensure the object returned is the one with hasTimer/isRandomized
      return _mockQuizzes.firstWhere((quiz) => quiz.id == quizId);
    } catch (e) {
      return null;
    }
  }

  // Ensure this uses the constructor from the imported AdminQuizSummary model
  Future<AdminQuizSummary> addAdminQuiz({
    required String title,
    required String category,
    bool hasTimer = false, // Default if not provided
    bool isRandomized = false, // Default if not provided
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newQuiz = AdminQuizSummary( // This MUST call the full constructor
      id: 'q_${_generateId()}',
      title: title,
      category: category,
      questionCount: 0,
      hasTimer: hasTimer,         // Explicitly use this
      isRandomized: isRandomized, // Explicitly use this
    );
    _mockQuizzes.add(newQuiz);
    return newQuiz;
  }

  // Ensure this updates the properties of the correct AdminQuizSummary object
  Future<AdminQuizSummary?> updateAdminQuiz(
      String quizId, {
        String? title,
        String? category,
        bool? hasTimer,
        bool? isRandomized,
      }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final quizIndex = _mockQuizzes.indexWhere((quiz) => quiz.id == quizId);
    if (quizIndex != -1) {
      final quizToUpdate = _mockQuizzes[quizIndex]; // This is the object from _mockQuizzes

      // Update properties
      if (title != null) quizToUpdate.title = title;
      if (category != null) quizToUpdate.category = category;
      if (hasTimer != null) quizToUpdate.hasTimer = hasTimer;
      if (isRandomized != null) quizToUpdate.isRandomized = isRandomized;

      return quizToUpdate;
    }
    return null;
  }

  Future<bool> deleteAdminQuiz(String quizId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockQuizzes.removeWhere((quiz) => quiz.id == quizId);
    _mockQuestions.removeWhere((question) => question.quizId == quizId);
    return true;
  }

  // --- Question Methods --- (Assumed to be correct if using imported models)
  Future<List<AdminQuestion>> getQuestionsForQuiz(String quizId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_mockQuestions.where((q) => q.quizId == quizId));
  }

  Future<AdminQuestion?> getQuestionById(String questionId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _mockQuestions.firstWhere((q) => q.id == questionId);
    } catch (e) {
      return null;
    }
  }

  Future<AdminQuestion> addQuestionToQuiz({
    required String quizId,
    required String text,
    required QuestionType type,
    List<String> options = const [],
    required String correctAnswer,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newQuestion = AdminQuestion( // Ensure this uses the imported AdminQuestion model
      id: 'qus_${_generateId()}',
      quizId: quizId,
      text: text,
      type: type, // Ensure this uses the imported QuestionType enum
      options: options,
      correctAnswer: correctAnswer,
    );
    _mockQuestions.add(newQuestion);
    final quizIndex = _mockQuizzes.indexWhere((q) => q.id == quizId);
    if (quizIndex != -1) {
      _mockQuizzes[quizIndex].questionCount = _mockQuestions.where((q) => q.quizId == quizId).length;
    }
    return newQuestion;
  }

  Future<AdminQuestion?> updateQuestion(AdminQuestion updatedQuestion) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final questionIndex = _mockQuestions.indexWhere((q) => q.id == updatedQuestion.id);
    if (questionIndex != -1) {
      _mockQuestions[questionIndex] = updatedQuestion;
      return updatedQuestion;
    }
    return null;
  }

  Future<bool> deleteQuestion(String questionId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    String? quizIdOfDeletedQuestion;
    final originalLength = _mockQuestions.length;
    _mockQuestions.removeWhere((q) {
      if (q.id == questionId) {
        quizIdOfDeletedQuestion = q.quizId;
        return true;
      }
      return false;
    });
    if (quizIdOfDeletedQuestion != null && _mockQuestions.length < originalLength) {
      final quizIndex = _mockQuizzes.indexWhere((q) => q.id == quizIdOfDeletedQuestion);
      if (quizIndex != -1) {
        _mockQuizzes[quizIndex].questionCount = _mockQuestions.where((q) => q.quizId == quizIdOfDeletedQuestion).length;
      }
      return true;
    }
    return false;
  }
}

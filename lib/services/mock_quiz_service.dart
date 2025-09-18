// lib/services/mock_quiz_service.dart

import 'dart:math';
import '../Model/question.dart';
import '../Model/quiz_summary.dart';

class MockQuizService {
  final Random _random = Random();

  final List<ManagerQuizSummary> _mockQuizzes = [
    ManagerQuizSummary(
        id: 'q1',
        title: 'Flutter Basics',
        category: 'Programming',
        questionCount: 2,
        hasTimer: true,
        isRandomized: false,
        timerSeconds: 120,
        description: 'Test your knowledge of Flutter fundamentals.'),
    ManagerQuizSummary(
        id: 'q2',
        title: 'World Capitals',
        category: 'Geography',
        questionCount: 1,
        hasTimer: false,
        isRandomized: true),
    ManagerQuizSummary(
        id: 'q3',
        title: 'Basic Math',
        category: 'Mathematics',
        questionCount: 0,
        hasTimer: true,
        isRandomized: false,
        timerSeconds: 60),
  ];

  final List<ManagerQuestion> _mockQuestions = [
    ManagerQuestion(quizId: 'q1', id: 'q1_qus1', text: 'What is the widget used for layout in Flutter?', type: QuestionType.multipleChoice, options: ['Container', 'Text', 'Column', 'Scaffold'], correctAnswer: '2'),
    ManagerQuestion(quizId: 'q1', id: 'q1_qus2', text: 'Is Dart statically typed?', type: QuestionType.trueFalse, correctAnswer: 'true'),
    ManagerQuestion(quizId: 'q2', id: 'q2_qus1', text: 'What is the capital of Japan?', type: QuestionType.fillInBlank, correctAnswer: 'Tokyo'),
  ];

  String _generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString() + _random.nextInt(9999).toString();
  }

  // --- Quiz Methods ---

  // CHANGED: Renamed method
  Future<List<ManagerQuizSummary>> getManagerQuizzes() async {
    await Future.delayed(const Duration(milliseconds: 300));
    for (var quiz in _mockQuizzes) {
      quiz.questionCount = _mockQuestions.where((q) => q.quizId == quiz.id).length;
    }
    return List.from(_mockQuizzes);
  }

  // CHANGED: Renamed method
  Future<ManagerQuizSummary?> getManagerQuizById(String quizId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    try {
      return _mockQuizzes.firstWhere((quiz) => quiz.id == quizId);
    } catch (e) {
      return null;
    }
  }

  // CHANGED: Renamed method
  Future<ManagerQuizSummary> addManagerQuiz({
    required String title,
    required String description,
    required String category,
    bool hasTimer = false,
    int? timerSeconds,
    bool isRandomized = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final newQuiz = ManagerQuizSummary(
      id: 'q_${_generateId()}',
      title: title,
      description: description,
      category: category,
      questionCount: 0,
      hasTimer: hasTimer,
      timerSeconds: timerSeconds,
      isRandomized: isRandomized,
    );
    _mockQuizzes.add(newQuiz);
    return newQuiz;
  }

  // CHANGED: Renamed method
  Future<ManagerQuizSummary?> updateManagerQuiz(ManagerQuizSummary updatedQuiz) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final quizIndex = _mockQuizzes.indexWhere((quiz) => quiz.id == updatedQuiz.id);
    if (quizIndex != -1) {
      _mockQuizzes[quizIndex] = updatedQuiz;
      return updatedQuiz;
    }
    return null;
  }

  // CHANGED: Renamed method
  Future<bool> deleteManagerQuiz(String quizId) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockQuizzes.removeWhere((quiz) => quiz.id == quizId);
    _mockQuestions.removeWhere((question) => question.quizId == quizId);
    return true;
  }

  // --- Question Methods --- (These are generic and do not need renaming)

  Future<List<ManagerQuestion>> getQuestionsForQuiz(String quizId) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_mockQuestions.where((q) => q.quizId == quizId));
  }

  Future<ManagerQuestion> addQuestionToQuiz(String quizId, ManagerQuestion newQuestion) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _mockQuestions.add(newQuestion);
    // Update question count
    final quizIndex = _mockQuizzes.indexWhere((q) => q.id == quizId);
    if (quizIndex != -1) {
      _mockQuizzes[quizIndex].questionCount++;
    }
    return newQuestion;
  }

  Future<ManagerQuestion?> updateQuestion(ManagerQuestion updatedQuestion) async {
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
    // Find the quizId before deleting the question to update the count
    String? quizIdOfDeletedQuestion;
    try {
        quizIdOfDeletedQuestion = _mockQuestions.firstWhere((q) => q.id == questionId).quizId;
    } catch (e) {
        // Question not found
        return false;
    }
    
    _mockQuestions.removeWhere((q) => q.id == questionId);

    // Update question count
    final quizIndex = _mockQuizzes.indexWhere((q) => q.id == quizIdOfDeletedQuestion);
    if (quizIndex != -1) {
      _mockQuizzes[quizIndex].questionCount--;
    }
    return true;
  }
}
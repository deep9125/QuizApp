// lib/Model/quiz_attempt.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class QuizAttempt {
  final String quizId;
  final String quizTitle;
  final int score;
  final int totalQuestions;
  final DateTime completedAt;

  QuizAttempt({
    required this.quizId,
    required this.quizTitle,
    required this.score,
    required this.totalQuestions,
    required this.completedAt,
  });

  factory QuizAttempt.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return QuizAttempt(
      quizId: data['quizId'] ?? '',
      quizTitle: data['quizTitle'] ?? 'Untitled Quiz',
      score: data['score'] ?? 0,
      totalQuestions: data['totalQuestions'] ?? 0,
      completedAt: (data['completedAt'] as Timestamp).toDate(),
    );
  }
}
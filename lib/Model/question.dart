// lib/models/question.dart
import 'package:cloud_firestore/cloud_firestore.dart';

// Enum for the different types of questions
enum QuestionType {
  multipleChoice,
  trueFalse,
  fillInBlank,
  numeric,
}

// Model class for a Manager Question
class ManagerQuestion {
  final String id;
  final String quizId;
  String text;
  QuestionType type;
  List<String> options;
  String correctAnswer;

  ManagerQuestion({
    required this.id,
    required this.quizId,
    required this.text,
    required this.type,
    this.options = const [],
    required this.correctAnswer,
  });

  // ADDED: A factory constructor to create a ManagerQuestion from a Firestore document.
  factory ManagerQuestion.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ManagerQuestion(
      id: doc.id,
      quizId: data['quizId'] ?? '',
      text: data['text'] ?? '',
      // Convert the string from Firestore back to an enum
      type: QuestionType.values.firstWhere(
        (e) => e.name == data['type'],
        orElse: () => QuestionType.multipleChoice // Default value if not found
      ),
      // Safely convert list from dynamic to String
      options: List<String>.from(data['options'] ?? []),
      correctAnswer: data['correctAnswer'] ?? '',
    );
  }

  // ADDED: A method to convert the ManagerQuestion object to a Map for Firestore.
  Map<String, dynamic> toFirestoreMap({String? newId}) {
    return {
      'id': newId ?? id, // Use the new ID if provided (for adding new questions)
      'quizId': quizId,
      'text': text,
      'type': type.name, // Store the enum as a string
      'options': options,
      'correctAnswer': correctAnswer,
    };
  }
}
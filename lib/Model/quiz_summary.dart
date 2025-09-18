// In your ManagerQuizSummary class
import 'package:cloud_firestore/cloud_firestore.dart';

class ManagerQuizSummary {
  final String id;
  String title;
  String description;
  String category;
  int questionCount;
  bool hasTimer;
  int? timerSeconds;
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

  // ADD THIS FACTORY CONSTRUCTOR
  factory ManagerQuizSummary.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ManagerQuizSummary(
      id: doc.id,
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      category: data['category'] ?? '',
      questionCount: data['questionCount'] ?? 0,
      hasTimer: data['hasTimer'] ?? false,
      timerSeconds: data['timerSeconds'], // Can be null
      isRandomized: data['isRandomized'] ?? false,
    );
  }

  // ADD THIS METHOD
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'category': category,
      'questionCount': questionCount,
      'hasTimer': hasTimer,
      'timerSeconds': timerSeconds,
      'isRandomized': isRandomized,
    };
  }
}
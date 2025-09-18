// lib/Model/quiz_user.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class QuizUser {
  final String uid;
  final String email;
  final int rewards;

  QuizUser({
    required this.uid,
    required this.email,
    required this.rewards,
  });

  factory QuizUser.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return QuizUser(
      uid: doc.id,
      email: data['email'] ?? 'No Email',
      rewards: data['rewards'] ?? 0,
    );
  }
}
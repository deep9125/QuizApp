// services/manager_quiz_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Model/question.dart';
import '../Model/quiz_summary.dart';

class ManagerQuizService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // A reference to the top-level 'quizzes' collection
  late final CollectionReference<ManagerQuizSummary> _quizzesRef;

  ManagerQuizService() {
    _quizzesRef = _firestore.collection('quizzes').withConverter<ManagerQuizSummary>(
          fromFirestore: (snapshot, _) => ManagerQuizSummary.fromFirestore(snapshot),
          toFirestore: (quiz, _) => quiz.toFirestore(),
        );
  }
  
  // --- Quiz Methods ---

  Future<List<ManagerQuizSummary>> getManagerQuizzes() async {
    final snapshot = await _quizzesRef.get();
    return snapshot.docs.map((doc) => doc.data()).toList();
  }

  Future<void> addManagerQuiz(ManagerQuizSummary quiz) async {
    await _quizzesRef.add(quiz);
  }

  Future<void> updateManagerQuiz(ManagerQuizSummary quiz) async {
    await _quizzesRef.doc(quiz.id).update(quiz.toFirestore());
  }
  
  Future<void> deleteManagerQuiz(String quizId) async {
    // Firestore doesn't delete subcollections automatically.
    // We must delete all questions first.
    final questionsSnapshot = await _quizzesRef.doc(quizId).collection('questions').get();
    for (var doc in questionsSnapshot.docs) {
      await doc.reference.delete();
    }
    // Then, delete the main quiz document
    await _quizzesRef.doc(quizId).delete();
  }

  // --- Question Methods ---

  Future<List<ManagerQuestion>> getQuestionsForQuiz(String quizId) async {
    // Assuming ManagerQuestion has a fromFirestore method
    final snapshot = await _quizzesRef.doc(quizId).collection('questions').get();
    return snapshot.docs.map((doc) => ManagerQuestion.fromFirestore(doc)).toList();
  }

  Future<void> addQuestionToQuiz(String quizId, ManagerQuestion question) async {
    // Add the question to the subcollection
    final newQuestionRef = _quizzesRef.doc(quizId).collection('questions').doc();
    // Assuming ManagerQuestion has a toFirestoreMap method
    await newQuestionRef.set(question.toFirestoreMap(newId: newQuestionRef.id));
    
    // IMPORTANT: Update the questionCount on the parent quiz document
    await _quizzesRef.doc(quizId).update({'questionCount': FieldValue.increment(1)});
  }

  Future<void> updateQuestion(ManagerQuestion question) async {
    await _quizzesRef.doc(question.quizId).collection('questions').doc(question.id).update(question.toFirestoreMap());
  }

  Future<void> deleteQuestion(String quizId, String questionId) async {
    await _quizzesRef.doc(quizId).collection('questions').doc(questionId).delete();
    // IMPORTANT: Update the questionCount
    await _quizzesRef.doc(quizId).update({'questionCount': FieldValue.increment(-1)});
  }
}
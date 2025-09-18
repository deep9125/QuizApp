// services/user_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Model/quiz_summary.dart';
import '../Model/question.dart';
import '../Model/reward_item.dart';
import '../Model/quiz_attempt.dart';
import '../Model/quiz_user.dart';
class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // A reference to the quizzes collection, using the model converter
  late final CollectionReference<ManagerQuizSummary> _quizzesRef;

  UserService() {
    _quizzesRef = _firestore.collection('quizzes').withConverter<ManagerQuizSummary>(
          fromFirestore: (snapshot, _) => ManagerQuizSummary.fromFirestore(snapshot),
          toFirestore: (quiz, _) => quiz.toFirestore(),
        );
  }
  Future<List<RewardItem>> getRewardItems() async {
    try {
      final snapshot = await _firestore.collection('rewards_store').get();
      return snapshot.docs.map((doc) => RewardItem.fromFirestore(doc)).toList();
    } catch (e) {
      print("Error fetching reward items: $e");
      return [];
    }
  }

  /// Attempts to redeem a reward item for a user.
  /// Returns true on success, false on failure (e.g., not enough points).
  Future<bool> redeemReward(String userId, RewardItem item) async {
    final userRef = _firestore.collection('users').doc(userId);

    // Use a Firestore transaction for safety. This ensures that we check the user's
    // balance and deduct points in a single, atomic operation.
    return _firestore.runTransaction((transaction) async {
      final userSnapshot = await transaction.get(userRef);
      if (!userSnapshot.exists) {
        throw Exception("User does not exist!");
      }

      final currentRewards = userSnapshot.data()!['rewards'] ?? 0;

      if (currentRewards >= item.cost) {
        // User has enough points. Deduct the cost.
        transaction.update(userRef, {
          'rewards': FieldValue.increment(-item.cost)
        });

        // (Optional) Add a record of the redemption to the user's rewards_log
        final logRef = userRef.collection('rewards_log').doc();
        transaction.set(logRef, {
          'amount': -item.cost,
          'reason': 'Redeemed: ${item.itemName}',
          'timestamp': FieldValue.serverTimestamp(),
        });
        
        return true; // Success
      } else {
        // User does not have enough points.
        return false; // Failure
      }
    });
  }
  // --- METHODS FOR USERS ---

  /// Fetches all available quizzes for a user to take.
  Future<List<ManagerQuizSummary>> getAvailableQuizzes() async {
    try {
      final snapshot = await _quizzesRef.get();
      return snapshot.docs.map((doc) => doc.data()).toList();
    } catch (e) {
      print("Error fetching quizzes: $e");
      return [];
    }
  }

  /// Fetches all questions for a specific quiz.
  Future<List<ManagerQuestion>> getQuestionsForQuiz(String quizId) async {
    try {
      // Assuming ManagerQuestion has a fromFirestore method
      final snapshot = await _quizzesRef.doc(quizId).collection('questions').get();
      return snapshot.docs.map((doc) => ManagerQuestion.fromFirestore(doc)).toList();
    } catch (e) {
      print("Error getting questions: $e");
      return [];
    }
  }
  Future<List<QuizAttempt>> getUserQuizHistory(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('quiz_attempts')
          .where('userId', isEqualTo: userId)
          .orderBy('completedAt', descending: true) // Show most recent first
          .get();
      return snapshot.docs.map((doc) => QuizAttempt.fromFirestore(doc)).toList();
    } catch (e) {
      print("Error fetching quiz history: $e");
      return [];
    }
  }
  Future<List<QuizUser>> getLeaderboardUsers() async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .orderBy('rewards', descending: true)
          .limit(50) // Get the top 50 users
          .get();
      return snapshot.docs.map((doc) => QuizUser.fromFirestore(doc)).toList();
    } catch (e) {
      print("Error fetching leaderboard: $e");
      return [];
    }
  }
  /// Saves the user's quiz result to the 'quiz_attempts' collection.
  /// THIS IS THE METHOD THAT CREATES THE DATA FOR YOUR ANALYTICS.
  Future<void> submitQuizAttempt({
    required String quizId,
    required String quizTitle,
    required String userId,
    required int score,
    required int totalQuestions,
  }) async {
    try {
      final userRef = _firestore.collection('users').doc(userId);
      final attemptsRef = _firestore.collection('quiz_attempts');

      // --- NEW REWARD LOGIC ---
      // 1. Check if the user has attempted this quiz before.
      final existingAttempt = await attemptsRef
          .where('userId', isEqualTo: userId)
          .where('quizId', isEqualTo: quizId)
          .limit(1) // We only need to know if at least one exists
          .get();

      // 2. If the query returns no documents, it's their first time!
      if (existingAttempt.docs.isEmpty) {
        // Let's say the reward is equal to the number of correct answers.
        final int rewardAmount = score; 
        
        // Use FieldValue.increment to safely add the reward to their total.
        // This prevents issues if the user is active on multiple devices.
        await userRef.update({'rewards': FieldValue.increment(rewardAmount)});
        print("🎉 First attempt! Granted $rewardAmount rewards.");
      }
      // --- END REWARD LOGIC ---

      // 3. Save the quiz attempt as before, regardless of reward.
      await attemptsRef.add({
        'quizId': quizId,
        'quizTitle': quizTitle,
        'userId': userId,
        'score': score,
        'totalQuestions': totalQuestions,
        'completedAt': Timestamp.now(), // Use a server timestamp for accuracy
      });
      print("✅ Quiz attempt saved successfully!");

    } catch (e) {
      print("Error submitting quiz attempt: $e");
      rethrow;
    }
  }
}
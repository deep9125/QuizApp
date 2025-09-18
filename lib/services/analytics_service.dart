// lib/services/analytics_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Model/Analytics/quiz_performance_metric.dart';
import '../Model/Analytics/user_engagement_metric.dart';

class AnalyticsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserEngagementMetric> getUserEngagement() async {
    // Fetches the real user engagement data
    final usersSnapshot = await _firestore.collection('users').get();
    final totalUsers = usersSnapshot.docs.length;

    final oneDayAgo = DateTime.now().subtract(const Duration(days: 1));
    final newUsersSnapshot = await _firestore
        .collection('users')
        .where('createdAt', isGreaterThanOrEqualTo: Timestamp.fromDate(oneDayAgo))
        .get();
    final newSignUpsToday = newUsersSnapshot.docs.length;

    final attemptsSnapshot = await _firestore.collection('quiz_attempts').get();
    final totalQuizCompletions = attemptsSnapshot.docs.length;

    final averageQuizzesPerUser = totalUsers > 0 ? totalQuizCompletions / totalUsers : 0.0;

    return UserEngagementMetric(
      activeUsersToday: totalUsers,
      newSignUpsToday: newSignUpsToday,
      totalQuizCompletionsAllTime: totalQuizCompletions,
      averageQuizzesPerUser: averageQuizzesPerUser,
      dailyActivityLast7Days: [],
    );
  }

  Future<List<QuizPerformanceMetric>> getQuizPerformanceMetrics() async {
    final quizzesSnapshot = await _firestore.collection('quizzes').get();
    List<QuizPerformanceMetric> performanceMetrics = [];

    for (var quizDoc in quizzesSnapshot.docs) {
      final quizData = quizDoc.data() as Map<String, dynamic>;
      final quizId = quizDoc.id;
      final quizTitle = quizData['title'] ?? 'Untitled Quiz';
      int attempts = 0;
      double averageScore = 0.0;

      try {
        final attemptsSnapshot = await _firestore
            .collection('quiz_attempts')
            .where('quizId', isEqualTo: quizId)
            .get();
            
        attempts = attemptsSnapshot.docs.length;

        if (attempts > 0) {
          double totalScore = attemptsSnapshot.docs.fold(0.0, (sum, doc) {
            final score = (doc.data() as Map<String, dynamic>)['score'] as num? ?? 0;
            return sum + score;
          });
          int totalQuestions = quizData['questionCount'] ?? 1;
          if (totalQuestions > 0) {
            averageScore = (totalScore / attempts) / totalQuestions * 100;
          }
        }

      } catch (e) {
        // In a real app, you might log this error to a service like Crashlytics
        print("Error fetching attempts for quiz '$quizTitle': $e");
      }

      performanceMetrics.add(
        QuizPerformanceMetric(
          quizId: quizId,
          quizTitle: quizTitle,
          attempts: attempts,
          averageScore: averageScore,
          totalQuestions: quizData['questionCount'] ?? 0,
        ),
      );
    }
    
    return performanceMetrics;
  }
}
import 'package:flutter/material.dart';
// Import your charting library when ready
// import 'package:fl_chart/fl_chart.dart';

// 1. IMPORT YOUR CENTRALIZED ANALYTICS MODELS
import '../../Model/Analytics/quiz_performance_metric.dart';
import '../../Model/Analytics/user_engagement_metric.dart';
import '../../Model/Analytics/daily_activity.dart';

// (Optional) Import an AnalyticsService if you create one
// import '../../services/analytics_service.dart';

// CHANGED: Renamed class to ManagerAnalyticsScreen
class ManagerAnalyticsScreen extends StatefulWidget {
  const ManagerAnalyticsScreen({super.key});

  @override
  // CHANGED: Renamed State class reference
  State<ManagerAnalyticsScreen> createState() => _ManagerAnalyticsScreenState();
}

// CHANGED: Renamed State class to _ManagerAnalyticsScreenState
class _ManagerAnalyticsScreenState extends State<ManagerAnalyticsScreen> {
  // Optional: late final AnalyticsService _analyticsService;
  bool _isLoading = false;
  UserEngagementMetric? _userEngagement;
  List<QuizPerformanceMetric> _quizPerformance = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Optional: _analyticsService = AnalyticsService();
    _loadAnalyticsData();
  }

  Future<void> _loadAnalyticsData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // In a real app, you would fetch this data from your service
      // For now, we'll continue using the mock data.
      await Future.delayed(const Duration(milliseconds: 800)); // Simulate API call
      _userEngagement = UserEngagementMetric(
          activeUsersToday: 152,
          newSignUpsToday: 12,
          totalQuizCompletionsAllTime: 1256,
          averageQuizzesPerUser: 3.5,
          dailyActivityLast7Days: List.generate(7, (index) {
            final date = DateTime.now().subtract(Duration(days: 6 - index));
            return DailyActivity(
                date: date,
                activeUsers: 100 + (index * 10) - (index % 2 == 0 ? 5 : -5),
                quizzesCompleted: 50 + (index * 5) + (index % 2 == 0 ? 3 : -2));
          }));

      _quizPerformance = [
        QuizPerformanceMetric(quizId: 'q1', quizTitle: 'Flutter Basics', attempts: 350, averageScore: 82.0, totalQuestions: 10, mostIncorrectAnswers: {'What is a Widget?': 25, 'Stateless vs Stateful': 18}),
        QuizPerformanceMetric(quizId: 'q2', quizTitle: 'World Capitals', attempts: 210, averageScore: 65.5, totalQuestions: 20, mostIncorrectAnswers: {'Capital of Australia?': 40}),
        QuizPerformanceMetric(quizId: 'q3', quizTitle: 'Basic Math', attempts: 450, averageScore: 90.1, totalQuestions: 15, mostIncorrectAnswers: {'15 * 6 = ?': 10}),
        QuizPerformanceMetric(quizId: 'q4', quizTitle: 'Advanced Dart', attempts: 80, averageScore: 70.0, totalQuestions: 12),
      ];
    } catch (e) {
      _errorMessage = 'Failed to load analytics data: ${e.toString()}';
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // --- All UI builder methods (_buildMetricCard, _buildChartPlaceholder, etc.) are the same ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Analytics'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadAnalyticsData,
            tooltip: 'Refresh Data',
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? _buildErrorView(_errorMessage!)
              : (_userEngagement == null && _quizPerformance.isEmpty)
                  ? _buildEmptyState()
                  : _buildAnalyticsContent(context),
    );
  }

  Widget _buildAnalyticsContent(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // --- User Engagement Section ---
          Text('User Engagement', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (_userEngagement != null) ...[
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: MediaQuery.of(context).size.width > 600 ? 1.5 : 1.7,
              children: [
                _buildMetricCard('Active Users Today', _userEngagement!.activeUsersToday.toString(), icon: Icons.person_pin_circle_outlined),
                _buildMetricCard('New Sign-ups Today', _userEngagement!.newSignUpsToday.toString(), icon: Icons.person_add_alt_1_outlined),
                _buildMetricCard('Total Quiz Completions', _userEngagement!.totalQuizCompletionsAllTime.toString(), icon: Icons.done_all_outlined),
                _buildMetricCard('Avg Quizzes/User', _userEngagement!.averageQuizzesPerUser.toStringAsFixed(1), icon: Icons.quiz_outlined),
              ],
            ),
            const SizedBox(height: 20),
            _buildChartPlaceholder('Daily Active Users (Last 7 Days)'),
            const SizedBox(height: 12),
            _buildChartPlaceholder('Daily Quiz Completions (Last 7 Days)'),
          ],
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),

          // --- Quiz Performance Section ---
          Text('Quiz Performance', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (_quizPerformance.isNotEmpty)
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _quizPerformance.length,
              itemBuilder: (context, index) {
                final quizPerf = _quizPerformance[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ExpansionTile(
                    leading: CircleAvatar(child: Text('${index + 1}')),
                    title: Text(quizPerf.quizTitle, style: const TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: Text('Attempts: ${quizPerf.attempts} | Avg Score: ${quizPerf.averageScore.toStringAsFixed(1)}%'),
                    childrenPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    children: <Widget>[
                      _buildDetailRow('Total Questions:', quizPerf.totalQuestions.toString()),
                      if (quizPerf.mostIncorrectAnswers.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Text('Commonly Missed:', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                        ...quizPerf.mostIncorrectAnswers.entries.map((entry) =>
                                Text('"${entry.key}" - ${entry.value} times')).toList(),
                      ],
                    ],
                  ),
                );
              },
            )
          else
            const Text('No quiz performance data available.'),
        ],
      ),
    );
  }
    // --- Helper methods like _buildMetricCard, etc. are unchanged ---

    Widget _buildMetricCard(String title, String value, {IconData? icon}) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) Icon(icon, size: 30, color: Theme.of(context).colorScheme.primary),
              if (icon != null) const SizedBox(height: 8),
              Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(title, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }

    Widget _buildChartPlaceholder(String title) {
      return Card(
          color: Colors.blueGrey[50],
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Container(
                      height: 150,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: Center(
                          child: Icon(Icons.insert_chart_outlined_rounded, size: 40, color: Colors.grey[600]),
                      )
                  ),
                ]
            ),
          )
      );
    }
    
    Widget _buildErrorView(String message) {
        return Center(child: Text(message));
    }
    
    Widget _buildEmptyState() {
        return const Center(child: Text('No data available.'));
    }

    Widget _buildDetailRow(String label, String value) {
        return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [Text(label), Text(value, style: const TextStyle(fontWeight: FontWeight.bold))]
        );
    }
}
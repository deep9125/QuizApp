import 'package:flutter/material.dart';

// Import your centralized analytics models
import '../../Model/Analytics/quiz_performance_metric.dart';
import '../../Model/Analytics/user_engagement_metric.dart';

// Import the real analytics service
import '../../services/analytics_service.dart';

class ManagerAnalyticsScreen extends StatefulWidget {
  const ManagerAnalyticsScreen({super.key});

  @override
  State<ManagerAnalyticsScreen> createState() => _ManagerAnalyticsScreenState();
}

class _ManagerAnalyticsScreenState extends State<ManagerAnalyticsScreen> {
  // Use the real AnalyticsService
  final AnalyticsService _analyticsService = AnalyticsService();
  bool _isLoading = false;
  UserEngagementMetric? _userEngagement;
  List<QuizPerformanceMetric> _quizPerformance = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadAnalyticsData();
  }
  
  Future<void> _loadAnalyticsData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Fetch real data from the Firestore service
      _userEngagement = await _analyticsService.getUserEngagement();
      _quizPerformance = await _analyticsService.getQuizPerformanceMetrics();
    } catch (e) {
      _errorMessage = 'Failed to load analytics data: ${e.toString()}';
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

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
          Text('User Engagement', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (_userEngagement != null) ...[
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: [
                _buildMetricCard('Total Users', _userEngagement!.activeUsersToday.toString(), icon: Icons.person_pin_circle_outlined),
                _buildMetricCard('New Sign-ups (24h)', _userEngagement!.newSignUpsToday.toString(), icon: Icons.person_add_alt_1_outlined),
                _buildMetricCard('Total Quiz Completions', _userEngagement!.totalQuizCompletionsAllTime.toString(), icon: Icons.done_all_outlined),
                _buildMetricCard('Avg Quizzes/User', _userEngagement!.averageQuizzesPerUser.toStringAsFixed(1), icon: Icons.quiz_outlined),
              ],
            ),
          ],
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          Text('Quiz Performance', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (_quizPerformance.isNotEmpty)
            // CHANGED: Using ExpansionTile for a more interactive list
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
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        child: _buildDetailRow('Total Questions:', quizPerf.totalQuestions.toString()),
                      )
                    ],
                  ),
                );
              },
            )
          else
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text('No quiz performance data available yet.'),
            ),
        ],
      ),
    );
  }

  Widget _buildMetricCard(String title, String value, {IconData? icon}) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) Icon(icon, size: 30, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(title, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView(String message) {
   return Center(
    child: Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 40),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    ),
    );
  }
  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('No analytics data available yet.', textAlign: TextAlign.center),
      ),
    );
  }

  // ADDED: Helper widget for neat detail rows inside the ExpansionTile
  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[700])),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
      ],
    );
  }
}
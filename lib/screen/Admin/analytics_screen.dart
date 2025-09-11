import 'package:flutter/material.dart';
// Import your charting library when ready
// import 'package:fl_chart/fl_chart.dart';

// 1. IMPORT YOUR CENTRALIZED ANALYTICS MODELS
// Adjust paths based on your actual model file locations
import '../../Model/Analytics/quiz_performance_metric.dart';
import '../../Model/Analytics/user_engagement_metric.dart';
import '../../Model/Analytics/daily_activity.dart';
// DailyActivity is often part of UserEngagementMetric or imported separately if used elsewhere

// (Optional) Import an AnalyticsService if you create one
// import '../../services/analytics_service.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  // Optional: late final AnalyticsService _analyticsService;
  bool _isLoading = false;
  UserEngagementMetric? _userEngagement;
  List<QuizPerformanceMetric> _quizPerformance = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Optional: _analyticsService = AnalyticsService(); // Initialize your service
    _loadAnalyticsData();
  }

  Future<void> _loadAnalyticsData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // In a real app, you would fetch data using a service:
      // await Future.delayed(const Duration(milliseconds: 700)); // Simulate API call
      // _userEngagement = await _analyticsService.getUserEngagement();
      // _quizPerformance = await _analyticsService.getQuizPerformanceMetrics();

      // --- USING MOCK DATA (as per original) ---
      await Future.delayed(const Duration(milliseconds: 700)); // Simulate API call
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
                quizzesCompleted: 50 + (index * 5) + (index % 2 == 0 ? 3 : -2)
            );
          })
      );

      _quizPerformance = [
        QuizPerformanceMetric(quizId: 'q1', quizTitle: 'Flutter Basics', attempts: 350, averageScore: 82.0, totalQuestions: 10, mostIncorrectAnswers: {'What is a Widget?': 25, 'Stateless vs Stateful': 18}),
        QuizPerformanceMetric(quizId: 'q2', quizTitle: 'World Capitals', attempts: 210, averageScore: 65.5, totalQuestions: 20, mostIncorrectAnswers: {'Capital of Australia?': 40}),
        QuizPerformanceMetric(quizId: 'q3', quizTitle: 'Basic Math', attempts: 450, averageScore: 90.1, totalQuestions: 15, mostIncorrectAnswers: {'15 * 6 = ?': 10}),
        QuizPerformanceMetric(quizId: 'q4', quizTitle: 'Advanced Dart', attempts: 80, averageScore: 70.0, totalQuestions: 12),
      ];
      // --- END MOCK DATA ---

    } catch (e) {
      // Basic error handling
      _errorMessage = 'Failed to load analytics data: ${e.toString()}';
    } finally {
      if (mounted) { // Check if the widget is still in the tree
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildMetricCard(String title, String value, {IconData? icon, Color? iconColor, VoidCallback? onTap}) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: InkWell( // Make card tappable if onTap is provided
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (icon != null) Icon(icon, size: 30, color: iconColor ?? Theme.of(context).colorScheme.primary),
              if (icon != null) const SizedBox(height: 8),
              Text(
                value,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartPlaceholder(String title, {double height = 150.0, String message = "Chart coming soon!"}) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      color: Colors.blueGrey[50],
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Container(
              height: height,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(8),
                // border: Border.all(color: Colors.grey[400]!) // Optional border
              ),
              child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.insert_chart_outlined_rounded, size: 40, color: Colors.grey[600]),
                      const SizedBox(height: 8),
                      Text(message, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600]))
                    ],
                  )
              ),
            ),
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
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              onPressed: _loadAnalyticsData,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 60, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('No analytics data available yet.', style: TextStyle(fontSize: 17, color: Colors.grey)),
          const SizedBox(height: 8),
          Text('Check back later once there is more activity!', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Analytics'),
        backgroundColor: Colors.blueGrey[700], // Consider using Theme.of(context).colorScheme.primaryContainer
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadAnalyticsData, // Disable if loading
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
      padding: const EdgeInsets.all(16.0), // Consistent padding
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
              crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2, // Responsive grid
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: MediaQuery.of(context).size.width > 600 ? 1.5 : 1.7,
              children: [
                _buildMetricCard('Active Users Today', _userEngagement!.activeUsersToday.toString(), icon: Icons.person_pin_circle_outlined, iconColor: Colors.blueAccent),
                _buildMetricCard('New Sign-ups Today', _userEngagement!.newSignUpsToday.toString(), icon: Icons.person_add_alt_1_outlined, iconColor: Colors.greenAccent[700]),
                _buildMetricCard('Total Quiz Completions', _userEngagement!.totalQuizCompletionsAllTime.toString(), icon: Icons.done_all_outlined, iconColor: Colors.orangeAccent[700]),
                _buildMetricCard('Avg Quizzes/User', _userEngagement!.averageQuizzesPerUser.toStringAsFixed(1), icon: Icons.quiz_outlined, iconColor: Colors.purpleAccent[700]),
              ],
            ),
            const SizedBox(height: 20),
            // TODO: Replace with actual charts when fl_chart is integrated
            _buildChartPlaceholder('Daily Active Users (Last 7 Days)', message: 'Chart for DAU - Last 7 Days'),
            const SizedBox(height: 12),
            _buildChartPlaceholder('Daily Quiz Completions (Last 7 Days)', message: 'Chart for Completions - Last 7 Days'),
          ] else ...[
            const Text('User engagement data is currently unavailable.', style: TextStyle(fontStyle: FontStyle.italic)),
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
                  elevation: 2.0,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                      child: Text('${index + 1}', style: TextStyle(color: Theme.of(context).colorScheme.onSecondaryContainer)),
                    ),
                    title: Text(quizPerf.quizTitle, style: const TextStyle(fontWeight: FontWeight.w500)),
                    subtitle: Text('Attempts: ${quizPerf.attempts} | Avg Score: ${quizPerf.averageScore.toStringAsFixed(1)}%'),
                    childrenPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0).copyWith(top:0),
                    children: <Widget>[
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow('Total Questions:', quizPerf.totalQuestions.toString()),
                          if(quizPerf.mostIncorrectAnswers.isNotEmpty)...[
                            const SizedBox(height: 10),
                            Text('Commonly Missed:', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            ...quizPerf.mostIncorrectAnswers.entries.map((entry) =>
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0, top: 2.0, bottom: 2.0),
                                  child: Text('"${entry.key}" - ${entry.value} times', style: TextStyle(color: Colors.grey[800])),
                                )
                            ).toList(),
                          ],
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              child: const Text('View Detailed Stats'),
                              onPressed: (){
                                // TODO: Navigate to a detailed stats screen for this quiz (quizPerf.quizId)
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Detailed stats for ${quizPerf.quizTitle} not yet implemented.')),
                                );
                              },
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                );
              },
            )
          else
            const Text('No quiz performance data available.', style: TextStyle(fontStyle: FontStyle.italic)),
          const SizedBox(height: 20),
          _buildChartPlaceholder('Overall Score Distribution', message: 'Chart for Score Distribution'),
          const SizedBox(height: 20), // Padding at the bottom
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey[700])),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}


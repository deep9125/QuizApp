// screens/User/quiz_result_screen.dart
import 'package:flutter/material.dart';

class QuizResultScreen extends StatelessWidget {
  final int score;
  final int totalQuestions;

  const QuizResultScreen({
    super.key,
    required this.score,
    required this.totalQuestions,
  });

  // Helper method to get a feedback message based on the score
  String _getFeedbackMessage(double percentage) {
    if (percentage >= 0.9) {
      return 'Excellent! You\'re a quiz master!';
    } else if (percentage >= 0.7) {
      return 'Great job! You really know your stuff.';
    } else if (percentage >= 0.5) {
      return 'Good effort! Keep practicing.';
    } else {
      return 'Keep trying! You\'ll get there.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final double percentage = totalQuestions > 0 ? score / totalQuestions : 0.0;
    final String feedback = _getFeedbackMessage(percentage);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quiz Result'),
        automaticallyImplyLeading: false, // Hide the back button
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                feedback,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 150,
                width: 150,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: percentage,
                      strokeWidth: 12,
                      backgroundColor: Colors.grey[300],
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.deepPurple),
                    ),
                    Center(
                      child: Text(
                        '$score / $totalQuestions',
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Text(
                'You answered ${ (percentage * 100).toStringAsFixed(0) }% of the questions correctly.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                icon: const Icon(Icons.dashboard_rounded),
                label: const Text('Return to Dashboard'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                onPressed: () {
                  // Pop all screens until we get back to the dashboard
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
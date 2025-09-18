// screens/manager/manage_quizzes_screen.dart
import 'package:flutter/material.dart';
import '../../services/mock_quiz_service.dart';
import '../../Model/quiz_summary.dart';
import 'add_quiz_screen.dart';
import 'edit_quiz_screen.dart'; // FIXED: Corrected file name for consistency
import 'manage_questions_screen.dart';

class ManagerManageQuizzesScreen extends StatefulWidget {
  const ManagerManageQuizzesScreen({super.key});

  @override
  State<ManagerManageQuizzesScreen> createState() => _ManagerManageQuizzesScreenState();
}

class _ManagerManageQuizzesScreenState extends State<ManagerManageQuizzesScreen> {
  // You can swap this with a real Firestore service when ready
  final MockQuizService _quizService = MockQuizService();
  List<ManagerQuizSummary> _quizzes = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  Future<void> _loadQuizzes() async {
    setState(() => _isLoading = true);
    _quizzes = await _quizService.getManagerQuizzes();
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToCreateQuizForm() async {
    final newQuizDetails = await Navigator.push<ManagerQuizSummary>(
      context,
      MaterialPageRoute(builder: (context) => const AddQuizScreen()),
    );

    if (newQuizDetails != null) {
      setState(() => _isLoading = true);
      try {
        final newQuiz = await _quizService.addManagerQuiz(
          title: newQuizDetails.title,
          description: newQuizDetails.description,
          category: newQuizDetails.category,
          hasTimer: newQuizDetails.hasTimer,
          timerSeconds: newQuizDetails.timerSeconds,
          isRandomized: newQuizDetails.isRandomized,
        );
        await _loadQuizzes();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Quiz "${newQuiz.title}" created.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error creating quiz: $e')),
          );
        }
      }
    }
  }

  void _navigateToEditQuizForm(ManagerQuizSummary quiz) async {
    final updatedQuiz = await Navigator.push<ManagerQuizSummary>(
      context,
      MaterialPageRoute(builder: (context) => EditQuizFormScreen(quizToEdit: quiz)),
    );

    if (updatedQuiz != null) {
      setState(() => _isLoading = true);
      try {
        await _quizService.updateManagerQuiz(updatedQuiz);
        await _loadQuizzes();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Quiz "${updatedQuiz.title}" updated.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating quiz: $e')),
          );
        }
      }
    }
  }

  Future<void> _deleteQuiz(String quizId, String quizTitle) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          // FIXED: The content now correctly refers to deleting a QUIZ and uses the correct variable.
          content: Text('Are you sure you want to delete the quiz "$quizTitle"? This will also delete all of its questions.'),
          actions: <Widget>[
            TextButton(child: const Text('Cancel'), onPressed: () => Navigator.of(context).pop(false)),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      await _quizService.deleteManagerQuiz(quizId);
      await _loadQuizzes();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Quiz "$quizTitle" deleted.')),
        );
      }
    }
  }

  void _navigateToManageQuestions(ManagerQuizSummary quiz) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManagerManageQuestionsScreen(
          quizId: quiz.id,
          quizTitle: quiz.title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Quizzes'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _quizzes.isEmpty
              ? Center(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('No quizzes found.', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Create First Quiz'),
                      onPressed: _navigateToCreateQuizForm,
                    )
                  ],
                ))
              : RefreshIndicator(
                  onRefresh: _loadQuizzes,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: _quizzes.length,
                    itemBuilder: (context, index) {
                      final quiz = _quizzes[index];
                      return Card(
                        child: ListTile(
                          title: Text(quiz.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('Category: ${quiz.category} | Questions: ${quiz.questionCount}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blueAccent),
                                tooltip: 'Edit Quiz Details',
                                onPressed: () => _navigateToEditQuizForm(quiz),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.redAccent),
                                tooltip: 'Delete Quiz',
                                onPressed: () => _deleteQuiz(quiz.id, quiz.title),
                              ),
                            ],
                          ),
                          onTap: () => _navigateToManageQuestions(quiz),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToCreateQuizForm,
        icon: const Icon(Icons.add),
        label: const Text('New Quiz'),
      ),
    );
  }
}
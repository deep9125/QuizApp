// screens/manager/manage_questions_screen.dart
import 'package:flutter/material.dart';
import '../../Model/question.dart';
// FIXED: Dart file names should be snake_case
import '../../services/ManagerQuizService.dart'; 
import 'add_question_screen.dart';
import 'edit_question_screen.dart';

class ManagerManageQuestionsScreen extends StatefulWidget {
  final String quizId;
  final String quizTitle;
  const ManagerManageQuestionsScreen({
    super.key,
    required this.quizId,
    required this.quizTitle,
  });

  @override
  State<ManagerManageQuestionsScreen> createState() => _ManagerManageQuestionsScreenState();
}

class _ManagerManageQuestionsScreenState extends State<ManagerManageQuestionsScreen> {
  final ManagerQuizService _quizService = ManagerQuizService();
  List<ManagerQuestion> _questions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() => _isLoading = true);
    _questions = await _quizService.getQuestionsForQuiz(widget.quizId);
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  void _navigateToAddQuestion() async {
    final newQuestion = await Navigator.push<ManagerQuestion>(
      context,
      MaterialPageRoute(
        builder: (_) => AddQuestionScreen(quizId: widget.quizId),
      ),
    );

    if (newQuestion != null) {
      setState(() => _isLoading = true);
      await _quizService.addQuestionToQuiz(widget.quizId, newQuestion);
      await _loadQuestions();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Question "${newQuestion.text}" added.')),
        );
      }
    }
  }

  void _navigateToEditQuestion(ManagerQuestion question) async {
    final updatedQuestion = await Navigator.push<ManagerQuestion>(
      context,
      MaterialPageRoute(
        builder: (_) => EditQuestionScreen(
          quizId: widget.quizId,
          questionToEdit: question,
        ),
      ),
    );

    if (updatedQuestion != null) {
      setState(() => _isLoading = true);
      await _quizService.updateQuestion(updatedQuestion);
      await _loadQuestions();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Question updated.')),
        );
      }
    }
  }

  Future<void> _deleteQuestion(String questionId, String questionText) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this question?\n\n"$questionText"'),
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
      // FIXED: The deleteQuestion method needs both the quizId and the questionId.
      await _quizService.deleteQuestion(widget.quizId, questionId);
      await _loadQuestions();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Question "$questionText" deleted.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Questions: ${widget.quizTitle}'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _questions.isEmpty
              ? Center(
                  child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('No questions yet.', style: TextStyle(fontSize: 18)),
                    const SizedBox(height: 10),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Add First Question'),
                      onPressed: _navigateToAddQuestion,
                    )
                  ],
                ))
              : RefreshIndicator(
                  onRefresh: _loadQuestions,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8.0),
                    itemCount: _questions.length,
                    itemBuilder: (context, index) {
                      final question = _questions[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(child: Text('${index + 1}')),
                          title: Text(question.text, maxLines: 2, overflow: TextOverflow.ellipsis),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit_note, color: Colors.blueAccent),
                                onPressed: () => _navigateToEditQuestion(question),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                                onPressed: () => _deleteQuestion(question.id, question.text),
                              ),
                            ],
                          ),
                          onTap: () => _navigateToEditQuestion(question),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddQuestion,
        tooltip: 'Add New Question',
        child: const Icon(Icons.add),
      ),
    );
  }
}
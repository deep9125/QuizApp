import 'package:flutter/material.dart';

// 1. IMPORT YOUR CENTRALIZED MODELS
// Adjust path if your screen is located elsewhere relative to the model folder.
// This assumes your models are in 'lib/model/'.
import '../../Model/question.dart';    // Should define AdminQuestion and QuestionType
import '../../services/mock_quiz_service.dart';

// 2. IMPORT THE SCREENS YOU NAVIGATE TO
import './add_question_screen.dart';   // Ensure this screen uses the imported AdminQuestion model
import './edit_question_screen.dart';  // Ensure this screen uses the imported AdminQuestion model

// 3. REMOVE ANY COMMENTED-OUT OR PLACEHOLDER MODEL DEFINITIONS FROM THIS FILE
// e.g., delete lines like:
// // enum QuestionType { multipleChoice, trueFalse, fillInBlank, numeric }
// // class AdminQuestion { ... }

class AdminManageQuestionsScreen extends StatefulWidget {
  final String quizId;
  final String quizTitle;

  const AdminManageQuestionsScreen({
    super.key,
    required this.quizId,
    required this.quizTitle,
  });

  @override
  State<AdminManageQuestionsScreen> createState() => _AdminManageQuestionsScreenState();
}

class _AdminManageQuestionsScreenState extends State<AdminManageQuestionsScreen> {
  final MockQuizService _quizService = MockQuizService();
  List<AdminQuestion> _questionsForThisQuiz = []; // This will use the imported AdminQuestion
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() => _isLoading = true);
    // This will fetch List<AdminQuestion> using the model definition
    // shared with MockQuizService
    _questionsForThisQuiz = await _quizService.getQuestionsForQuiz(widget.quizId);
    setState(() => _isLoading = false);
  }

  // This uses the imported QuestionType enum
  String _getQuestionTypeString(QuestionType type) {
    switch (type) {
      case QuestionType.multipleChoice:
        return 'MCQ';
      case QuestionType.trueFalse:
        return 'T/F';
      case QuestionType.fillInBlank:
        return 'Fill Blank';
      case QuestionType.numeric:
        return 'Numeric';
      default:
        return 'Unknown';
    }
  }

  void _navigateToAddQuestionForm() async {
    // AddQuestionScreen should be designed to return an AdminQuestion object
    // (using the imported model) or the necessary data for the service.
    final newQuestionDetails = await Navigator.push<AdminQuestion>(
      context,
      MaterialPageRoute(
        builder: (_) => AddQuestionScreen(quizId: widget.quizId),
      ),
    );

    if (newQuestionDetails != null) {
      setState(() => _isLoading = true);
      try {
        // The service's addQuestionToQuiz should expect parameters that
        // match the fields of the imported AdminQuestion model.
        await _quizService.addQuestionToQuiz(
          quizId: newQuestionDetails.quizId, // Ensure AddQuestionScreen returns this or it's widget.quizId
          text: newQuestionDetails.text,
          type: newQuestionDetails.type,
          options: newQuestionDetails.options,
          correctAnswer: newQuestionDetails.correctAnswer,
        );
        await _loadQuestions();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Question "${newQuestionDetails.text}" added.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error adding question: $e')),
          );
        }
        await _loadQuestions(); // Ensure list consistency
      }
    }
  }

  void _navigateToEditQuestionForm(AdminQuestion questionToEdit) async {
    // EditQuestionScreen should take and return an AdminQuestion object
    // (using the imported model).
    final updatedQuestion = await Navigator.push<AdminQuestion>(
      context,
      MaterialPageRoute(
        builder: (_) => EditQuestionScreen(
          quizId: widget.quizId, // <--- ADD THIS LINE
          questionToEdit: questionToEdit,
        ),
      ),
    );

    if (updatedQuestion != null) {
      setState(() => _isLoading = true);
      try {
        // The service's updateQuestion should expect an AdminQuestion object
        // matching the imported model.
        await _quizService.updateQuestion(updatedQuestion);
        await _loadQuestions();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Question "${updatedQuestion.text}" updated.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating question: $e')),
          );
        }
        await _loadQuestions(); // Ensure list consistency
      }
    }
  }

  Future<void> _deleteQuestion(String questionId, String questionText) async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete Question'),
          content: Text('Are you sure you want to delete the question "$questionText"? This action cannot be undone.'),
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

    if (confirmDelete == true) {
      setState(() => _isLoading = true);
      try {
        final success = await _quizService.deleteQuestion(questionId);
        await _loadQuestions();
        if (mounted && success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Question "$questionText" deleted.')),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting question "$questionText".')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting question: $e')),
          );
        }
        await _loadQuestions(); // Ensure list consistency
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Questions: ${widget.quizTitle}'),
        backgroundColor: Colors.blueGrey[700],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _questionsForThisQuiz.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No questions found for this quiz.', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add First Question'),
              onPressed: _navigateToAddQuestionForm,
            )
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadQuestions,
        child: ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: _questionsForThisQuiz.length,
          itemBuilder: (context, index) {
            final question = _questionsForThisQuiz[index]; // Instance of imported AdminQuestion
            return Card(
              child: ListTile(
                leading: CircleAvatar(child: Text('${index + 1}')),
                title: Text(question.text, maxLines: 2, overflow: TextOverflow.ellipsis),
                subtitle: Text('Type: ${_getQuestionTypeString(question.type)} | Ans: ${question.correctAnswer.substring(0, (question.correctAnswer.length > 15) ? 15 : question.correctAnswer.length)}${(question.correctAnswer.length > 15) ? "..." : ""}'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_note, color: Colors.blueAccent),
                      onPressed: () => _navigateToEditQuestionForm(question),
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                      onPressed: () => _deleteQuestion(question.id, question.text),
                    ),
                  ],
                ),
                onTap: () => _navigateToEditQuestionForm(question),
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddQuestionForm,
        tooltip: 'Add New Question',
        child: const Icon(Icons.add),
      ),
    );
  }
}

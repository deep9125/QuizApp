import 'package:flutter/material.dart';
// Assuming your service and models are in these locations
import '../../services/mock_quiz_service.dart';
// AdminQuizSummary might be in a models folder, or defined in mock_quiz_service.dart
// If it's in this file, that's fine for now. If separate, adjust path.
import '../../Model/quiz_summary.dart';

// Assuming AddQuizScreen and EditQuizFormScreen are in the current directory or a sub-directory
// For consistency with the AdminDashboard, they might be in ./Admin/
// For this example, I'll assume they are named as per your original code.
// You might have consolidated these into an AdminAddEditQuizScreen as discussed.
import './add_quiz_screen.dart'; // Or your combined AdminAddEditQuizScreen
import './edit_quiz_screen.dart'; // Or your combined AdminAddEditQuizScreen
import './manage_questions_screen.dart';
// If AdminQuizSummary is not imported from models or mock_quiz_service,
// ensure it's defined here (as it is in your provided code).
// class AdminQuizSummary { ... } // Your existing definition

class AdminManageQuizzesScreen extends StatefulWidget {
  const AdminManageQuizzesScreen({super.key});

  @override
  State<AdminManageQuizzesScreen> createState() => _AdminManageQuizzesScreenState();
}

class _AdminManageQuizzesScreenState extends State<AdminManageQuizzesScreen> {
  // Use the MockQuizService
  final MockQuizService _quizService = MockQuizService();
  List<AdminQuizSummary> _quizzes = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  Future<void> _loadQuizzes() async {
    setState(() => _isLoading = true);
    // Fetch quizzes from the service
    _quizzes = await _quizService.getAdminQuizzes();
    setState(() => _isLoading = false);
  }

  void _navigateToCreateQuizForm() async {
    // Navigate to AddQuizScreen. It should return the data needed to create a quiz.
    // Let's assume AddQuizScreen returns a Map<String, String> for title and category,
    // or an AdminQuizSummary object directly (if it generates its own ID etc.)
    final result = await Navigator.push<AdminQuizSummary>( // Or Map<String, dynamic> if AddQuizScreen is simpler
      context,
      MaterialPageRoute(builder: (context) => const AddQuizScreen()), // Or your AdminAddEditQuizScreen()
    );

    if (result != null) {
      setState(() => _isLoading = true);
      // Add the quiz using the service
      // The service will handle ID generation and adding to its internal list
      try {
        // If AddQuizScreen returns an AdminQuizSummary directly (with temporary or no ID)
        // you might pass its properties to the service.
        // For this example, let's assume AddQuizScreen is designed to return what the service needs.
        // If your AddQuizScreen returns title/category:
        // final newQuiz = await _quizService.addAdminQuiz(title: result.title, category: result.category);
        // If AddQuizScreen returns the full object (less robust for service interaction but simpler to start):
        final newQuiz = await _quizService.addAdminQuiz(title: result.title, category: result.category);
        // We call _loadQuizzes() to refresh the list from the single source of truth (the service)
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
        _loadQuizzes(); // Ensure list is in a consistent state
      }
    }
  }

  void _navigateToEditQuizForm(AdminQuizSummary quiz) async {
    // EditQuizFormScreen should take quizToEdit and return the updated AdminQuizSummary
    final result = await Navigator.push<AdminQuizSummary>(
      context,
      MaterialPageRoute(builder: (context) => EditQuizFormScreen(quizToEdit: quiz)), // Or AdminAddEditQuizScreen(quizToEdit: quiz)
    );

    if (result != null) {
      setState(() => _isLoading = true);
      // Update the quiz using the service
      try {
        final updatedQuiz = await _quizService.updateAdminQuiz(
          result.id, // Use the ID from the returned result
          title: result.title,
          category: result.category,
          // If your model has hasTimer, isRandomized, pass them too:
          // hasTimer: result.hasTimer,
          // isRandomized: result.isRandomized,
        );
        await _loadQuizzes(); // Refresh list from service
        if (mounted && updatedQuiz != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Quiz "${updatedQuiz.title}" updated.')),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Quiz not found or error updating.')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error updating quiz: $e')),
          );
        }
        _loadQuizzes(); // Ensure list is in a consistent state
      }
    }
  }

  Future<void> _deleteQuiz(String quizId, String quizTitle) async {
    final confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: Text('Are you sure you want to delete the quiz "$quizTitle"? This will also delete all its questions (if using cascade in service).'),
        actions: <Widget>[
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmDelete == true) {
      setState(() => _isLoading = true);
      // Delete the quiz using the service
      try {
        final success = await _quizService.deleteAdminQuiz(quizId);
        await _loadQuizzes(); // Refresh list from service
        if (mounted && success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Quiz "$quizTitle" deleted.')),
          );
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting quiz "$quizTitle".')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting quiz: $e')),
          );
        }
        _loadQuizzes(); // Ensure list is in a consistent state
      }
    }
  }

  // --- NEW: Method to navigate to manage questions for a quiz ---
  void _navigateToManageQuestions(AdminQuizSummary quiz) { // 'quiz' here is your AdminQuizSummary object
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminManageQuestionsScreen(
          quizId: quiz.id,         // CORRECT: Pass the ID
          quizTitle: quiz.title,   // CORRECT: Pass the title
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Quizzes (Service)'), // Updated title for clarity
        backgroundColor: Colors.blueGrey[700],
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
        ),
      )
          : RefreshIndicator( // Optional: Add pull-to-refresh
        onRefresh: _loadQuizzes,
        child: ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: _quizzes.length,
          itemBuilder: (context, index) {
            final quiz = _quizzes[index];
            return Card(
              elevation: 2.0,
              margin: const EdgeInsets.symmetric(vertical: 6.0),
              child: ListTile(
                title: Text(quiz.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('Category: ${quiz.category} | Questions: ${quiz.questionCount} | Timer: ${quiz.hasTimer} | Randomized: ${quiz.isRandomized}'),
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
                // UPDATED: onTap now navigates to manage questions
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
        backgroundColor: Colors.blueGrey[600],
      ),
    );
  }
}

// You would need to create this screen:
// class AdminManageQuestionsScreen extends StatelessWidget {
//   final AdminQuizSummary quiz;
//   const AdminManageQuestionsScreen({Key? key, required this.quiz}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text("Questions for ${quiz.title}")),
//       body: Center(child: Text("Manage questions for ${quiz.id} here.")),
//     );
//   }
// }

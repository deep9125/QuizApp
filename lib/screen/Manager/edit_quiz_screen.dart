import 'package:flutter/material.dart';

// 1. IMPORT YOUR CENTRALIZED ManagerQuizSummary MODEL
import '../../Model/quiz_summary.dart'; // Assuming ManagerQuizSummary is here

// 2. IMPORT THE MANAGER'S MANAGE QUESTIONS SCREEN
import 'manage_questions_screen.dart'; // This should be your ManagerManageQuestionsScreen

class EditQuizFormScreen extends StatefulWidget {
  // CHANGED: The quiz to edit is now a ManagerQuizSummary
  final ManagerQuizSummary quizToEdit;

  const EditQuizFormScreen({
    super.key,
    required this.quizToEdit,
  });

  @override
  State<EditQuizFormScreen> createState() => _EditQuizFormScreenState();
}

class _EditQuizFormScreenState extends State<EditQuizFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _customCategoryController;
  late TextEditingController _timerDurationController;

  late bool _hasTimer;
  late bool _isRandomized;

  final List<String> _predefinedCategories = [
    'Programming',
    'Geography',
    'History',
    'Science',
    'General Knowledge',
    'Custom'
  ];
  String? _selectedCategory;

  @override
  void initState() {
    super.initState();
    final quiz = widget.quizToEdit;

    _titleController = TextEditingController(text: quiz.title);
    _descriptionController = TextEditingController(text: quiz.description); // Now loads from model
    _customCategoryController = TextEditingController();
    _timerDurationController = TextEditingController();

    _hasTimer = quiz.hasTimer;
    _isRandomized = quiz.isRandomized;
    _selectedCategory = quiz.category;
    
    // Now loads timer value from model if it exists
    if (_hasTimer) {
      _timerDurationController.text = quiz.timerSeconds?.toString() ?? '60';
    }

    if (!_predefinedCategories.contains(quiz.category)) {
      _selectedCategory = 'Custom';
      _customCategoryController.text = quiz.category;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _customCategoryController.dispose();
    _timerDurationController.dispose();
    super.dispose();
  }

  void _updateQuiz() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final String category = _selectedCategory == 'Custom'
          ? _customCategoryController.text.trim()
          : _selectedCategory!;

      int? seconds;
      if (_hasTimer) {
        seconds = int.tryParse(_timerDurationController.text.trim());
        if (seconds == null || seconds <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid timer duration.')),
          );
          return;
        }
      }

      // CHANGED: Create an updated quiz object using ManagerQuizSummary
      final updatedQuiz = ManagerQuizSummary(
        id: widget.quizToEdit.id,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(), // Now saves to model
        category: category,
        questionCount: widget.quizToEdit.questionCount,
        hasTimer: _hasTimer,
        timerSeconds: seconds, // Now saves to model
        isRandomized: _isRandomized,
      );

      Navigator.of(context).pop(updatedQuiz);
    }
  }

  void _navigateToManageQuestions() {
    Navigator.push(
      context,
      MaterialPageRoute(
        // CHANGED: Navigate to ManagerManageQuestionsScreen
        builder: (context) => ManagerManageQuestionsScreen(
          quizId: widget.quizToEdit.id,
          quizTitle: _titleController.text.trim().isNotEmpty
              ? _titleController.text.trim()
              : widget.quizToEdit.title,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Quiz: ${widget.quizToEdit.title}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_as_outlined),
            tooltip: 'Update Quiz',
            onPressed: _updateQuiz,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // --- All FormFields are the same as before ---
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(labelText: 'Quiz Title*'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Title is required.' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Quiz Description (Optional)'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              // ... Category Dropdown, Custom Category Field, Switches, and Buttons are the same
              DropdownButtonFormField<String>(
                  value: _selectedCategory,
                  items: _predefinedCategories.map((cat) => DropdownMenuItem(value: cat, child: Text(cat))).toList(),
                  onChanged: (val) => setState(() => _selectedCategory = val),
                  decoration: const InputDecoration(labelText: 'Category*')
              ),
              const SizedBox(height: 24),
              const Divider(),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.list_alt_outlined),
                label: const Text('Manage Questions for this Quiz'),
                onPressed: _navigateToManageQuestions,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.save_as_outlined),
                label: const Text('UPDATE QUIZ DETAILS'),
                onPressed: _updateQuiz,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
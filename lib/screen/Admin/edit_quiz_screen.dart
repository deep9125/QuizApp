import 'package:flutter/material.dart';

// 1. IMPORT YOUR CENTRALIZED AdminQuizSummary MODEL
// Adjust path if your model is elsewhere (e.g., ../../models/admin_quiz_summary.dart)
import '../../Model/quiz_summary.dart'; // Assuming AdminQuizSummary is here and does NOT have timerSeconds

// 2. IMPORT THE SCREEN YOU NAVIGATE TO
import './manage_questions_screen.dart'; // Make sure this is AdminManageQuestionsScreen

class EditQuizFormScreen extends StatefulWidget {
  final AdminQuizSummary quizToEdit;

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
  late TextEditingController _timerDurationController; // Renamed for clarity, as it's UI state

  late bool _hasTimer; // This is from the model
  late bool _isRandomized; // This is from the model

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
    _descriptionController = TextEditingController(); // Assuming no description in model for now
    _customCategoryController = TextEditingController();

    _hasTimer = quiz.hasTimer;
    _isRandomized = quiz.isRandomized;
    _selectedCategory = quiz.category;

    // Initialize timer duration controller, e.g., with a default if timer is enabled
    // This value is purely for the form if not stored in AdminQuizSummary
    _timerDurationController = TextEditingController(text: _hasTimer ? '60' : '');


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

      // If _hasTimer is true, you might still want to validate _timerDurationController
      // even if not saving the duration to the model, to ensure UX is good.
      if (_hasTimer) {
        final int? seconds = int.tryParse(_timerDurationController.text.trim());
        if (seconds == null || seconds <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid timer duration. Please enter a positive number.')),
          );
          return; // Prevent saving if timer is enabled but duration is invalid
        }
      }

      // Create an updated quiz object
      // Note: timerSeconds is no longer part of AdminQuizSummary here
      final updatedQuiz = AdminQuizSummary(
        id: widget.quizToEdit.id,
        title: _titleController.text.trim(),
        category: category,
        questionCount: widget.quizToEdit.questionCount,
        hasTimer: _hasTimer, // Only this boolean is saved to the model regarding timer
        isRandomized: _isRandomized,
      );

      Navigator.of(context).pop(updatedQuiz);
    }
  }

  void _navigateToManageQuestions() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminManageQuestionsScreen(
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
        backgroundColor: Colors.blueGrey[700],
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
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Quiz Title*',
                  border: OutlineInputBorder(),
                  hintText: 'Enter the title of the quiz',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a quiz title.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Quiz Description (Optional)',
                  border: OutlineInputBorder(),
                  hintText: 'Enter a brief description for the quiz',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(
                  labelText: 'Category*',
                  border: OutlineInputBorder(),
                ),
                items: _predefinedCategories
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedCategory = newValue;
                    if (newValue != 'Custom') {
                      _customCategoryController.clear();
                    }
                  });
                },
                validator: (value) =>
                value == null ? 'Please select a category.' : null,
              ),
              if (_selectedCategory == 'Custom') ...[
                const SizedBox(height: 16),
                TextFormField(
                  controller: _customCategoryController,
                  decoration: const InputDecoration(
                    labelText: 'Custom Category Name*',
                    border: OutlineInputBorder(),
                    hintText: 'Enter your custom category',
                  ),
                  validator: (value) {
                    if (_selectedCategory == 'Custom' &&
                        (value == null || value.trim().isEmpty)) {
                      return 'Please enter the custom category name.';
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 20),
              SwitchListTile(
                title: const Text('Enable Timer?'),
                value: _hasTimer,
                onChanged: (bool value) {
                  setState(() {
                    _hasTimer = value;
                    if (!value) {
                      _timerDurationController.clear();
                    } else if (_timerDurationController.text.isEmpty) {
                      _timerDurationController.text = '60'; // Default if enabling
                    }
                  });
                },
                secondary: const Icon(Icons.timer_outlined),
                tileColor: Colors.blueGrey[50],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              if (_hasTimer) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _timerDurationController, // Use the renamed controller
                  decoration: const InputDecoration(
                    labelText: 'Timer Duration (seconds)*',
                    border: OutlineInputBorder(),
                    hintText: 'e.g., 60 for 1 minute',
                    prefixIcon: Icon(Icons.av_timer),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    // This validation is still useful for good UX,
                    // even if the value isn't directly saved to AdminQuizSummary
                    if (_hasTimer) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a duration.';
                      }
                      final int? seconds = int.tryParse(value.trim());
                      if (seconds == null) {
                        return 'Please enter a valid number.';
                      }
                      if (seconds <= 0) {
                        return 'Duration must be positive.';
                      }
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Randomize Question Order?'),
                value: _isRandomized,
                onChanged: (bool value) {
                  setState(() {
                    _isRandomized = value;
                  });
                },
                secondary: const Icon(Icons.shuffle),
                tileColor: Colors.blueGrey[50],
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              const SizedBox(height: 24),
              const Divider(thickness: 1),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  textStyle: const TextStyle(fontSize: 16),
                  minimumSize: const Size(double.infinity, 50),
                ),
                icon: const Icon(Icons.list_alt_outlined),
                label: const Text('Manage Questions for this Quiz'),
                onPressed: _navigateToManageQuestions,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  minimumSize: const Size(double.infinity, 50),
                ),
                icon: const Icon(Icons.save_as_outlined),
                label: const Text('UPDATE QUIZ DETAILS'),
                onPressed: _updateQuiz,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}


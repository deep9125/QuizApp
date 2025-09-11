import 'package:flutter/material.dart';

// 1. IMPORT YOUR CENTRALIZED AdminQuizSummary MODEL
// Replace the import from manage_quizzes_screen with a direct model import.
// Adjust path if your model is elsewhere (e.g., ../../models/admin_quiz_summary.dart)
import '../../Model/quiz_summary.dart'; // Assuming AdminQuizSummary is here

class AddQuizScreen extends StatefulWidget {
  const AddQuizScreen({super.key});

  @override
  State<AddQuizScreen> createState() => _AddQuizScreenState();
}

class _AddQuizScreenState extends State<AddQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _customCategoryController = TextEditingController();
  final TextEditingController _timerDurationController = TextEditingController(); // Renamed for clarity

  bool _hasTimer = false;
  bool _isRandomized = false;

  // Consider making this configurable or fetching from a service in a larger app
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
    _selectedCategory = _predefinedCategories.first; // Default to first predefined
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _customCategoryController.dispose();
    _timerDurationController.dispose();
    super.dispose();
  }

  void _createQuiz() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save(); // Important if using onSaved in FormFields

      final String category = _selectedCategory == 'Custom'
          ? _customCategoryController.text.trim()
          : _selectedCategory!;

      // If _hasTimer is true, you might still want to validate _timerDurationController
      // even if not saving the duration to the model, to ensure UX is good.
      if (_hasTimer) {
        final String durationText = _timerDurationController.text.trim();
        if (durationText.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please enter timer duration if timer is enabled.')),
          );
          return; // Prevent creating quiz if timer is on but duration is missing/invalid
        }
        final int? seconds = int.tryParse(durationText);
        if (seconds == null || seconds <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid timer duration. Please enter a positive number.')),
          );
          return; // Prevent creating quiz
        }
        // If your AdminQuizSummary model HAS a timerSeconds field, you'd use 'seconds' here.
      }

      // Create the new quiz object using the imported AdminQuizSummary model
      final newQuiz = AdminQuizSummary(
        id: 'new_quiz_${DateTime.now().millisecondsSinceEpoch}', // Mock ID for now
        title: _titleController.text.trim(),
        // description: _descriptionController.text.trim(), // Uncomment if your AdminQuizSummary model supports it
        category: category,
        questionCount: 0, // New quizzes start with 0 questions
        hasTimer: _hasTimer, // This boolean indicates if a timer is active
        isRandomized: _isRandomized,
        // timerSeconds: _hasTimer ? int.parse(_timerDurationController.text.trim()) : null, // Add if your model supports it
      );

      Navigator.of(context).pop(newQuiz); // Return the newly created quiz object
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Quiz'),
        backgroundColor: Colors.blueGrey[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined), // Changed icon
            tooltip: 'Create Quiz',
            onPressed: _createQuiz,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // Make button wider
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Quiz Title*',
                  border: OutlineInputBorder(),
                  hintText: 'e.g., Flutter Intermediate Concepts',
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
                  hintText: 'A brief summary of what this quiz covers.',
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
                subtitle: Text(_hasTimer ? 'Timer is ON' : 'Timer is OFF'),
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
                    if (_hasTimer) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter timer duration.';
                      }
                      final int? seconds = int.tryParse(value.trim());
                      if (seconds == null) {
                        return 'Please enter a valid number for seconds.';
                      }
                      if (seconds <= 0) {
                        return 'Duration must be a positive number.';
                      }
                    }
                    return null;
                  },
                ),
              ],
              const SizedBox(height: 12),
              SwitchListTile(
                title: const Text('Randomize Question Order?'),
                subtitle: Text(_isRandomized
                    ? 'Questions will be randomized'
                    : 'Questions appear in defined order'),
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
              const SizedBox(height: 30),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  minimumSize: const Size(double.infinity, 50), // Make button wide
                ),
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('CREATE QUIZ'),
                onPressed: _createQuiz,
              ),
              const SizedBox(height: 16), // Padding at the bottom
            ],
          ),
        ),
      ),
    );
  }
}

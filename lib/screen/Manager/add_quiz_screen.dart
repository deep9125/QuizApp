import 'package:flutter/material.dart';

// 1. IMPORT YOUR CENTRALIZED ManagerQuizSummary MODEL
// Make sure the class inside this file is named ManagerQuizSummary
import '../../Model/quiz_summary.dart';

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
  final TextEditingController _timerDurationController = TextEditingController();

  bool _hasTimer = false;
  bool _isRandomized = false;

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
    _selectedCategory = _predefinedCategories.first;
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
      _formKey.currentState!.save();

      final String category = _selectedCategory == 'Custom'
          ? _customCategoryController.text.trim()
          : _selectedCategory!;

      int? timerSeconds;
      if (_hasTimer) {
        final String durationText = _timerDurationController.text.trim();
        final int? parsedSeconds = int.tryParse(durationText);
        if (parsedSeconds == null || parsedSeconds <= 0) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Invalid timer duration. Please enter a positive number.')),
          );
          return;
        }
        timerSeconds = parsedSeconds;
      }

      // CHANGED: Create the new quiz object using the ManagerQuizSummary model
      final newQuiz = ManagerQuizSummary(
        id: 'new_quiz_${DateTime.now().millisecondsSinceEpoch}', // Mock ID
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(), // Assuming model supports this
        category: category,
        questionCount: 0,
        hasTimer: _hasTimer,
        isRandomized: _isRandomized,
        timerSeconds: timerSeconds, // Pass the parsed seconds
      );

      Navigator.of(context).pop(newQuiz);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Quiz'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
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
            crossAxisAlignment: CrossAxisAlignment.stretch,
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
                      _timerDurationController.text = '60'; // Default
                    }
                  });
                },
                secondary: const Icon(Icons.timer_outlined),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              if (_hasTimer) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _timerDurationController,
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
                subtitle: Text(_isRandomized
                    ? 'Questions will be randomized'
                    : 'Questions appear in order'),
                value: _isRandomized,
                onChanged: (bool value) {
                  setState(() {
                    _isRandomized = value;
                  });
                },
                secondary: const Icon(Icons.shuffle),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('CREATE QUIZ'),
                onPressed: _createQuiz,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
// lib/screen/add_quiz_screen.dart
import 'package:flutter/material.dart';
import '../Model/Question.dart';
import '../Model/Answer.dart';

class AddQuizScreen extends StatefulWidget {
  const AddQuizScreen({super.key});

  @override
  State<AddQuizScreen> createState() => _AddQuizScreenState();
}

class _AddQuizScreenState extends State<AddQuizScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _questionController = TextEditingController();
  final List<TextEditingController> _answerControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(), // Start with 3 answer fields, add more if needed
    TextEditingController(),
  ];
  int? _correctAnswerIndex; // Radio button group value

  // For simplicity, fixed number of answers. Can be made dynamic.
  final int _numberOfAnswers = 4;

  @override
  void dispose() {
    _questionController.dispose();
    for (var controller in _answerControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _saveQuiz() {
    if (_formKey.currentState!.validate()) {
      if (_correctAnswerIndex == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select the correct answer.')),
        );
        return;
      }

      List<Answer> answers = [];
      for (int i = 0; i < _numberOfAnswers; i++) {
        if (_answerControllers[i].text.isNotEmpty) { // Only add non-empty answers
          answers.add(Answer(
            ans: _answerControllers[i].text,
            isCorrect: i == _correctAnswerIndex,
          ));
        }
      }

      if (answers.length < 2) { // Need at least two options for a meaningful question
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please provide at least two answer options.')),
        );
        return;
      }

      Question newQuestion = Question(
        question: _questionController.text,
        answers: answers,
      );

      // Return the new question to the previous screen
      Navigator.pop(context, newQuestion);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Quiz Question'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _questionController,
                decoration: const InputDecoration(
                  labelText: 'Question',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the question.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              const Text('Answers:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              // Answer fields with radio buttons
              for (int i = 0; i < _numberOfAnswers; i++)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _answerControllers[i],
                          decoration: InputDecoration(
                            labelText: 'Answer ${i + 1}',
                            border: const OutlineInputBorder(),
                          ),
                          validator: (value) {
                            // Only validate first two answers as mandatory, others are optional
                            if (i < 2 && (value == null || value.isEmpty)) {
                              return 'Please enter answer ${i + 1}.';
                            }
                            // If an optional answer has a radio button selected but no text
                            if (_correctAnswerIndex == i && (value == null || value.isEmpty)){
                              return 'Please enter text for the correct answer.';
                            }
                            return null;
                          },
                        ),
                      ),
                      Radio<int>(
                        value: i,
                        groupValue: _correctAnswerIndex,
                        onChanged: (int? value) {
                          setState(() {
                            _correctAnswerIndex = value;
                          });
                        },
                      ),
                      const Text('Correct')
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveQuiz,
                style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    textStyle: const TextStyle(fontSize: 18)
                ),
                child: const Text('Save Question'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

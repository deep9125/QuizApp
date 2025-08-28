// lib/screens/welcome_screen.dart
import 'package:flutter/material.dart';
import '../QuizQuestions.dart';      // Uses getAllQuizQuestions and addQuizQuestion
import '../Model/Question.dart';
import './add_quiz_screen.dart'; // Import the new screen

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  List<Question> _currentQuestions = [];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  void _loadQuestions() {
    setState(() {
      _currentQuestions = getAllQuizQuestions();
    });
  }

  void _navigateToAddQuizScreen() async {
    // Navigate to AddQuizScreen and wait for a result
    final newQuestion = await Navigator.push<Question>(
      context,
      MaterialPageRoute(builder: (context) => const AddQuizScreen()),
    );

    // If a new question was returned (i.e., user saved it)
    if (newQuestion != null) {
      addQuizQuestion(newQuestion); // Add to our data source
      _loadQuestions(); // Reload questions to update the UI
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('New question added!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('All Quiz Questions'),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _currentQuestions.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'No quiz questions found.',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _navigateToAddQuizScreen,
              child: const Text('Add Your First Question'),
            )
          ],
        ),
      )
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: _currentQuestions.length,
        itemBuilder: (context, index) {
          final question = _currentQuestions[index];
          return Card(
            elevation: 2.0,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'Q${index + 1}: ${question.question}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  ...question.answers.map((answer) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 16.0, top: 4.0),
                      child: Text(
                        '- ${answer.ans} ${answer.isCorrect ? "(Correct)" : ""}', // Optionally show (Correct)
                        style: TextStyle(
                          fontSize: 16,
                          color: answer.isCorrect ? Colors.green.shade700 : Colors.black87,
                          fontWeight: answer.isCorrect ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToAddQuizScreen,
        icon: const Icon(Icons.add),
        label: const Text('Add Quiz'),
      ),
    );
  }
}

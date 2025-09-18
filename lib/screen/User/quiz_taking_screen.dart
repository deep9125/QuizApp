// screens/User/quiz_taking_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/user_service.dart';
import '../../Model/quiz_summary.dart';
import '../../Model/question.dart';
import 'result_screen.dart';

class QuizTakingScreen extends StatefulWidget {
  final ManagerQuizSummary quiz;

  const QuizTakingScreen({super.key, required this.quiz});

  @override
  State<QuizTakingScreen> createState() => _QuizTakingScreenState();
}

class _QuizTakingScreenState extends State<QuizTakingScreen> {
  final UserService _userService = UserService();
  bool _isLoading = true;
  List<ManagerQuestion> _questions = [];
  int _currentQuestionIndex = 0;
  final Map<String, String> _userAnswers = {};

  Timer? _timer;
  int _secondsRemaining = 0;

  @override
  void initState() {
    super.initState();
    _loadQuizData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadQuizData() async {
    setState(() => _isLoading = true);
    final questions = await _userService.getQuestionsForQuiz(widget.quiz.id);
    
    if (widget.quiz.isRandomized) {
      questions.shuffle();
    }
    
    if (mounted) {
      setState(() {
        _questions = questions;
        _isLoading = false;
        if (widget.quiz.hasTimer && widget.quiz.timerSeconds != null) {
          _secondsRemaining = widget.quiz.timerSeconds!;
          _startTimer();
        }
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        timer.cancel();
        _submitQuiz();
      }
    });
  }

  void _selectAnswer(String questionId, String answer) {
    setState(() {
      _userAnswers[questionId] = answer;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _questions.length - 1) {
      setState(() => _currentQuestionIndex++);
    } else {
      _submitQuiz();
    }
  }

  Future<void> _submitQuiz() async {
    _timer?.cancel();

    int correctAnswers = 0;
    for (var question in _questions) {
      // Case-insensitive comparison for fill-in-the-blank answers
      if (question.type == QuestionType.fillInBlank) {
        if (_userAnswers[question.id]?.trim().toLowerCase() == question.correctAnswer.toLowerCase()) {
          correctAnswers++;
        }
      } else {
        if (_userAnswers[question.id] == question.correctAnswer) {
          correctAnswers++;
        }
      }
    }

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    await _userService.submitQuizAttempt(
      quizId: widget.quiz.id,
      quizTitle: widget.quiz.title,
      userId: userId,
      score: correctAnswers,
      totalQuestions: _questions.length,
    );
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => QuizResultScreen(
            score: correctAnswers,
            totalQuestions: _questions.length,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isLastQuestion = _questions.isNotEmpty && _currentQuestionIndex == _questions.length - 1;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.quiz.title),
        actions: [
          if (widget.quiz.hasTimer)
            Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Center(child: Text('Time: $_secondsRemaining s')),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Question ${_currentQuestionIndex + 1} of ${_questions.length}',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: SingleChildScrollView( // Makes content scrollable if it overflows
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _questions[_currentQuestionIndex].text,
                                style: Theme.of(context).textTheme.headlineSmall,
                              ),
                              const SizedBox(height: 20),
                              ..._buildAnswerOptions(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _nextQuestion,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: Text(isLastQuestion ? 'Submit Quiz' : 'Next Question'),
                  ),
                ],
              ),
            ),
    );
  }

  // FIXED: This method now builds the correct UI for all question types.
  List<Widget> _buildAnswerOptions() {
    final question = _questions[_currentQuestionIndex];
    
    switch (question.type) {
      case QuestionType.multipleChoice:
        int correctIndex = int.tryParse(question.correctAnswer) ?? -1;
        return List.generate(question.options.length, (index) {
          return RadioListTile<int>(
            title: Text(question.options[index]),
            value: index,
            groupValue: int.tryParse(_userAnswers[question.id] ?? ''),
            onChanged: (value) {
              if (value != null) {
                _selectAnswer(question.id, value.toString());
              }
            },
          );
        });

      case QuestionType.trueFalse:
        return [
          RadioListTile<String>(
            title: const Text('True'),
            value: 'true',
            groupValue: _userAnswers[question.id],
            onChanged: (value) {
              if (value != null) _selectAnswer(question.id, value);
            },
          ),
          RadioListTile<String>(
            title: const Text('False'),
            value: 'false',
            groupValue: _userAnswers[question.id],
            onChanged: (value) {
              if (value != null) _selectAnswer(question.id, value);
            },
          ),
        ];

      case QuestionType.fillInBlank:
        return [
          TextFormField(
            initialValue: _userAnswers[question.id],
            decoration: const InputDecoration(
              labelText: 'Your Answer',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => _selectAnswer(question.id, value),
          ),
        ];

      case QuestionType.numeric:
        return [
          TextFormField(
            initialValue: _userAnswers[question.id],
            decoration: const InputDecoration(
              labelText: 'Numeric Answer',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
            onChanged: (value) => _selectAnswer(question.id, value),
          ),
        ];
        
      default:
        return [const Text('Error: Unsupported question type.')];
    }
  }
}
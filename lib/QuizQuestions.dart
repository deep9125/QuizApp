import './Model/Question.dart';
import './Model/Answer.dart';

// Initial set of questions
List<Question> _allQuestions = [
  Question(
    question: 'What is the capital of France?',
    answers: [
      Answer(ans: 'Berlin', isCorrect: false),
      Answer(ans: 'Madrid', isCorrect: false),
      Answer(ans: 'Paris', isCorrect: true),
      Answer(ans: 'Rome', isCorrect: false),
    ],
  ),
  Question(
    question: 'Which planet is known as the Red Planet?',
    answers: [
      Answer(ans: 'Earth', isCorrect: false),
      Answer(ans: 'Mars', isCorrect: true),
      Answer(ans: 'Jupiter', isCorrect: false),
      Answer(ans: 'Venus', isCorrect: false),
    ],
  ),
  // Add more initial questions if you like
];

// Function to get the current list of all questions
List<Question> getAllQuizQuestions() {
  return List.from(_allQuestions); // Return a copy to prevent direct modification from outside
}

// Function to add a new question
void addQuizQuestion(Question newQuestion) {
  _allQuestions.add(newQuestion);
  // In a real app, you'd save this to persistent storage here
}

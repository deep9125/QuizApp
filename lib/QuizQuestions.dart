import './Model/Question.dart';
import './Model/Answer.dart';
List<Question>  getQuizQuestions() { // Or QuizQuestions()
  return [
    Question(
      question: 'What is the capital of France?',
      answers: [
        Answer(ans: 'Berlin', isCorrect: false),
        Answer(ans: 'Madrid', isCorrect: false),
        Answer(ans: 'Paris', isCorrect: true),  // Mark the correct answer
        Answer(ans: 'Rome', isCorrect: false),
      ],
    ),
    Question(
      question: 'Which planet is known as the Red Planet?',
      answers: [
        Answer(ans: 'Earth', isCorrect: false),
        Answer(ans: 'Mars', isCorrect: true),   // Mark the correct answer
        Answer(ans: 'Jupiter', isCorrect: false),
        Answer(ans: 'Venus', isCorrect: false),
      ],
    ),
    Question(
      question: 'Who wrote "Romeo and Juliet"?',
      answers: [
        Answer(ans: 'Charles Dickens', isCorrect: false),
        Answer(ans: 'William Shakespeare', isCorrect: true), // Mark the correct answer
        Answer(ans: 'Jane Austen', isCorrect: false),
        Answer(ans: 'Mark Twain', isCorrect: false),
      ],
    ),
    Question(
      question: 'What is H2O commonly known as?',
      answers: [
        Answer(ans: 'Salt', isCorrect: false),
        Answer(ans: 'Sugar', isCorrect: false),
        Answer(ans: 'Water', isCorrect: true),  // Mark the correct answer
        Answer(ans: 'Oxygen', isCorrect: false),
      ],
    ),
    // Add more questions here
  ];
}
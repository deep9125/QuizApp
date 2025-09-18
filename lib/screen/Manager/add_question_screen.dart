import 'package:flutter/material.dart';
// 1. Make sure this import path is correct and the file contains the ManagerQuestion class.
import '../../Model/question.dart';

class AddQuestionScreen extends StatefulWidget {
  final String quizId;

  const AddQuestionScreen({
    super.key,
    required this.quizId,
  });

  @override
  State<AddQuestionScreen> createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _questionTextController;
  QuestionType _selectedQuestionType = QuestionType.multipleChoice;

  // State for Multiple Choice questions
  List<TextEditingController> _mcOptionControllers = [];
  List<bool> _mcIsCorrectOption = [];
  final int _minMcOptions = 2;
  final int _maxMcOptions = 6;

  // State for True/False questions
  bool? _tfCorrectAnswer;

  // State for Fill-in-the-blank and Numeric questions
  late TextEditingController _textBasedAnswerController;

  @override
  void initState() {
    super.initState();
    _questionTextController = TextEditingController();
    _textBasedAnswerController = TextEditingController();

    // Initialize fields for the default question type (Multiple Choice)
    _mcOptionControllers = List.generate(_minMcOptions, (_) => TextEditingController());
    _mcIsCorrectOption = List.generate(_minMcOptions, (index) => index == 0);
  }

  @override
  void dispose() {
    _questionTextController.dispose();
    _textBasedAnswerController.dispose();
    for (var controller in _mcOptionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _addMcOption() {
    if (_mcOptionControllers.length < _maxMcOptions) {
      setState(() {
        _mcOptionControllers.add(TextEditingController());
        _mcIsCorrectOption.add(false);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Maximum of $_maxMcOptions options allowed.')),
      );
    }
  }

  void _removeMcOption(int index) {
    if (_mcOptionControllers.length > _minMcOptions) {
      setState(() {
        bool wasCorrect = _mcIsCorrectOption[index];
        _mcOptionControllers.removeAt(index);
        _mcIsCorrectOption.removeAt(index);
        // If the removed option was the correct one, default to the first option
        if (wasCorrect && !_mcIsCorrectOption.contains(true) && _mcIsCorrectOption.isNotEmpty) {
          _mcIsCorrectOption[0] = true;
        }
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Minimum of $_minMcOptions options required.')),
      );
    }
  }

  void _setMcCorrectOption(int index) {
    setState(() {
      for (int i = 0; i < _mcIsCorrectOption.length; i++) {
        _mcIsCorrectOption[i] = (i == index);
      }
    });
  }

  void _createQuestion() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    String questionId = 'new_q_${widget.quizId}_${DateTime.now().millisecondsSinceEpoch}';
    String finalCorrectAnswer = '';
    List<String> finalOptions = [];

    switch (_selectedQuestionType) {
      case QuestionType.multipleChoice:
        finalOptions = _mcOptionControllers.map((c) => c.text.trim()).toList();
        int correctIndex = _mcIsCorrectOption.indexWhere((isCorrect) => isCorrect);
        if (correctIndex == -1) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please mark one option as correct.')),
          );
          return;
        }
        finalCorrectAnswer = correctIndex.toString(); // Store index as a string
        break;
      case QuestionType.trueFalse:
        if (_tfCorrectAnswer == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select True or False.')),
          );
          return;
        }
        finalCorrectAnswer = _tfCorrectAnswer.toString(); // "true" or "false"
        break;
      case QuestionType.fillInBlank:
      case QuestionType.numeric:
        finalCorrectAnswer = _textBasedAnswerController.text.trim();
        if (finalCorrectAnswer.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please provide the correct answer.')),
          );
          return;
        }
        break;
    }

    final ManagerQuestion newQuestion = ManagerQuestion(
      id: questionId, // This ID might be replaced by your backend service
      quizId: widget.quizId,
      text: _questionTextController.text.trim(),
      type: _selectedQuestionType,
      options: finalOptions,
      correctAnswer: finalCorrectAnswer,
    );

    // Return the created question object to the previous screen
    Navigator.of(context).pop(newQuestion);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Question'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            onPressed: _createQuestion,
            tooltip: 'Save Question',
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
                controller: _questionTextController,
                decoration: const InputDecoration(
                    labelText: 'Question Text*',
                    border: OutlineInputBorder(),
                    hintText: 'Enter the full text of the question'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Question text is required.' : null,
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<QuestionType>(
                value: _selectedQuestionType,
                decoration: const InputDecoration(
                    labelText: 'Question Type*',
                    border: OutlineInputBorder()),
                items: QuestionType.values
                    .map((type) => DropdownMenuItem<QuestionType>(
                        value: type, child: Text(_getQuestionTypeString(type))))
                    .toList(),
                onChanged: (QuestionType? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedQuestionType = newValue;
                      // Reset fields when type changes for a clean slate
                      _mcOptionControllers = List.generate(_minMcOptions, (_) => TextEditingController());
                      _mcIsCorrectOption = List.generate(_minMcOptions, (index) => index == 0);
                      _tfCorrectAnswer = null;
                      _textBasedAnswerController.clear();
                    });
                  }
                },
                validator: (value) => value == null ? 'Please select a question type.' : null,
              ),
              const SizedBox(height: 24),
              const Divider(thickness: 1),
              const SizedBox(height: 16),
              // Conditionally build the UI for the selected question type
              if (_selectedQuestionType == QuestionType.multipleChoice) _buildMultipleChoiceFields(),
              if (_selectedQuestionType == QuestionType.trueFalse) _buildTrueFalseFields(),
              if (_selectedQuestionType == QuestionType.fillInBlank) _buildFillInBlankFields(),
              if (_selectedQuestionType == QuestionType.numeric) _buildNumericFields(),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('ADD QUESTION'),
                onPressed: _createQuestion,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getQuestionTypeString(QuestionType type) {
    switch (type) {
      case QuestionType.multipleChoice:
        return 'Multiple Choice (MCQ)';
      case QuestionType.trueFalse:
        return 'True / False';
      case QuestionType.fillInBlank:
        return 'Fill in the Blank';
      case QuestionType.numeric:
        return 'Numeric Answer';
      default:
        return 'Unknown';
    }
  }

  Widget _buildMultipleChoiceFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Options & Correct Answer:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _mcOptionControllers.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0),
              child: Row(
                children: [
                  Radio<bool>(
                    value: true,
                    groupValue: _mcIsCorrectOption[index],
                    onChanged: (bool? value) {
                      if (value == true) {
                        _setMcCorrectOption(index);
                      }
                    },
                  ),
                  Expanded(
                    child: TextFormField(
                        controller: _mcOptionControllers[index],
                        decoration: InputDecoration(
                          labelText: 'Option ${index + 1}${_mcIsCorrectOption[index] ? " (Correct)" : ""}',
                          border: const OutlineInputBorder(),
                          hintText: 'Text for option ${index + 1}',
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Option text required.';
                          return null;
                        }),
                  ),
                  if (_mcOptionControllers.length > _minMcOptions)
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                      onPressed: () => _removeMcOption(index),
                      tooltip: 'Remove Option ${index + 1}',
                    ),
                ],
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        if (_mcOptionControllers.length < _maxMcOptions)
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Add Option'),
              onPressed: _addMcOption,
            ),
          ),
      ],
    );
  }

  Widget _buildTrueFalseFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Correct Answer:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        RadioListTile<bool>(
          title: const Text('True'),
          value: true,
          groupValue: _tfCorrectAnswer,
          onChanged: (bool? value) => setState(() => _tfCorrectAnswer = value),
        ),
        RadioListTile<bool>(
          title: const Text('False'),
          value: false,
          groupValue: _tfCorrectAnswer,
          onChanged: (bool? value) => setState(() => _tfCorrectAnswer = value),
        ),
      ],
    );
  }

  Widget _buildFillInBlankFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Correct Answer(s):', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        TextFormField(
          controller: _textBasedAnswerController,
          decoration: const InputDecoration(
              labelText: 'Expected Answer*',
              border: OutlineInputBorder(),
              hintText: 'The exact answer expected'),
          validator: (v) => (v == null || v.trim().isEmpty) ? 'Answer required.' : null,
        ),
        const SizedBox(height: 4),
        const Text('For multiple correct answers, separate with | (pipe)', style: TextStyle(fontSize: 12, color: Colors.grey))
      ],
    );
  }

  Widget _buildNumericFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Correct Answer:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        TextFormField(
          controller: _textBasedAnswerController,
          decoration: const InputDecoration(
              labelText: 'Numeric Value*',
              border: OutlineInputBorder(),
              hintText: 'e.g., 42 or 3.14'),
          keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Numeric answer required.';
            if (double.tryParse(v.trim()) == null) return 'Invalid number format.';
            return null;
          },
        ),
      ],
    );
  }
}
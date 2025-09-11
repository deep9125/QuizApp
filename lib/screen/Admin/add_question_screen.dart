import 'package:flutter/material.dart';

// 1. IMPORT YOUR CENTRALIZED AdminQuestion MODEL and QuestionType ENUM
// Adjust path if your model is elsewhere (e.g., ../../models/admin_question.dart or ../../model/question.dart)
import '../../Model/question.dart'; // Assuming AdminQuestion and QuestionType are here

class AddQuestionScreen extends StatefulWidget {
  final String quizId; // The quiz this new question belongs to

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
  // Ensure QuestionType is the one imported from your model file
  QuestionType _selectedQuestionType = QuestionType.multipleChoice;

  List<TextEditingController> _mcOptionControllers = [];
  List<bool> _mcIsCorrectOption = [];
  final int _minMcOptions = 2;
  final int _maxMcOptions = 6;

  bool? _tfCorrectAnswer;
  late TextEditingController _textBasedAnswerController;

  @override
  void initState() {
    super.initState();
    _questionTextController = TextEditingController();
    _textBasedAnswerController = TextEditingController();

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

    // The service will likely generate the final ID, but having a temporary one
    // or passing raw data is also an option. Here, we create one locally.
    String questionId = 'new_q_${widget.quizId}_${DateTime.now().millisecondsSinceEpoch}';
    String finalCorrectAnswer = '';
    List<String> finalOptions = [];

    switch (_selectedQuestionType) {
      case QuestionType.multipleChoice:
        finalOptions = _mcOptionControllers.map((c) => c.text.trim()).toList();
        int correctIndex = _mcIsCorrectOption.indexWhere((isCorrect) => isCorrect);
        if (correctIndex == -1 && finalOptions.any((opt) => opt.isNotEmpty)) { // Check if any option has text
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please mark one option as correct for MCQ.')),
          );
          return;
        }
        // Ensure that if no option is marked correct, but all options are empty, it's fine.
        // Or handle as an error if at least one option must be non-empty.
        // For now, if all options are empty, correctIndex will be -1, which is fine if options list is also empty.
        finalCorrectAnswer = correctIndex.toString(); // Store index as string
        break;
      case QuestionType.trueFalse:
        if (_tfCorrectAnswer == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select True or False as the correct answer.')),
          );
          return;
        }
        finalCorrectAnswer = _tfCorrectAnswer.toString(); // "true" or "false"
        break;
      case QuestionType.fillInBlank:
      case QuestionType.numeric: // Assuming numeric also uses textBasedAnswerController
        finalCorrectAnswer = _textBasedAnswerController.text.trim();
        if (finalCorrectAnswer.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please provide the correct answer.')),
          );
          return;
        }
        break;
    }

    // Ensure AdminQuestion is the imported model
    // CRITICAL: Pass widget.quizId to the quizId parameter
    final AdminQuestion newQuestion = AdminQuestion(
      id: questionId, // This ID might be replaced by the service
      quizId: widget.quizId, // <--- ADD THIS to associate with the current quiz
      text: _questionTextController.text.trim(),
      type: _selectedQuestionType,
      options: finalOptions,
      correctAnswer: finalCorrectAnswer,
    );

    Navigator.of(context).pop(newQuestion); // Return the fully formed AdminQuestion object
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Question'),
        backgroundColor: Colors.blueGrey[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined), // Changed icon
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
            crossAxisAlignment: CrossAxisAlignment.stretch, // Make button wider
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
              // Ensure QuestionType.values and _getQuestionTypeString use the imported enum
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
              // Conditional UI based on _selectedQuestionType
              if (_selectedQuestionType == QuestionType.multipleChoice) _buildMultipleChoiceFields(),
              if (_selectedQuestionType == QuestionType.trueFalse) _buildTrueFalseFields(),
              if (_selectedQuestionType == QuestionType.fillInBlank) _buildFillInBlankFields(),
              if (_selectedQuestionType == QuestionType.numeric) _buildNumericFields(),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  minimumSize: const Size(double.infinity, 50), // Make button wide
                ),
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('ADD QUESTION'),
                onPressed: _createQuestion,
              ),
              const SizedBox(height: 16), // Padding at the bottom
            ],
          ),
        ),
      ),
    );
  }

  // Ensure QuestionType used here is the imported one
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
                    onChanged: (bool? value) => (value == true) ? _setMcCorrectOption(index) : null,
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
                          // Option text is only required if it's not one of the first _minMcOptions
                          // or if any other option has text. This is a bit complex.
                          // A simpler validation: if any option is filled, all must be (or a certain number).
                          // Or, just make it required if visible.
                          // For now, keep it simple:
                          if (v == null || v.trim().isEmpty) return 'Option text required.';
                          return null;
                        }
                    ),
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
          activeColor: Theme.of(context).primaryColor,
        ),
        RadioListTile<bool>(
          title: const Text('False'),
          value: false,
          groupValue: _tfCorrectAnswer,
          onChanged: (bool? value) => setState(() => _tfCorrectAnswer = value),
          activeColor: Theme.of(context).primaryColor,
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
        const Text('For multiple correct (case-sensitive) answers, separate with | (pipe)', style: TextStyle(fontSize: 12, color: Colors.grey))
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

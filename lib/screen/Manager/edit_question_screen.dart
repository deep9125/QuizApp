import 'package:flutter/material.dart';
// 1. IMPORT YOUR CENTRALIZED ManagerQuestion MODEL
import '../../Model/question.dart'; // Assuming ManagerQuestion and QuestionType are here

class EditQuestionScreen extends StatefulWidget {
  final String quizId;
  // CHANGED: The question to edit is now a ManagerQuestion
  final ManagerQuestion questionToEdit;

  const EditQuestionScreen({
    super.key,
    required this.quizId,
    required this.questionToEdit,
  });

  @override
  State<EditQuestionScreen> createState() => _EditQuestionScreenState();
}

class _EditQuestionScreenState extends State<EditQuestionScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _questionTextController;
  late QuestionType _selectedQuestionType;

  List<TextEditingController> _mcOptionControllers = [];
  List<bool> _mcIsCorrectOption = [];
  final int _minMcOptions = 2;
  final int _maxMcOptions = 6;

  bool? _tfCorrectAnswer;
  late TextEditingController _textBasedAnswerController;

  @override
  void initState() {
    super.initState();
    // Use the passed-in ManagerQuestion object to initialize the state
    final q = widget.questionToEdit;

    _questionTextController = TextEditingController(text: q.text);
    _selectedQuestionType = q.type;
    _textBasedAnswerController = TextEditingController();

    switch (q.type) {
      case QuestionType.multipleChoice:
        _mcOptionControllers = q.options.map((optText) => TextEditingController(text: optText)).toList();
        _mcIsCorrectOption = List.generate(q.options.length, (index) => index.toString() == q.correctAnswer);

        if (!_mcIsCorrectOption.contains(true) && _mcIsCorrectOption.isNotEmpty) {
          _mcIsCorrectOption[0] = true;
        }
        while (_mcOptionControllers.length < _minMcOptions) {
          _mcOptionControllers.add(TextEditingController());
          _mcIsCorrectOption.add(false);
        }
        break;
      case QuestionType.trueFalse:
        _tfCorrectAnswer = q.correctAnswer.toLowerCase() == 'true';
        break;
      case QuestionType.fillInBlank:
      case QuestionType.numeric:
        _textBasedAnswerController.text = q.correctAnswer;
        break;
    }
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

  void _updateQuestion() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    String finalCorrectAnswer = '';
    List<String> finalOptions = [];

    switch (_selectedQuestionType) {
      case QuestionType.multipleChoice:
        finalOptions = _mcOptionControllers.map((c) => c.text.trim()).toList();
        int correctIndex = _mcIsCorrectOption.indexWhere((isCorrect) => isCorrect);
        if (correctIndex == -1 && finalOptions.any((opt) => opt.isNotEmpty)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please mark one MCQ option as correct.')),
          );
          return;
        }
        finalCorrectAnswer = correctIndex.toString();
        break;
      case QuestionType.trueFalse:
        if (_tfCorrectAnswer == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select True or False as the correct answer.')),
          );
          return;
        }
        finalCorrectAnswer = _tfCorrectAnswer.toString();
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

    // CHANGED: Create an updated question object using the ManagerQuestion model
    final ManagerQuestion updatedQuestion = ManagerQuestion(
      id: widget.questionToEdit.id,
      quizId: widget.questionToEdit.quizId,
      text: _questionTextController.text.trim(),
      type: _selectedQuestionType,
      options: finalOptions,
      correctAnswer: finalCorrectAnswer,
    );
    Navigator.of(context).pop(updatedQuestion);
  }

  // --- All other helper methods (_addMcOption, _getQuestionTypeString, etc.) are unchanged ---
  // --- The entire build method and its helpers are also unchanged ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit: ${widget.questionToEdit.text.length > 20 ? "${widget.questionToEdit.text.substring(0, 20)}..." : widget.questionToEdit.text}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_as_outlined),
            onPressed: _updateQuestion,
            tooltip: 'Update Question',
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
                  if (newValue != null && newValue != _selectedQuestionType) {
                    setState(() {
                      _selectedQuestionType = newValue;
                      // Reset fields when type changes
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
                icon: const Icon(Icons.save_as_outlined),
                label: const Text('UPDATE QUESTION'),
                onPressed: _updateQuestion,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Helper methods for building UI based on question type ---
  // These are identical to the ones in add_question_screen.dart

  void _addMcOption() {
      if (_mcOptionControllers.length < _maxMcOptions) {
          setState(() {
              _mcOptionControllers.add(TextEditingController());
              _mcIsCorrectOption.add(false);
          });
      }
  }

  void _removeMcOption(int index) {
      if (_mcOptionControllers.length > _minMcOptions) {
          setState(() {
              _mcOptionControllers.removeAt(index);
              _mcIsCorrectOption.removeAt(index);
          });
      }
  }

  void _setMcCorrectOption(int index) {
      setState(() {
          for (int i = 0; i < _mcIsCorrectOption.length; i++) {
              _mcIsCorrectOption[i] = (i == index);
          }
      });
  }

  String _getQuestionTypeString(QuestionType type) {
    switch (type) {
      case QuestionType.multipleChoice: return 'Multiple Choice (MCQ)';
      case QuestionType.trueFalse: return 'True / False';
      case QuestionType.fillInBlank: return 'Fill in the Blank';
      case QuestionType.numeric: return 'Numeric Answer';
      default: return 'Unknown';
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
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Option text required.' : null,
                    ),
                  ),
                  if (_mcOptionControllers.length > _minMcOptions)
                    IconButton(
                      icon: const Icon(Icons.remove_circle_outline, color: Colors.redAccent),
                      onPressed: () => _removeMcOption(index),
                    ),
                ],
              ),
            );
          },
        ),
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
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
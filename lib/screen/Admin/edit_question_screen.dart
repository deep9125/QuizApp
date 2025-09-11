import 'package:flutter/material.dart';

// 1. IMPORT YOUR CENTRALIZED AdminQuestion MODEL and QuestionType ENUM
// Adjust path if your model is elsewhere (e.g., ../../models/admin_question.dart or ../../model/question.dart)
import '../../Model/question.dart'; // Assuming AdminQuestion and QuestionType are here

class EditQuestionScreen extends StatefulWidget {
  final String quizId; // Quiz ID passed for context, though questionToEdit should also have it
  final AdminQuestion questionToEdit; // This should be an instance of the imported AdminQuestion

  const EditQuestionScreen({
    super.key,
    required this.quizId, // Keep for context or if questionToEdit might not have quizId initially (less ideal)
    required this.questionToEdit,
  });

  @override
  State<EditQuestionScreen> createState() => _EditQuestionScreenState();
}

class _EditQuestionScreenState extends State<EditQuestionScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _questionTextController;
  // Ensure QuestionType is the one imported from your model file
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
    final q = widget.questionToEdit; // Instance of imported AdminQuestion

    _questionTextController = TextEditingController(text: q.text);
    _selectedQuestionType = q.type;
    _textBasedAnswerController = TextEditingController(); // Initialize always, populate below

    switch (q.type) {
      case QuestionType.multipleChoice:
      // Ensure q.options and q.correctAnswer are compatible with how they are stored
        _mcOptionControllers = q.options.map((optText) => TextEditingController(text: optText)).toList();
        // If q.options is empty but should have min options, initialize them
        if (_mcOptionControllers.length < _minMcOptions && _mcOptionControllers.isEmpty) { // Only if completely empty from model
          _mcOptionControllers = List.generate(_minMcOptions, (_) => TextEditingController());
          _mcIsCorrectOption = List.generate(_minMcOptions, (i) => i == 0); // Default first if new
        } else {
          _mcIsCorrectOption = List.generate(q.options.length, (index) => index.toString() == q.correctAnswer);
        }

        // If no option was marked correct (e.g. data issue or new structure), default to first
        if (!_mcIsCorrectOption.contains(true) && _mcIsCorrectOption.isNotEmpty) {
          _mcIsCorrectOption[0] = true;
        }
        // Ensure minimum options if loaded data has less (but not if empty, handled above)
        while (_mcOptionControllers.length < _minMcOptions && _mcOptionControllers.isNotEmpty) {
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
        // Ensure at least one option is marked correct if there are options with text
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

    // Create an updated question object using the imported AdminQuestion model
    // CRITICAL: Ensure widget.questionToEdit.quizId is used
    final AdminQuestion updatedQuestion = AdminQuestion(
      id: widget.questionToEdit.id, // Keep original question ID
      quizId: widget.questionToEdit.quizId, // CRITICAL: Preserve the original quizId
      text: _questionTextController.text.trim(),
      type: _selectedQuestionType,
      options: finalOptions,
      correctAnswer: finalCorrectAnswer,
    );
    Navigator.of(context).pop(updatedQuestion);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit: ${widget.questionToEdit.text.length > 20 ? "${widget.questionToEdit.text.substring(0,20)}..." : widget.questionToEdit.text}'),
        backgroundColor: Colors.blueGrey[700],
        actions: [
          IconButton(
            icon: const Icon(Icons.save_as_outlined), // Changed icon
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
                  if (newValue != null && newValue != _selectedQuestionType) { // Prevent reset if same type selected
                    setState(() {
                      _selectedQuestionType = newValue;
                      // Reset relevant fields when type changes
                      // For MC: initialize with min options, first as correct
                      _mcOptionControllers = List.generate(_minMcOptions, (_) => TextEditingController());
                      _mcIsCorrectOption = List.generate(_minMcOptions, (index) => index == 0);
                      _tfCorrectAnswer = null; // Reset T/F
                      _textBasedAnswerController.clear(); // Reset Fill/Numeric
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
                  backgroundColor: Colors.blueGrey[600], // Consistent with other update buttons
                  foregroundColor: Colors.white,
                  textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  minimumSize: const Size(double.infinity, 50), // Make button wide
                ),
                icon: const Icon(Icons.save_as_outlined),
                label: const Text('UPDATE QUESTION'),
                onPressed: _updateQuestion,
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
      case QuestionType.multipleChoice: return 'Multiple Choice (MCQ)';
      case QuestionType.trueFalse: return 'True / False';
      case QuestionType.fillInBlank: return 'Fill in the Blank';
      case QuestionType.numeric: return 'Numeric Answer';
      default: return 'Unknown';
    }
  }

  // --- UI Builder Methods (Copy from AddQuestionScreen or keep as is if already identical) ---
  // For brevity, assuming these are identical to the versions provided for AddQuestionScreen
  // with the same controller names (_mcOptionControllers, _mcIsCorrectOption, etc.)
  // If you copy, ensure they use the local state variables of this _EditQuestionScreenState.

  Widget _buildMultipleChoiceFields() {
    // This should be identical to _buildMultipleChoiceFields in AddQuestionScreen,
    // using this screen's _mcOptionControllers, _mcIsCorrectOption, etc.
    // Example (ensure controllers are this screen's instance variables):
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
                    groupValue: _mcIsCorrectOption[index], // Use this screen's state
                    onChanged: (bool? value) => (value == true) ? _setMcCorrectOption(index) : null,
                  ),
                  Expanded(
                    child: TextFormField(
                      controller: _mcOptionControllers[index], // Use this screen's state
                      decoration: InputDecoration(
                        labelText: 'Option ${index + 1}${_mcIsCorrectOption[index] ? " (Correct)" : ""}',
                        border: const OutlineInputBorder(),
                        hintText: 'Text for option ${index + 1}',
                      ),
                      validator: (v) => (v == null || v.trim().isEmpty) ? 'Option text required.' : null,
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
    // Identical to AddQuestionScreen, using this screen's _tfCorrectAnswer
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Correct Answer:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        RadioListTile<bool>(
          title: const Text('True'),
          value: true,
          groupValue: _tfCorrectAnswer, // Use this screen's state
          onChanged: (bool? value) => setState(() => _tfCorrectAnswer = value),
          activeColor: Theme.of(context).primaryColor,
        ),
        RadioListTile<bool>(
          title: const Text('False'),
          value: false,
          groupValue: _tfCorrectAnswer, // Use this screen's state
          onChanged: (bool? value) => setState(() => _tfCorrectAnswer = value),
          activeColor: Theme.of(context).primaryColor,
        ),
      ],
    );
  }

  Widget _buildFillInBlankFields() {
    // Identical to AddQuestionScreen, using this screen's _textBasedAnswerController
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Correct Answer(s):', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        TextFormField(
          controller: _textBasedAnswerController, // Use this screen's state
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
    // Identical to AddQuestionScreen, using this screen's _textBasedAnswerController
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Correct Answer:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        TextFormField(
          controller: _textBasedAnswerController, // Use this screen's state
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

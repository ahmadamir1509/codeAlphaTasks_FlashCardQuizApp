import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/flashcard_model.dart';
import '../providers/flashcard_provider.dart';

class AddEditFlashcardScreen extends StatefulWidget {
  final Flashcard? flashcard;

  const AddEditFlashcardScreen({super.key, this.flashcard});

  @override
  State<AddEditFlashcardScreen> createState() =>
      _AddEditFlashcardScreenState();
}

class _AddEditFlashcardScreenState extends State<AddEditFlashcardScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _questionController;
  late TextEditingController _answerController;

  bool get isEditing => widget.flashcard != null;

  @override
  void initState() {
    super.initState();
    _questionController =
        TextEditingController(text: widget.flashcard?.question ?? '');
    _answerController =
        TextEditingController(text: widget.flashcard?.answer ?? '');
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    super.dispose();
  }

  void _saveFlashcard() {
    if (_formKey.currentState!.validate()) {
      final provider = context.read<FlashcardProvider>();
      if (isEditing) {
        provider.editFlashcard(
          id: widget.flashcard!.id,
          question: _questionController.text.trim(),
          answer: _answerController.text.trim(), category: '',
        );
      } else {
        provider.addFlashcard(
          question: _questionController.text.trim(),
          answer: _answerController.text.trim(),
          category: '',
        );
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Flashcard' : 'Add Flashcard'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _questionController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Question',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a question';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _answerController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'Answer',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter an answer';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _saveFlashcard,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                child: Text(isEditing ? 'Update Flashcard' : 'Add Flashcard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
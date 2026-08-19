import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/flashcard_provider.dart';
import '../models/flashcard_model.dart';

class CreateFlashcardScreen extends StatefulWidget {
  final FlashcardModel? flashcard; // null = create, not null = edit

  const CreateFlashcardScreen({super.key, this.flashcard});

  @override
  State<CreateFlashcardScreen> createState() => _CreateFlashcardScreenState();
}

class _CreateFlashcardScreenState extends State<CreateFlashcardScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _questionController;
  late TextEditingController _answerController;
  late TextEditingController _newCategoryController;
  String? _selectedCategory;
  bool _isAddingNewCategory = false;

  bool get isEditing => widget.flashcard != null;

  @override
  void initState() {
    super.initState();
    _questionController =
        TextEditingController(text: widget.flashcard?.question ?? '');
    _answerController =
        TextEditingController(text: widget.flashcard?.answer ?? '');
    _newCategoryController = TextEditingController();
    _selectedCategory = widget.flashcard?.category;
  }

  @override
  void dispose() {
    _questionController.dispose();
    _answerController.dispose();
    _newCategoryController.dispose();
    super.dispose();
  }

  // Adds the typed category immediately to the provider's category list
  // and selects it, without waiting for the flashcard to be saved.
  void _addNewCategory() {
    final newCategory = _newCategoryController.text.trim();
    if (newCategory.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please type a category name first')),
      );
      return;
    }

    context.read<FlashcardProvider>().addCategory(newCategory);

    setState(() {
      _selectedCategory = newCategory;
      _isAddingNewCategory = false;
      _newCategoryController.clear();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Category "$newCategory" added')),
    );
  }

  void _saveFlashcard() {
    if (!_formKey.currentState!.validate()) return;

    final category = _selectedCategory ?? '';

    if (category.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select or add a category')),
      );
      return;
    }

    final provider = context.read<FlashcardProvider>();
    if (isEditing) {
      provider.editFlashcard(
        id: widget.flashcard!.id,
        question: _questionController.text.trim(),
        answer: _answerController.text.trim(),
        category: category,
      );
    } else {
      provider.addFlashcard(
        question: _questionController.text.trim(),
        answer: _answerController.text.trim(),
        category: category,
      );
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(isEditing ? 'Flashcard updated!' : 'Flashcard saved!'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<FlashcardProvider>().categories;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Flashcard' : 'Create Flashcard'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Question',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _questionController,
                maxLines: 3,
                decoration: _inputDecoration('Enter your question'),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Question is required'
                    : null,
              ),
              const SizedBox(height: 20),
              Text(
                'Answer',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _answerController,
                maxLines: 3,
                decoration: _inputDecoration('Enter the answer'),
                validator: (value) => (value == null || value.trim().isEmpty)
                    ? 'Answer is required'
                    : null,
              ),
              const SizedBox(height: 20),
              Text(
                'Category',
                style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ...categories.map((cat) {
                    final selected = _selectedCategory == cat && !_isAddingNewCategory;
                    return ChoiceChip(
                      label: Text(cat),
                      selected: selected,
                      selectedColor: Colors.deepPurple.withOpacity(0.2),
                      onSelected: (_) {
                        setState(() {
                          _selectedCategory = cat;
                          _isAddingNewCategory = false;
                        });
                      },
                    );
                  }),
                  ChoiceChip(
                    label: const Text('+ New Category'),
                    selected: _isAddingNewCategory,
                    selectedColor: Colors.deepPurple.withOpacity(0.2),
                    onSelected: (_) {
                      setState(() {
                        _isAddingNewCategory = true;
                        _selectedCategory = null;
                      });
                    },
                  ),
                ],
              ),
              if (_isAddingNewCategory) ...[
                const SizedBox(height: 12),
                TextFormField(
                  controller: _newCategoryController,
                  decoration: _inputDecoration('Enter new category name'),
                  onFieldSubmitted: (_) => _addNewCategory(),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _addNewCategory,
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add Category'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveFlashcard,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: Text(isEditing ? 'Update Flashcard' : 'Save Flashcard'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }
}
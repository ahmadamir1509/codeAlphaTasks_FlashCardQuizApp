import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/flashcard_provider.dart';
import '../providers/quiz_provider.dart';
import 'quiz_screen.dart';

class QuizSetupScreen extends StatefulWidget {
  const QuizSetupScreen({super.key});

  @override
  State<QuizSetupScreen> createState() => _QuizSetupScreenState();
}

class _QuizSetupScreenState extends State<QuizSetupScreen> {
  String _selectedCategory = 'All';
  int _questionCount = 10;

  @override
  Widget build(BuildContext context) {
    final flashcardProvider = context.watch<FlashcardProvider>();
    final categories = ['All', ...flashcardProvider.categories];

    // How many cards are actually available for the chosen category
    final availableCards = _selectedCategory == 'All'
        ? flashcardProvider.flashcards
        : flashcardProvider.filterByCategory(_selectedCategory);

    final maxQuestions = availableCards.length;

    return Scaffold(
      appBar: AppBar(title: const Text('Quiz Setup')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose Category',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: categories.map((cat) {
                final selected = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                );
              }).toList(),
            ),
            const SizedBox(height: 28),
            Text(
              'Number of Questions',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              '$maxQuestions flashcard(s) available in this category',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 12),
            if (maxQuestions > 0)
              Slider(
                value: _questionCount.clamp(1, maxQuestions).toDouble(),
                min: 1,
                max: maxQuestions.toDouble(),
                divisions: maxQuestions > 1 ? maxQuestions - 1 : 1,
                label: '$_questionCount',
                onChanged: (value) {
                  setState(() => _questionCount = value.round());
                },
              ),
            Center(
              child: Text(
                '$_questionCount Questions',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            const Spacer(),
            ElevatedButton.icon(
              onPressed: maxQuestions == 0
                  ? null
                  : () {
                      context.read<QuizProvider>().generateQuiz(
                            availableCards,
                            questionCount: _questionCount,
                          );
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const QuizScreen()),
                      );
                    },
              icon: const Icon(Icons.play_arrow_rounded),
              label: const Text('Start Quiz'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
            if (maxQuestions == 0) ...[
              const SizedBox(height: 12),
              Text(
                'No flashcards in this category yet. Add some first!',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(fontSize: 12, color: Colors.red),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
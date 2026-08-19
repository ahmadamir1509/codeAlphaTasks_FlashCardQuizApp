import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:flip_card/flip_card.dart';
import '../providers/flashcard_provider.dart';
import '../models/flashcard_model.dart';

class StudyModeScreen extends StatefulWidget {
  final String? initialCardId; // optional - jump to a specific card

  const StudyModeScreen({super.key, this.initialCardId});

  @override
  State<StudyModeScreen> createState() => _StudyModeScreenState();
}

class _StudyModeScreenState extends State<StudyModeScreen> {
  final GlobalKey<FlipCardState> _flipKey = GlobalKey<FlipCardState>();
  List<FlashcardModel> _cards = [];
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Defer until after first frame so provider is available
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadCards();
    });
  }

  void _loadCards() {
    final provider = context.read<FlashcardProvider>();
    setState(() {
      _cards = [...provider.flashcards];
      if (widget.initialCardId != null) {
        final idx = _cards.indexWhere((c) => c.id == widget.initialCardId);
        if (idx != -1) _currentIndex = idx;
      }
    });
  }

  void _next() {
    if (_cards.isEmpty) return;
    _flipKey.currentState?.controller?.value = 0; // reset to front
    setState(() {
      _currentIndex = (_currentIndex + 1) % _cards.length;
    });
  }

  void _previous() {
    if (_cards.isEmpty) return;
    _flipKey.currentState?.controller?.value = 0;
    setState(() {
      _currentIndex = (_currentIndex - 1 + _cards.length) % _cards.length;
    });
  }

  void _shuffle() {
    if (_cards.isEmpty) return;
    setState(() {
      _cards.shuffle();
      _currentIndex = 0;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cards shuffled!'),
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _markAsLearned() {
    if (_cards.isEmpty) return;
    final card = _cards[_currentIndex];
    context.read<FlashcardProvider>().toggleLearned(card.id);
    setState(() {}); // refresh learned icon
  }

  @override
  Widget build(BuildContext context) {
    if (_cards.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Study Mode')),
        body: Center(
          child: Text(
            'No flashcards to study yet.\nCreate one first!',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: Colors.grey),
          ),
        ),
      );
    }

    final card = _cards[_currentIndex];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Study Mode'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shuffle),
            tooltip: 'Shuffle',
            onPressed: _shuffle,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Card ${_currentIndex + 1} of ${_cards.length}',
              style: GoogleFonts.poppins(color: Colors.grey.shade600),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                card.category,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Colors.deepPurple,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: FlipCard(
                key: _flipKey,
                direction: FlipDirection.HORIZONTAL,
                front: _buildCardFace(
                  text: card.question,
                  label: 'QUESTION',
                  gradientColors: [Colors.white, Colors.grey.shade100],
                  textColor: Colors.black87,
                ),
                back: _buildCardFace(
                  text: card.answer,
                  label: 'ANSWER',
                  gradientColors: [Colors.deepPurple, Colors.deepPurple.shade300],
                  textColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the card to flip',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _markAsLearned,
              icon: Icon(
                card.isLearned ? Icons.check_circle : Icons.check_circle_outline,
              ),
              label: Text(card.isLearned ? 'Learned ✓' : 'Mark as Learned'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                backgroundColor: card.isLearned ? Colors.green : null,
                foregroundColor: card.isLearned ? Colors.white : null,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: _previous,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Previous'),
                ),
                ElevatedButton.icon(
                  onPressed: _next,
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Next'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardFace({
    required String text,
    required String label,
    required List<Color> gradientColors,
    required Color textColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                  color: textColor.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                text,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
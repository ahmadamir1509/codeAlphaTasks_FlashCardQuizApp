import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/flashcard_provider.dart';
import '../models/flashcard_model.dart';
import 'create_flashcard_screen.dart';
import 'study_mode_screen.dart';

class MyFlashcardsScreen extends StatefulWidget {
  const MyFlashcardsScreen({super.key});

  @override
  State<MyFlashcardsScreen> createState() => _MyFlashcardsScreenState();
}

class _MyFlashcardsScreenState extends State<MyFlashcardsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'All';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _confirmDelete(BuildContext context, FlashcardModel card) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Flashcard'),
        content: const Text('Are you sure you want to delete this flashcard?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<FlashcardProvider>().deleteFlashcard(card.id);
              Navigator.pop(ctx);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<FlashcardProvider>();

    // Apply search first, then category filter
    List<FlashcardModel> cards = _searchQuery.isEmpty
        ? provider.flashcards
        : provider.search(_searchQuery);

    if (_selectedCategory != 'All') {
      cards = cards.where((c) => c.category == _selectedCategory).toList();
    }

    final categories = ['All', ...provider.categories];

    return Scaffold(
      appBar: AppBar(title: const Text('My Flashcards')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              decoration: InputDecoration(
                hintText: 'Search question, answer, or category',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = categories[index];
                final selected = _selectedCategory == cat;
                return ChoiceChip(
                  label: Text(cat),
                  selected: selected,
                  onSelected: (_) => setState(() => _selectedCategory = cat),
                );
              },
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: cards.isEmpty
                ? Center(
                    child: Text(
                      'No flashcards found',
                      style: GoogleFonts.poppins(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                    itemCount: cards.length,
                    itemBuilder: (context, index) {
                      final card = cards[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
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
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      card.isFavorite
                                          ? Icons.favorite
                                          : Icons.favorite_border,
                                      color: card.isFavorite ? Colors.red : null,
                                    ),
                                    onPressed: () => context
                                        .read<FlashcardProvider>()
                                        .toggleFavorite(card.id),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                card.question,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                card.answer,
                                style: GoogleFonts.poppins(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  TextButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => StudyModeScreen(
                                            initialCardId: card.id,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.menu_book, size: 18),
                                    label: const Text('Study'),
                                  ),
                                  TextButton.icon(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => CreateFlashcardScreen(
                                            flashcard: card,
                                          ),
                                        ),
                                      );
                                    },
                                    icon: const Icon(Icons.edit, size: 18),
                                    label: const Text('Edit'),
                                  ),
                                  TextButton.icon(
                                    onPressed: () => _confirmDelete(context, card),
                                    icon: const Icon(Icons.delete,
                                        size: 18, color: Colors.red),
                                    label: const Text('Delete',
                                        style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateFlashcardScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
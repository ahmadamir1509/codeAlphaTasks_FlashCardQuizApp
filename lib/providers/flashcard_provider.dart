import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/flashcard_model.dart';
import '../utils/constants.dart';

class FlashcardProvider extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  List<FlashcardModel> _flashcards = [];
  List<String> _categories = [...AppConstants.defaultCategories];
  bool _isLoading = false;

  List<FlashcardModel> get flashcards => _flashcards;
  List<String> get categories => _categories;
  bool get isLoading => _isLoading;

  List<FlashcardModel> get favorites =>
      _flashcards.where((c) => c.isFavorite).toList();

  List<FlashcardModel> get learnedCards =>
      _flashcards.where((c) => c.isLearned).toList();

  // Reference to the current logged-in user's flashcards collection
  CollectionReference<Map<String, dynamic>>? get _userCollection {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    return _firestore.collection('users').doc(uid).collection('flashcards');
  }

  // Call this right after login/register, and on app start if already logged in
  Future<void> loadFlashcards() async {
    final collection = _userCollection;
    if (collection == null) return;

    _isLoading = true;
    notifyListeners();

    final snapshot = await collection.orderBy('createdAt', descending: true).get();
    _flashcards = snapshot.docs
        .map((doc) => FlashcardModel.fromMap(doc.id, doc.data()))
        .toList();

    // Rebuild category list from default + any custom ones already used
    final usedCategories = _flashcards.map((c) => c.category).toSet();
    _categories = {...AppConstants.defaultCategories, ...usedCategories}.toList();

    _isLoading = false;
    notifyListeners();
  }

  void addCategory(String category) {
    if (!_categories.contains(category)) {
      _categories.add(category);
      notifyListeners();
    }
  }

  Future<void> addFlashcard({
    required String question,
    required String answer,
    required String category,
  }) async {
    final collection = _userCollection;
    if (collection == null) return;

    final card = FlashcardModel(
      id: '',
      question: question,
      answer: answer,
      category: category,
    );

    final docRef = await collection.add(card.toMap());
    card.id = docRef.id;
    _flashcards.insert(0, card);
    notifyListeners();
  }

  Future<void> editFlashcard({
    required String id,
    required String question,
    required String answer,
    required String category,
  }) async {
    final collection = _userCollection;
    if (collection == null) return;

    final index = _flashcards.indexWhere((c) => c.id == id);
    if (index == -1) return;

    _flashcards[index]
      ..question = question
      ..answer = answer
      ..category = category;

    await collection.doc(id).update({
      'question': question,
      'answer': answer,
      'category': category,
    });
    notifyListeners();
  }

  Future<void> deleteFlashcard(String id) async {
    final collection = _userCollection;
    if (collection == null) return;

    await collection.doc(id).delete();
    _flashcards.removeWhere((c) => c.id == id);
    notifyListeners();
  }

  Future<void> toggleFavorite(String id) async {
    final collection = _userCollection;
    if (collection == null) return;

    final index = _flashcards.indexWhere((c) => c.id == id);
    if (index == -1) return;

    _flashcards[index].isFavorite = !_flashcards[index].isFavorite;
    await collection.doc(id).update({'isFavorite': _flashcards[index].isFavorite});
    notifyListeners();
  }

  Future<void> toggleLearned(String id) async {
    final collection = _userCollection;
    if (collection == null) return;

    final index = _flashcards.indexWhere((c) => c.id == id);
    if (index == -1) return;

    _flashcards[index].isLearned = !_flashcards[index].isLearned;
    await collection.doc(id).update({'isLearned': _flashcards[index].isLearned});
    notifyListeners();
  }

  List<FlashcardModel> search(String query) {
    if (query.trim().isEmpty) return _flashcards;
    final lowerQuery = query.toLowerCase();
    return _flashcards.where((card) {
      return card.question.toLowerCase().contains(lowerQuery) ||
          card.answer.toLowerCase().contains(lowerQuery) ||
          card.category.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  List<FlashcardModel> filterByCategory(String category) {
    if (category == 'All') return _flashcards;
    return _flashcards.where((c) => c.category == category).toList();
  }

  Future<void> resetProgress() async {
    final collection = _userCollection;
    if (collection == null) return;

    for (final card in _flashcards) {
      card.isLearned = false;
      card.isFavorite = false;
      await collection.doc(card.id).update({
        'isLearned': false,
        'isFavorite': false,
      });
    }
    notifyListeners();
  }

  // Call this on logout to clear in-memory data
  void clearLocalData() {
    _flashcards = [];
    _categories = [...AppConstants.defaultCategories];
    notifyListeners();
  }
}
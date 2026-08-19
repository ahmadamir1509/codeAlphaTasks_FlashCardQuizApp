import 'dart:math';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/flashcard_model.dart';
import '../models/quiz_result_model.dart';
import '../utils/constants.dart';

class QuizQuestion {
  final FlashcardModel flashcard;
  final String correctAnswer;

  QuizQuestion({
    required this.flashcard,
    required this.correctAnswer,
  });
}

class QuizProvider extends ChangeNotifier {
  final Box<QuizResultModel> _historyBox = Hive.box<QuizResultModel>(
    AppConstants.quizHistoryBox,
  );

  List<QuizQuestion> _questions = [];
  int _currentIndex = 0;
  int _correctCount = 0;
  int _wrongCount = 0;
  String? _userAnswer;
  bool _answered = false;

  List<QuizQuestion> get questions => _questions;
  int get currentIndex => _currentIndex;
  int get correctCount => _correctCount;
  int get wrongCount => _wrongCount;
  String? get userAnswer => _userAnswer;
  bool get answered => _answered;

  QuizQuestion? get currentQuestion =>
      _questions.isEmpty ? null : _questions[_currentIndex];

  double get progress =>
      _questions.isEmpty ? 0 : (_currentIndex + 1) / _questions.length;

  bool get isLastQuestion => _currentIndex == _questions.length - 1;

  // Generate quiz questions from flashcards - user types the answer for each
  void generateQuiz(List<FlashcardModel> flashcards, {int questionCount = 10}) {
    final random = Random();
    final shuffled = [...flashcards]..shuffle(random);
    final selected = shuffled.take(questionCount).toList();

    _questions = selected.map((card) {
      return QuizQuestion(
        flashcard: card,
        correctAnswer: card.answer,
      );
    }).toList();

    _currentIndex = 0;
    _correctCount = 0;
    _wrongCount = 0;
    _userAnswer = null;
    _answered = false;
    notifyListeners();
  }

  // Check the typed answer against the flashcard's saved answer
  void submitAnswer(String answer) {
    if (_answered) return;
    _userAnswer = answer;
    _answered = true;

    final isCorrect = _normalize(answer) == _normalize(currentQuestion!.correctAnswer);

    if (isCorrect) {
      _correctCount++;
    } else {
      _wrongCount++;
    }
    notifyListeners();
  }

  // Normalize text before comparing - trims spaces, lowercases,
  // and removes extra internal spaces/punctuation for a fairer match
  String _normalize(String text) {
    return text
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[^\w\s]'), '');
  }

  void nextQuestion() {
    if (_currentIndex < _questions.length - 1) {
      _currentIndex++;
      _userAnswer = null;
      _answered = false;
      notifyListeners();
    }
  }

  // Save result to history and return the result model
  QuizResultModel finishQuiz() {
    final total = _questions.length;
    final percentage = total == 0 ? 0.0 : (_correctCount / total) * 100;

    final result = QuizResultModel(
      totalQuestions: total,
      correctAnswers: _correctCount,
      wrongAnswers: _wrongCount,
      percentage: percentage,
    );

    _historyBox.add(result);
    return result;
  }

  List<QuizResultModel> get history => _historyBox.values.toList();

  double get highestScore {
    if (history.isEmpty) return 0;
    return history.map((r) => r.percentage).reduce(max);
  }

  double get averageScore {
    if (history.isEmpty) return 0;
    final total = history.map((r) => r.percentage).reduce((a, b) => a + b);
    return total / history.length;
  }

  Future<void> clearHistory() async {
    await _historyBox.clear();
    notifyListeners();
  }
}
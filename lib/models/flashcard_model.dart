import 'package:hive/hive.dart';

part 'flashcard_model.g.dart';

class FlashcardModel {
  String id;
  String question;
  String answer;
  String category;
  bool isFavorite;
  bool isLearned;
  DateTime createdAt;

  FlashcardModel({
    required this.id,
    required this.question,
    required this.answer,
    required this.category,
    this.isFavorite = false,
    this.isLearned = false,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'answer': answer,
      'category': category,
      'isFavorite': isFavorite,
      'isLearned': isLearned,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory FlashcardModel.fromMap(String id, Map<String, dynamic> map) {
    return FlashcardModel(
      id: id,
      question: map['question'] ?? '',
      answer: map['answer'] ?? '',
      category: map['category'] ?? 'General',
      isFavorite: map['isFavorite'] ?? false,
      isLearned: map['isLearned'] ?? false,
      createdAt: DateTime.tryParse(map['createdAt'] ?? '') ?? DateTime.now(),
    );
  }
}
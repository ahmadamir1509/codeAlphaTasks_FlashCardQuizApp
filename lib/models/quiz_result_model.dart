import 'package:hive/hive.dart';

part 'quiz_result_model.g.dart';

@HiveType(typeId: 1)
class QuizResultModel extends HiveObject {
  @HiveField(0)
  int totalQuestions;

  @HiveField(1)
  int correctAnswers;

  @HiveField(2)
  int wrongAnswers;

  @HiveField(3)
  double percentage;

  @HiveField(4)
  DateTime attemptedAt;

  QuizResultModel({
    required this.totalQuestions,
    required this.correctAnswers,
    required this.wrongAnswers,
    required this.percentage,
    DateTime? attemptedAt,
  }) : attemptedAt = attemptedAt ?? DateTime.now();
}
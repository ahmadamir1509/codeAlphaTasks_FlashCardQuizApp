// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quiz_result_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QuizResultModelAdapter extends TypeAdapter<QuizResultModel> {
  @override
  final int typeId = 1;

  @override
  QuizResultModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QuizResultModel(
      totalQuestions: fields[0] as int,
      correctAnswers: fields[1] as int,
      wrongAnswers: fields[2] as int,
      percentage: fields[3] as double,
      attemptedAt: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, QuizResultModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.totalQuestions)
      ..writeByte(1)
      ..write(obj.correctAnswers)
      ..writeByte(2)
      ..write(obj.wrongAnswers)
      ..writeByte(3)
      ..write(obj.percentage)
      ..writeByte(4)
      ..write(obj.attemptedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QuizResultModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

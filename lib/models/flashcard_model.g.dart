// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'flashcard_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FlashcardModelAdapter extends TypeAdapter<FlashcardModel> {
  @override
  final int typeId = 0;

  @override
  FlashcardModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FlashcardModel(
      id: fields[0] as String,
      question: fields[1] as String,
      answer: fields[2] as String,
      category: fields[3] as String,
      isFavorite: fields[4] as bool,
      isLearned: fields[5] as bool,
      createdAt: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, FlashcardModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.question)
      ..writeByte(2)
      ..write(obj.answer)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.isFavorite)
      ..writeByte(5)
      ..write(obj.isLearned)
      ..writeByte(6)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FlashcardModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

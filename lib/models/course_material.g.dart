// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_material.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CourseMaterialAdapter extends TypeAdapter<CourseMaterial> {
  @override
  final int typeId = 2;

  @override
  CourseMaterial read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CourseMaterial(
      id: fields[0] as String,
      title: fields[1] as String,
      url: fields[2] as String,
      sizeBytes: fields[3] as int,
      sectionId: fields[4] as String,
    );
  }

  @override
  void write(BinaryWriter writer, CourseMaterial obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.url)
      ..writeByte(3)
      ..write(obj.sizeBytes)
      ..writeByte(4)
      ..write(obj.sectionId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CourseMaterialAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

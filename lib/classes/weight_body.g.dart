// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weight_body.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WeightBodyAdapter extends TypeAdapter<WeightBody> {
  @override
  final int typeId = 6;

  @override
  WeightBody read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WeightBody()
      ..date = fields[0] as DateTime
      ..weight = fields[1] as double;
  }

  @override
  void write(BinaryWriter writer, WeightBody obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.date)
      ..writeByte(1)
      ..write(obj.weight);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WeightBodyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

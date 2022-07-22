// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_kind.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkKindAdapter extends TypeAdapter<WorkKind> {
  @override
  final int typeId = 1;

  @override
  WorkKind read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    var res = WorkKind()..title = fields[0] as String;
    if (numOfFields > 1) {
      res.parentHash = fields[1] as int;
    }
    return res;
  }

  @override
  void write(BinaryWriter writer, WorkKind obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.title);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkKindAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

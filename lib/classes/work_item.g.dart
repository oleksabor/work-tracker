// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'work_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkItemAdapter extends TypeAdapter<WorkItem> {
  @override
  final int typeId = 0;

  @override
  WorkItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    var res = WorkItem()
      ..kind = fields[0] as String
      ..created = fields[1] as DateTime
      ..qty = fields[2] as int
      ..weight = fields[3] as double
      ..kindId = fields[4] == null ? -1 : fields[4] as int;
    return res;
  }

  @override
  void write(BinaryWriter writer, WorkItem obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.kind)
      ..writeByte(1)
      ..write(obj.created)
      ..writeByte(2)
      ..write(obj.qty)
      ..writeByte(3)
      ..write(obj.weight)
      ..writeByte(4)
      ..write(obj.kindId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

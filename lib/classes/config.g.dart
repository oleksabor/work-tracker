// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConfigAdapter extends TypeAdapter<Config> {
  @override
  final int typeId = 2;

  @override
  Config read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Config()
      ..graph = fields[0] as ConfigGraph
      ..log = fields[1] == null ? ConfigLog() : fields[1] as ConfigLog
      ..notify = fields[2] == null ? ConfigNotify() : fields[2] as ConfigNotify
      ..ui = fields[3] == null ? ConfigUI() : fields[3] as ConfigUI;
  }

  @override
  void write(BinaryWriter writer, Config obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.graph)
      ..writeByte(1)
      ..write(obj.log)
      ..writeByte(2)
      ..write(obj.notify)
      ..writeByte(3)
      ..write(obj.ui);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfigAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

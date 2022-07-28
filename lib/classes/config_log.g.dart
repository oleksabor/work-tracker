// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config_log.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConfigLogAdapter extends TypeAdapter<ConfigLog> {
  @override
  final int typeId = 4;

  @override
  ConfigLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConfigLog()
      ..logLevel = fields[0] as String
      ..includeCallerInfo = fields[1] as bool;
  }

  @override
  void write(BinaryWriter writer, ConfigLog obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.logLevel)
      ..writeByte(1)
      ..write(obj.includeCallerInfo);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfigLogAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

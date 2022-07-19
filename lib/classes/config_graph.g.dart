// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config_graph.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConfigGraphAdapter extends TypeAdapter<ConfigGraph> {
  @override
  final int typeId = 3;

  @override
  ConfigGraph read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConfigGraph()
      ..weight4graph = fields[0] as bool
      ..weight4graphCoefficient = fields[1] as double;
  }

  @override
  void write(BinaryWriter writer, ConfigGraph obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.weight4graph)
      ..writeByte(1)
      ..write(obj.weight4graphCoefficient);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfigGraphAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

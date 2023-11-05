// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config_ui.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConfigUIAdapter extends TypeAdapter<ConfigUI> {
  @override
  final int typeId = 7;

  @override
  ConfigUI read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ConfigUI()..qtyFontMulti = fields[0] as double;
  }

  @override
  void write(BinaryWriter writer, ConfigUI obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.qtyFontMulti);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfigUIAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

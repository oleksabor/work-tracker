// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'config_notify.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ConfigNotifyAdapter extends TypeAdapter<ConfigNotify> {
  @override
  final int typeId = 5;

  @override
  ConfigNotify read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    try {
      return ConfigNotify()
        ..volume = fields[0] as double
        ..frequency = fields[1] as double
        ..sampleRate = fields[2] as int
        ..period = fields[3] as int
        ..waveType = fields[4] as String;
    } catch (e) {
      if (kDebugMode) {
        print("failed to read configNotify ${e.toString()}");
      }
      return ConfigNotify();
    }
  }

  @override
  void write(BinaryWriter writer, ConfigNotify obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.volume)
      ..writeByte(1)
      ..write(obj.frequency)
      ..writeByte(2)
      ..write(obj.sampleRate)
      ..writeByte(3)
      ..write(obj.period)
      ..writeByte(4)
      ..write(obj.waveType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConfigNotifyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

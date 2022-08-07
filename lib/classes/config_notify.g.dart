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
        ..notification = fields[1] as String
        ..playAfterNewResult = fields[2] as bool
        ..delay = fields[3] as int
        ..kind = NotificationKind.values[fields[4] as int]
        ..asAlarm = fields[5];
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
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.volume)
      ..writeByte(1)
      ..write(obj.notification)
      ..writeByte(2)
      ..write(obj.playAfterNewResult)
      ..writeByte(3)
      ..write(obj.delay)
      ..writeByte(4)
      ..write(obj.kind.index)
      ..writeByte(5)
      ..write(obj.asAlarm);
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

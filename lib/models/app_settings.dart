import 'package:hive/hive.dart';

class AppSettings extends HiveObject {
  int checkIntervalSeconds;
  bool useDarkMode;
  String? activeGroupFilter;

  AppSettings({
    this.checkIntervalSeconds = 5,
    this.useDarkMode = true,
    this.activeGroupFilter,
  });
}

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 2;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return AppSettings(
      checkIntervalSeconds: (fields[0] as int?) ?? 5,
      useDarkMode: (fields[1] as bool?) ?? true,
      activeGroupFilter: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.checkIntervalSeconds)
      ..writeByte(1)
      ..write(obj.useDarkMode)
      ..writeByte(2)
      ..write(obj.activeGroupFilter);
  }
}

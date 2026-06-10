import 'package:hive/hive.dart';

class TrackEntry extends HiveObject {
  String id;
  String target;
  String? alias;
  String? group;
  int? lastStatusCode;
  bool? isAvailable;
  int? lastPingMs;
  DateTime? lastCheckedAt;
  DateTime createdAt;

  TrackEntry({
    required this.id,
    required this.target,
    this.alias,
    this.group,
    this.lastStatusCode,
    this.isAvailable,
    this.lastPingMs,
    this.lastCheckedAt,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}

class TrackEntryAdapter extends TypeAdapter<TrackEntry> {
  @override
  final int typeId = 1;

  @override
  TrackEntry read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return TrackEntry(
      id: fields[0] as String,
      target: fields[1] as String,
      alias: fields[2] as String?,
      group: fields[3] as String?,
      lastStatusCode: fields[4] as int?,
      isAvailable: fields[5] as bool?,
      lastPingMs: fields[6] as int?,
      lastCheckedAt: fields[7] as DateTime?,
      createdAt: fields[8] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, TrackEntry obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.target)
      ..writeByte(2)
      ..write(obj.alias)
      ..writeByte(3)
      ..write(obj.group)
      ..writeByte(4)
      ..write(obj.lastStatusCode)
      ..writeByte(5)
      ..write(obj.isAvailable)
      ..writeByte(6)
      ..write(obj.lastPingMs)
      ..writeByte(7)
      ..write(obj.lastCheckedAt)
      ..writeByte(8)
      ..write(obj.createdAt);
  }
}

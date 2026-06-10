import 'package:hive/hive.dart';

class CheckLog extends HiveObject {
  DateTime timestamp;
  String target;
  String method;
  int? statusCode;
  bool isAvailable;
  int pingMs;
  String? errorMessage;
  bool isFailure;

  CheckLog({
    required this.timestamp,
    required this.target,
    required this.method,
    this.statusCode,
    required this.isAvailable,
    required this.pingMs,
    this.errorMessage,
    required this.isFailure,
  });
}

class CheckLogAdapter extends TypeAdapter<CheckLog> {
  @override
  final int typeId = 3;

  @override
  CheckLog read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      fields[reader.readByte()] = reader.read();
    }
    return CheckLog(
      timestamp: fields[0] as DateTime,
      target: fields[1] as String,
      method: fields[2] as String,
      statusCode: fields[3] as int?,
      isAvailable: fields[4] as bool,
      pingMs: fields[5] as int,
      errorMessage: fields[6] as String?,
      isFailure: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, CheckLog obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.timestamp)
      ..writeByte(1)
      ..write(obj.target)
      ..writeByte(2)
      ..write(obj.method)
      ..writeByte(3)
      ..write(obj.statusCode)
      ..writeByte(4)
      ..write(obj.isAvailable)
      ..writeByte(5)
      ..write(obj.pingMs)
      ..writeByte(6)
      ..write(obj.errorMessage)
      ..writeByte(7)
      ..write(obj.isFailure);
  }
}

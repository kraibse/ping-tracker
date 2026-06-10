import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/check_log.dart';

class LogController extends ChangeNotifier {
  static const String boxName = 'check_logs';
  static const int maxLogs = 100;

  List<CheckLog> _logs = [];
  List<CheckLog> get logs => List.unmodifiable(_logs);

  List<CheckLog> get failures => _logs.where((l) => l.isFailure).toList();

  Future<void> init() async {
    final box = await Hive.openBox<CheckLog>(boxName);
    _logs = box.values.toList()..sort((a, b) => b.timestamp.compareTo(a.timestamp));
    notifyListeners();
  }

  Future<void> addLog({
    required String target,
    required String method,
    required int? statusCode,
    required bool isAvailable,
    required int pingMs,
    String? error,
  }) async {
    final box = Hive.box<CheckLog>(boxName);
    final log = CheckLog(
      timestamp: DateTime.now(),
      target: target,
      method: method,
      statusCode: statusCode,
      isAvailable: isAvailable,
      pingMs: pingMs,
      errorMessage: error,
      isFailure: !isAvailable || (error != null && error.isNotEmpty),
    );
    await box.add(log);
    _logs.insert(0, log);
    if (_logs.length > maxLogs) {
      final toRemove = _logs.sublist(maxLogs);
      _logs = _logs.sublist(0, maxLogs);
      for (final old in toRemove) {
        await old.delete();
      }
    }
    notifyListeners();
  }

  Future<void> clear() async {
    final box = Hive.box<CheckLog>(boxName);
    await box.clear();
    _logs.clear();
    notifyListeners();
  }
}

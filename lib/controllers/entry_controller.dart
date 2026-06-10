import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

import '../models/track_entry.dart';
import '../services/check_service.dart';
import 'settings_controller.dart';

class EntryController extends ChangeNotifier {
  static const String boxName = 'track_entries';

  final SettingsController settings;
  EntryController({required this.settings});

  Timer? _timer;

  List<TrackEntry> _entries = [];
  List<TrackEntry> get entries => _applyFilter(_entries);

  List<String> get groups {
    final set = <String>{};
    for (final e in _entries) {
      if ((e.group ?? '').isNotEmpty) set.add(e.group!);
    }
    return set.toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  }

  List<TrackEntry> _applyFilter(List<TrackEntry> input) {
    final g = settings.value.activeGroupFilter;
    if (g == null || g.isEmpty) return input;
    return input.where((e) => (e.group ?? '') == g).toList();
  }

  Future<void> init() async {
    final box = await Hive.openBox<TrackEntry>(boxName);
    _entries = box.values.toList();
    _startTimer();
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(
      Duration(seconds: settings.value.checkIntervalSeconds),
      (_) => runChecks(),
    );
  }

  void refreshTimer() {
    _startTimer();
  }

  Future<void> runChecks() async {
    for (final entry in _entries) {
      final res = await CheckService.check(entry.target);
      entry
        ..lastStatusCode = res.statusCode
        ..isAvailable = res.isAvailable
        ..lastPingMs = res.pingMs
        ..lastCheckedAt = DateTime.now();
      await entry.save();
    }
    notifyListeners();
  }

  Future<void> runCheckFor(TrackEntry entry) async {
    final res = await CheckService.check(entry.target);
    entry
      ..lastStatusCode = res.statusCode
      ..isAvailable = res.isAvailable
      ..lastPingMs = res.pingMs
      ..lastCheckedAt = DateTime.now();
    await entry.save();
    notifyListeners();
  }

  Future<TrackEntry> addEntry({
    required String target,
    String? alias,
    String? group,
  }) async {
    final box = Hive.box<TrackEntry>(boxName);
    final id = const Uuid().v4();
    final entry = TrackEntry(
      id: id,
      target: target,
      alias: alias,
      group: group,
    );
    await box.put(id, entry);
    _entries.add(entry);
    notifyListeners();
    return entry;
  }

  Future<void> updateEntry(
    TrackEntry entry, {
    String? target,
    String? alias,
    String? group,
  }) async {
    if (target != null) entry.target = target;
    if (alias != null) entry.alias = alias;
    if (group != null) entry.group = group;
    await entry.save();
    notifyListeners();
  }

  Future<void> deleteEntry(TrackEntry entry) async {
    final box = Hive.box<TrackEntry>(boxName);
    await box.delete(entry.id);
    _entries.removeWhere((e) => e.id == entry.id);
    notifyListeners();
  }

  Future<CheckResult> quickCheck(String target) => CheckService.check(target);

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

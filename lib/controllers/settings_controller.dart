import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/app_settings.dart';

class SettingsController extends ChangeNotifier {
  static const String boxName = 'app_settings';

  AppSettings _settings = AppSettings();
  AppSettings get value => _settings;

  Future<void> init() async {
    final box = await Hive.openBox<AppSettings>(boxName);
    if (box.isEmpty) {
      await box.put('settings', AppSettings());
    }
    _settings = box.get('settings') ?? AppSettings();
    notifyListeners();
  }

  Future<void> update({
    int? intervalSeconds,
    bool? useDarkMode,
    String? activeGroup,
    List<String>? groups,
  }) async {
    final box = Hive.box<AppSettings>(boxName);
    if (intervalSeconds != null) {
      _settings.checkIntervalSeconds = intervalSeconds;
    }
    if (useDarkMode != null) {
      _settings.useDarkMode = useDarkMode;
    }
    if (activeGroup != null) {
      _settings.activeGroupFilter = activeGroup.isEmpty ? null : activeGroup;
    }
    if (groups != null) {
      _settings.groups = groups;
    }
    await box.put('settings', _settings);
    notifyListeners();
  }

  Future<void> addGroup(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    if (_settings.groups.contains(trimmed)) return;
    _settings.groups.add(trimmed);
    _settings.groups.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    final box = Hive.box<AppSettings>(boxName);
    await box.put('settings', _settings);
    notifyListeners();
  }

  Future<void> renameGroup(String oldName, String newName) async {
    final trimmed = newName.trim();
    if (trimmed.isEmpty || trimmed == oldName) return;
    final index = _settings.groups.indexOf(oldName);
    if (index == -1) return;
    _settings.groups[index] = trimmed;
    _settings.groups.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    final box = Hive.box<AppSettings>(boxName);
    await box.put('settings', _settings);
    notifyListeners();
  }

  Future<void> deleteGroup(String name) async {
    _settings.groups.remove(name);
    final box = Hive.box<AppSettings>(boxName);
    await box.put('settings', _settings);
    notifyListeners();
  }
}

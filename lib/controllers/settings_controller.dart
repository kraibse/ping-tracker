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
    await box.put('settings', _settings);
    notifyListeners();
  }
}

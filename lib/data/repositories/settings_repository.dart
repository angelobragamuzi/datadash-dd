import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class SettingsRepository {
  SettingsRepository(this._box);

  final Box<dynamic> _box;

  static const String _themeModeKey = 'theme_mode';

  ThemeMode getThemeMode() {
    final value = _box.get(_themeModeKey);
    if (value == ThemeMode.dark.name) return ThemeMode.dark;
    if (value == ThemeMode.system.name) return ThemeMode.system;
    return ThemeMode.light;
  }

  Future<void> saveThemeMode(ThemeMode mode) {
    return _box.put(_themeModeKey, mode.name);
  }
}

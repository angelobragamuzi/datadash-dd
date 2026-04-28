import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class SettingsRepository {
  SettingsRepository(this._box);

  final Box<dynamic> _box;

  static const String _themeModeKey = 'theme_mode';
  static const String _tutorialsSeenKey = 'tutorials_seen';
  static const String _legacyHomeTutorialSeenKey = 'home_tutorial_seen';

  ThemeMode getThemeMode() {
    final value = _box.get(_themeModeKey);
    if (value == ThemeMode.dark.name) return ThemeMode.dark;
    if (value == ThemeMode.system.name) return ThemeMode.system;
    return ThemeMode.light;
  }

  Future<void> saveThemeMode(ThemeMode mode) {
    return _box.put(_themeModeKey, mode.name);
  }

  Set<String> getSeenTutorials() {
    final raw = _box.get(_tutorialsSeenKey);
    final tutorials = <String>{};

    if (raw is List) {
      for (final item in raw) {
        if (item is String && item.trim().isNotEmpty) {
          tutorials.add(item.trim());
        }
      }
    }

    // Migração de versão antiga, onde só havia o tutorial da Home.
    final legacyHomeSeen = _box.get(_legacyHomeTutorialSeenKey);
    if (legacyHomeSeen == true) {
      tutorials.add('home');
    }

    return tutorials;
  }

  Future<void> saveSeenTutorials(Set<String> tutorials) {
    return _box.put(_tutorialsSeenKey, tutorials.toList());
  }
}

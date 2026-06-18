import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../constants/app_constants.dart';

/// Holds user preferences (theme mode, display name) persisted in the Hive
/// settings box, and notifies the app when they change.
class SettingsController extends ChangeNotifier {
  SettingsController() {
    _load();
  }

  static const _keyDisplayName = 'display_name';
  static const _keyApiKey = 'claude_api_key';

  Box<String> get _box => Hive.box<String>(AppConstants.settingsBox);

  ThemeMode _themeMode = ThemeMode.dark;
  ThemeMode get themeMode => _themeMode;

  String _displayName = 'Friend';
  String get displayName => _displayName;

  /// User-supplied Claude API key for AI habit suggestions. When empty, the
  /// app falls back to a curated offline list.
  String _claudeApiKey = '';
  String get claudeApiKey => _claudeApiKey;
  bool get hasAiKey => _claudeApiKey.isNotEmpty;

  void _load() {
    final stored = _box.get(AppConstants.keyThemeMode);
    _themeMode = switch (stored) {
      'light' => ThemeMode.light,
      'system' => ThemeMode.system,
      _ => ThemeMode.dark,
    };
    _displayName = _box.get(_keyDisplayName) ?? 'Friend';
    _claudeApiKey = _box.get(_keyApiKey) ?? '';
  }

  /// Stores (or clears, when [key] is blank) the Claude API key.
  Future<void> setClaudeApiKey(String key) async {
    _claudeApiKey = key.trim();
    if (_claudeApiKey.isEmpty) {
      await _box.delete(_keyApiKey);
    } else {
      await _box.put(_keyApiKey, _claudeApiKey);
    }
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _box.put(AppConstants.keyThemeMode, mode.name);
    notifyListeners();
  }

  Future<void> setDisplayName(String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    _displayName = trimmed;
    await _box.put(_keyDisplayName, trimmed);
    notifyListeners();
  }
}

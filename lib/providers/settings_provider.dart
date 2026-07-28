import 'package:flutter/foundation.dart';
import 'package:campusbite/models/settings.dart';
import 'package:campusbite/services/hive_service.dart';

/// Provider for app settings management
class SettingsProvider with ChangeNotifier {
  final HiveService _hiveService = HiveService();

  Settings? _settings;

  Settings? get settings => _settings;

  /// Get currency
  String get currency => _settings?.currency ?? 'Birr';

  /// Get dark mode
  bool get darkMode => _settings?.darkMode ?? false;

  /// Get low balance threshold
  double get lowBalanceThreshold => _settings?.lowBalanceThreshold ?? 500.0;

  /// Get notifications enabled
  bool get notificationsEnabled => _settings?.notificationsEnabled ?? true;

  /// Get language
  String get language => _settings?.language ?? 'en';

  /// Initialize provider
  Future<void> initialize() async {
    await loadSettings();
  }

  /// Load settings
  Future<void> loadSettings() async {
    _settings = _hiveService.getSettings();
    if (_settings == null) {
      _settings = Settings.defaultSettings();
      await _hiveService.saveSettings(_settings!);
    }
    notifyListeners();
  }

  /// Update currency
  Future<void> updateCurrency(String currency) async {
    _settings = _settings?.copyWith(currency: currency) ?? Settings(currency: currency);
    await _hiveService.updateSettings(_settings!);
    notifyListeners();
  }

  /// Toggle dark mode
  Future<void> toggleDarkMode() async {
    _settings = _settings?.copyWith(darkMode: !_settings!.darkMode) ?? Settings(darkMode: true);
    await _hiveService.updateSettings(_settings!);
    notifyListeners();
  }

  /// Set dark mode
  Future<void> setDarkMode(bool value) async {
    _settings = _settings?.copyWith(darkMode: value) ?? Settings(darkMode: value);
    await _hiveService.updateSettings(_settings!);
    notifyListeners();
  }

  /// Update low balance threshold
  Future<void> updateLowBalanceThreshold(double threshold) async {
    _settings = _settings?.copyWith(lowBalanceThreshold: threshold) ?? Settings(lowBalanceThreshold: threshold);
    await _hiveService.updateSettings(_settings!);
    notifyListeners();
  }

  /// Toggle notifications
  Future<void> toggleNotifications() async {
    _settings = _settings?.copyWith(notificationsEnabled: !_settings!.notificationsEnabled) ?? Settings(notificationsEnabled: true);
    await _hiveService.updateSettings(_settings!);
    notifyListeners();
  }

  /// Set notifications
  Future<void> setNotifications(bool value) async {
    _settings = _settings?.copyWith(notificationsEnabled: value) ?? Settings(notificationsEnabled: value);
    await _hiveService.updateSettings(_settings!);
    notifyListeners();
  }

  /// Update language
  Future<void> updateLanguage(String language) async {
    _settings = _settings?.copyWith(language: language) ?? Settings(language: language);
    await _hiveService.updateSettings(_settings!);
    notifyListeners();
  }

  /// Reset settings to default
  Future<void> resetSettings() async {
    _settings = Settings.defaultSettings();
    await _hiveService.updateSettings(_settings!);
    notifyListeners();
  }
}

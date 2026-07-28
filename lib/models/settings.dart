import 'package:hive/hive.dart';

part 'settings.g.dart';

/// App settings model
@HiveType(typeId: 2)
class Settings extends HiveObject {
  @HiveField(0)
  final String currency;

  @HiveField(1)
  final bool darkMode;

  @HiveField(2)
  final double lowBalanceThreshold;

  @HiveField(3)
  final bool notificationsEnabled;

  @HiveField(4)
  final String language;

  Settings({
    this.currency = 'Birr',
    this.darkMode = false,
    this.lowBalanceThreshold = 500.0,
    this.notificationsEnabled = true,
    this.language = 'en',
  });

  /// Create default settings
  factory Settings.defaultSettings() {
    return Settings();
  }

  /// Create a copy of this settings with updated fields
  Settings copyWith({
    String? currency,
    bool? darkMode,
    double? lowBalanceThreshold,
    bool? notificationsEnabled,
    String? language,
  }) {
    return Settings(
      currency: currency ?? this.currency,
      darkMode: darkMode ?? this.darkMode,
      lowBalanceThreshold: lowBalanceThreshold ?? this.lowBalanceThreshold,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      language: language ?? this.language,
    );
  }

  /// Convert settings to JSON for export
  Map<String, dynamic> toJson() {
    return {
      'currency': currency,
      'darkMode': darkMode,
      'lowBalanceThreshold': lowBalanceThreshold,
      'notificationsEnabled': notificationsEnabled,
      'language': language,
    };
  }
}

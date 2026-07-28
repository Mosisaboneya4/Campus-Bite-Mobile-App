import 'package:hive_flutter/hive_flutter.dart';
import 'package:campusbite/models/meal.dart';
import 'package:campusbite/models/contract.dart';
import 'package:campusbite/models/settings.dart';
import 'package:campusbite/constants/app_constants.dart';
// Removed path_provider to avoid jni transitive dependency in CI.

/// Hive database service for local storage
class HiveService {
  static final HiveService _instance = HiveService._internal();
  factory HiveService() => _instance;
  HiveService._internal();

  bool _isInitialized = false;

  /// Initialize Hive database
  Future<void> initialize() async {
    if (_isInitialized) return;

    // Initialize Hive
    await Hive.initFlutter();

    // Register adapters
    Hive.registerAdapter(MealAdapter());
    Hive.registerAdapter(ContractAdapter());
    Hive.registerAdapter(SettingsAdapter());

    // Open boxes
    await Hive.openBox<Meal>(AppConstants.mealsBox);
    await Hive.openBox<Contract>(AppConstants.contractBox);
    await Hive.openBox<Settings>(AppConstants.settingsBox);

    _isInitialized = true;
  }

  /// Check if Hive is initialized
  bool get isInitialized => _isInitialized;

  // ==================== MEAL OPERATIONS ====================

  /// Get all meals
  List<Meal> getAllMeals() {
    final box = Hive.box<Meal>(AppConstants.mealsBox);
    return box.values.toList();
  }

  /// Add a meal
  Future<void> addMeal(Meal meal) async {
    final box = Hive.box<Meal>(AppConstants.mealsBox);
    await box.put(meal.id, meal);
  }

  /// Update a meal
  Future<void> updateMeal(Meal meal) async {
    final box = Hive.box<Meal>(AppConstants.mealsBox);
    await box.put(meal.id, meal);
  }

  /// Delete a meal
  Future<void> deleteMeal(String mealId) async {
    final box = Hive.box<Meal>(AppConstants.mealsBox);
    await box.delete(mealId);
  }

  /// Get meals for a specific date range
  List<Meal> getMealsByDateRange(DateTime start, DateTime end) {
    final meals = getAllMeals();
    return meals.where((meal) {
      final mealDate = DateTime(meal.date.year, meal.date.month, meal.date.day);
      final startDate = DateTime(start.year, start.month, start.day);
      final endDate = DateTime(end.year, end.month, end.day);
      return !mealDate.isBefore(startDate) && !mealDate.isAfter(endDate);
    }).toList();
  }

  /// Get meals for a specific date
  List<Meal> getMealsByDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1)).subtract(const Duration(seconds: 1));
    return getMealsByDateRange(start, end);
  }

  /// Get meals for current month
  List<Meal> getMealsForCurrentMonth() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    final end = DateTime(now.year, now.month + 1, 1).subtract(const Duration(seconds: 1));
    return getMealsByDateRange(start, end);
  }

  /// Clear all meals
  Future<void> clearAllMeals() async {
    final box = Hive.box<Meal>(AppConstants.mealsBox);
    await box.clear();
  }

  // ==================== CONTRACT OPERATIONS ====================

  /// Get current contract
  Contract? getCurrentContract() {
    final box = Hive.box<Contract>(AppConstants.contractBox);
    return box.get(AppConstants.currentContractKey);
  }

  /// Save contract
  Future<void> saveContract(Contract contract) async {
    final box = Hive.box<Contract>(AppConstants.contractBox);
    await box.put(AppConstants.currentContractKey, contract);
  }

  /// Update contract
  Future<void> updateContract(Contract contract) async {
    final box = Hive.box<Contract>(AppConstants.contractBox);
    await box.put(AppConstants.currentContractKey, contract);
  }

  /// Delete contract
  Future<void> deleteContract() async {
    final box = Hive.box<Contract>(AppConstants.contractBox);
    await box.delete(AppConstants.currentContractKey);
  }

  // ==================== SETTINGS OPERATIONS ====================

  /// Get settings
  Settings? getSettings() {
    final box = Hive.box<Settings>(AppConstants.settingsBox);
    return box.get(AppConstants.settingsKey);
  }

  /// Save settings
  Future<void> saveSettings(Settings settings) async {
    final box = Hive.box<Settings>(AppConstants.settingsBox);
    await box.put(AppConstants.settingsKey, settings);
  }

  /// Update settings
  Future<void> updateSettings(Settings settings) async {
    final box = Hive.box<Settings>(AppConstants.settingsBox);
    await box.put(AppConstants.settingsKey, settings);
  }

  // ==================== BACKUP & RESTORE ====================

  /// Export all data as JSON
  Future<Map<String, dynamic>> exportData() async {
    return {
      'contract': getCurrentContract()?.toJson(),
      'settings': getSettings()?.toJson(),
      'meals': getAllMeals().map((meal) => meal.toJson()).toList(),
      'exportDate': DateTime.now().toIso8601String(),
    };
  }

  /// Import data from JSON
  Future<void> importData(Map<String, dynamic> data) async {
    // Clear existing data
    await clearAllMeals();
    await deleteContract();

    // Import contract
    if (data['contract'] != null) {
      final contractData = data['contract'] as Map<String, dynamic>;
      final contract = Contract(
        id: contractData['id'],
        studentName: contractData['studentName'],
        initialDeposit: contractData['initialDeposit'].toDouble(),
        lunchPrice: contractData['lunchPrice'].toDouble(),
        dinnerPrice: contractData['dinnerPrice'].toDouble(),
        startDate: DateTime.parse(contractData['startDate']),
        endDate: DateTime.parse(contractData['endDate']),
        createdAt: DateTime.parse(contractData['createdAt']),
      );
      await saveContract(contract);
    }

    // Import settings
    if (data['settings'] != null) {
      final settingsData = data['settings'] as Map<String, dynamic>;
      final settings = Settings(
        currency: settingsData['currency'],
        darkMode: settingsData['darkMode'],
        lowBalanceThreshold: settingsData['lowBalanceThreshold'].toDouble(),
        notificationsEnabled: settingsData['notificationsEnabled'],
        language: settingsData['language'],
      );
      await saveSettings(settings);
    }

    // Import meals
    if (data['meals'] != null) {
      final mealsData = data['meals'] as List;
      for (var mealData in mealsData) {
        final mealTypeString = mealData['mealType'] as String;
        MealType mealType;
        switch (mealTypeString) {
          case 'Lunch':
            mealType = MealType.lunch;
            break;
          case 'Dinner':
            mealType = MealType.dinner;
            break;
          default:
            mealType = MealType.custom;
        }

        final meal = Meal(
          id: mealData['id'],
          mealType: mealType,
          amount: mealData['amount'].toDouble(),
          date: DateTime.parse(mealData['date']),
          reason: mealData['reason'],
          note: mealData['note'],
        );
        await addMeal(meal);
      }
    }
  }

  /// Close all boxes
  Future<void> close() async {
    await Hive.close();
    _isInitialized = false;
  }
}

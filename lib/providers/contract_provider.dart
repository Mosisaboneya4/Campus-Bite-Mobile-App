import 'package:flutter/foundation.dart';
import 'package:campusbite/models/contract.dart';
import 'package:campusbite/models/meal.dart';
import 'package:campusbite/services/hive_service.dart';
import 'package:uuid/uuid.dart';

/// Provider for contract and balance management
class ContractProvider with ChangeNotifier {
  final HiveService _hiveService = HiveService();
  final Uuid _uuid = const Uuid();

  Contract? _currentContract;
  List<Meal> _meals = [];

  Contract? get currentContract => _currentContract;
  List<Meal> get meals => _meals;

  /// Get remaining balance
  double get remainingBalance {
    if (_currentContract == null) return 0.0;
    final totalSpent = _meals.fold<double>(0.0, (sum, meal) => sum + meal.amount);
    return _currentContract!.initialDeposit - totalSpent;
  }

  /// Get total spent
  double get totalSpent {
    return _meals.fold<double>(0.0, (sum, meal) => sum + meal.amount);
  }

  /// Get total meals count
  int get totalMeals => _meals.length;

  /// Get lunch count
  int get lunchCount {
    return _meals.where((meal) => meal.mealType == MealType.lunch).length;
  }

  /// Get dinner count
  int get dinnerCount {
    return _meals.where((meal) => meal.mealType == MealType.dinner).length;
  }

  /// Get custom meals count
  int get customMealCount {
    return _meals.where((meal) => meal.mealType == MealType.custom).length;
  }

  /// Get today's spending
  double get todaySpending {
    final today = DateTime.now();
    final todayMeals = _meals.where((meal) {
      return meal.date.year == today.year &&
          meal.date.month == today.month &&
          meal.date.day == today.day;
    });
    return todayMeals.fold<double>(0.0, (sum, meal) => sum + meal.amount);
  }

  /// Get average daily spending
  double get averageDailySpending {
    if (_currentContract == null || totalMeals == 0) return 0.0;
    final daysElapsed = _currentContract!.daysElapsed;
    if (daysElapsed == 0) return 0.0;
    return totalSpent / daysElapsed;
  }

  /// Get highest spending day
  MapEntry<DateTime, double>? get highestSpendingDay {
    if (_meals.isEmpty) return null;

    final spendingByDay = <DateTime, double>{};
    for (final meal in _meals) {
      final day = DateTime(meal.date.year, meal.date.month, meal.date.day);
      spendingByDay[day] = (spendingByDay[day] ?? 0.0) + meal.amount;
    }

    if (spendingByDay.isEmpty) return null;

    return spendingByDay.entries.reduce((a, b) => a.value > b.value ? a : b);
  }

  /// Check if balance is low
  bool get isLowBalance {
    if (_currentContract == null) return false;
    return remainingBalance <= _currentContract!.initialDeposit * 0.1;
  }

  /// Check if balance is zero
  bool get isBalanceZero {
    return remainingBalance <= 0;
  }

  /// Initialize provider
  Future<void> initialize() async {
    await loadContract();
    await loadMeals();
  }

  /// Load current contract
  Future<void> loadContract() async {
    _currentContract = _hiveService.getCurrentContract();
    notifyListeners();
  }

  /// Load meals
  Future<void> loadMeals() async {
    _meals = _hiveService.getAllMeals();
    // Sort by date descending
    _meals.sort((a, b) => b.date.compareTo(a.date));
    notifyListeners();
  }

  /// Create new contract
  Future<void> createContract({
    required String studentName,
    required double initialDeposit,
    required double lunchPrice,
    required double dinnerPrice,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final contract = Contract(
      id: _uuid.v4(),
      studentName: studentName,
      initialDeposit: initialDeposit,
      lunchPrice: lunchPrice,
      dinnerPrice: dinnerPrice,
      startDate: startDate,
      endDate: endDate,
      createdAt: DateTime.now(),
    );

    await _hiveService.saveContract(contract);
    _currentContract = contract;
    notifyListeners();
  }

  /// Update contract
  Future<void> updateContract(Contract contract) async {
    await _hiveService.updateContract(contract);
    _currentContract = contract;
    notifyListeners();
  }

  /// Delete contract
  Future<void> deleteContract() async {
    await _hiveService.deleteContract();
    await _hiveService.clearAllMeals();
    _currentContract = null;
    _meals = [];
    notifyListeners();
  }

  /// Add meal
  Future<void> addMeal(Meal meal) async {
    await _hiveService.addMeal(meal);
    _meals.insert(0, meal);
    notifyListeners();
  }

  /// Update meal
  Future<void> updateMeal(Meal meal) async {
    await _hiveService.updateMeal(meal);
    final index = _meals.indexWhere((m) => m.id == meal.id);
    if (index != -1) {
      _meals[index] = meal;
      _meals.sort((a, b) => b.date.compareTo(a.date));
      notifyListeners();
    }
  }

  /// Delete meal
  Future<void> deleteMeal(String mealId) async {
    await _hiveService.deleteMeal(mealId);
    _meals.removeWhere((meal) => meal.id == mealId);
    notifyListeners();
  }

  /// Get meals for a specific date
  List<Meal> getMealsForDate(DateTime date) {
    return _hiveService.getMealsByDate(date);
  }

  /// Get meals for date range
  List<Meal> getMealsForDateRange(DateTime start, DateTime end) {
    return _hiveService.getMealsByDateRange(start, end);
  }

  /// Check if can add meal (balance check)
  bool canAddMeal(double amount) {
    if (_currentContract == null) return false;
    return remainingBalance >= amount;
  }
}

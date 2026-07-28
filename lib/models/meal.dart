import 'package:hive/hive.dart';

part 'meal.g.dart';

/// Meal type enumeration
enum MealType {
  lunch,
  dinner,
  custom,
}

/// Meal model representing a single meal entry
@HiveType(typeId: 0)
class Meal extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final MealType mealType;

  @HiveField(2)
  final double amount;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final String? reason;

  @HiveField(5)
  final String? note;

  Meal({
    required this.id,
    required this.mealType,
    required this.amount,
    required this.date,
    this.reason,
    this.note,
  });

  /// Get meal type as string for display
  String get mealTypeString {
    switch (mealType) {
      case MealType.lunch:
        return 'Lunch';
      case MealType.dinner:
        return 'Dinner';
      case MealType.custom:
        return 'Custom';
    }
  }

  /// Create a copy of this meal with updated fields
  Meal copyWith({
    String? id,
    MealType? mealType,
    double? amount,
    DateTime? date,
    String? reason,
    String? note,
  }) {
    return Meal(
      id: id ?? this.id,
      mealType: mealType ?? this.mealType,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      reason: reason ?? this.reason,
      note: note ?? this.note,
    );
  }

  /// Convert meal to JSON for export
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mealType': mealTypeString,
      'amount': amount,
      'date': date.toIso8601String(),
      'reason': reason,
      'note': note,
    };
  }
}

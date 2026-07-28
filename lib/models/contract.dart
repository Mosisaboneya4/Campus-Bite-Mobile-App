import 'package:hive/hive.dart';

part 'contract.g.dart';

/// Contract model representing a monthly meal contract
@HiveType(typeId: 1)
class Contract extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String studentName;

  @HiveField(2)
  final double initialDeposit;

  @HiveField(3)
  final double lunchPrice;

  @HiveField(4)
  final double dinnerPrice;

  @HiveField(5)
  final DateTime startDate;

  @HiveField(6)
  final DateTime endDate;

  @HiveField(7)
  final DateTime createdAt;

  Contract({
    required this.id,
    required this.studentName,
    required this.initialDeposit,
    required this.lunchPrice,
    required this.dinnerPrice,
    required this.startDate,
    required this.endDate,
    required this.createdAt,
  });

  /// Get contract duration in days
  int get durationDays {
    return endDate.difference(startDate).inDays + 1;
  }

  /// Get days elapsed since contract start
  int get daysElapsed {
    final now = DateTime.now();
    if (now.isBefore(startDate)) return 0;
    if (now.isAfter(endDate)) return durationDays;
    return now.difference(startDate).inDays + 1;
  }

  /// Get days remaining in contract
  int get daysRemaining {
    final now = DateTime.now();
    if (now.isBefore(startDate)) return durationDays;
    if (now.isAfter(endDate)) return 0;
    return endDate.difference(now).inDays + 1;
  }

  /// Check if contract is active
  bool get isActive {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    return !today.isBefore(start) && !today.isAfter(end);
  }

  /// Check if contract has ended
  bool get isExpired {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    return today.isAfter(end);
  }

  /// Get contract month as formatted string
  String get contractMonth {
    return '${startDate.month}/${startDate.year}';
  }

  /// Create a copy of this contract with updated fields
  Contract copyWith({
    String? id,
    String? studentName,
    double? initialDeposit,
    double? lunchPrice,
    double? dinnerPrice,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
  }) {
    return Contract(
      id: id ?? this.id,
      studentName: studentName ?? this.studentName,
      initialDeposit: initialDeposit ?? this.initialDeposit,
      lunchPrice: lunchPrice ?? this.lunchPrice,
      dinnerPrice: dinnerPrice ?? this.dinnerPrice,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Convert contract to JSON for export
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentName': studentName,
      'initialDeposit': initialDeposit,
      'lunchPrice': lunchPrice,
      'dinnerPrice': dinnerPrice,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

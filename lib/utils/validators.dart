import 'package:campusbite/constants/app_constants.dart';

/// Validation utilities
class Validators {
  /// Validate student name
  static String? validateStudentName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Student name is required';
    }
    if (value.trim().length > AppConstants.maxStudentNameLength) {
      return 'Name must be less than ${AppConstants.maxStudentNameLength} characters';
    }
    return null;
  }

  /// Validate deposit amount
  static String? validateDeposit(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Deposit amount is required';
    }
    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Please enter a valid number';
    }
    if (amount < AppConstants.minDeposit) {
      return 'Minimum deposit is ${AppConstants.minDeposit}';
    }
    if (amount > AppConstants.maxDeposit) {
      return 'Maximum deposit is ${AppConstants.maxDeposit}';
    }
    return null;
  }

  /// Validate meal price
  static String? validateMealPrice(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Price is required';
    }
    final price = double.tryParse(value);
    if (price == null) {
      return 'Please enter a valid number';
    }
    if (price < AppConstants.minMealPrice) {
      return 'Minimum price is ${AppConstants.minMealPrice}';
    }
    if (price > AppConstants.maxMealPrice) {
      return 'Maximum price is ${AppConstants.maxMealPrice}';
    }
    return null;
  }

  /// Validate custom meal amount
  static String? validateMealAmount(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Amount is required';
    }
    final amount = double.tryParse(value);
    if (amount == null) {
      return 'Please enter a valid number';
    }
    if (amount <= 0) {
      return 'Amount must be greater than 0';
    }
    if (amount > AppConstants.maxMealPrice) {
      return 'Maximum amount is ${AppConstants.maxMealPrice}';
    }
    return null;
  }

  /// Validate date range
  static String? validateDateRange(DateTime? start, DateTime? end) {
    if (start == null || end == null) {
      return 'Both dates are required';
    }
    if (end.isBefore(start)) {
      return 'End date must be after start date';
    }
    return null;
  }

  /// Validate low balance threshold
  static String? validateThreshold(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Threshold is required';
    }
    final threshold = double.tryParse(value);
    if (threshold == null) {
      return 'Please enter a valid number';
    }
    if (threshold < 0) {
      return 'Threshold must be positive';
    }
    return null;
  }
}

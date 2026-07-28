import 'package:intl/intl.dart';

/// Formatting utilities
class Formatters {
  /// Format currency
  static String formatCurrency(double amount, {String currency = 'Birr'}) {
    final formatter = NumberFormat.currency(
      symbol: currency,
      decimalDigits: 0,
    );
    return formatter.format(amount);
  }

  /// Format date
  static String formatDate(DateTime date) {
    return DateFormat('MMM d, yyyy').format(date);
  }

  /// Format short date
  static String formatShortDate(DateTime date) {
    return DateFormat('MMM d').format(date);
  }

  /// Format time
  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  /// Format date and time
  static String formatDateTime(DateTime date) {
    return DateFormat('MMM d, yyyy HH:mm').format(date);
  }

  /// Format month and year
  static String formatMonthYear(DateTime date) {
    return DateFormat('MMMM yyyy').format(date);
  }

  /// Format day of week
  static String formatDayOfWeek(DateTime date) {
    return DateFormat('EEEE').format(date);
  }

  /// Format number with commas
  static String formatNumber(double number) {
    return NumberFormat.decimalPattern().format(number);
  }

  /// Format full date
  static String formatFullDate(DateTime date) {
    return DateFormat('EEEE, MMMM d, yyyy').format(date);
  }
}

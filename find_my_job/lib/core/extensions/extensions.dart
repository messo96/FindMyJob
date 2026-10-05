import 'package:flutter/material.dart';

extension DateTimeX on DateTime {
  /// Returns a human-readable relative time string (Italian locale).
  String toRelativeString() {
    final now = DateTime.now();
    final diff = now.difference(this);

    if (diff.inDays > 30) {
      final months = (diff.inDays / 30).round();
      return '$months ${months == 1 ? 'mese' : 'mesi'} fa';
    }
    if (diff.inDays >= 1) {
      return '${diff.inDays} ${diff.inDays == 1 ? 'giorno' : 'giorni'} fa';
    }
    if (diff.inHours >= 1) {
      return '${diff.inHours} ${diff.inHours == 1 ? 'ora' : 'ore'} fa';
    }
    if (diff.inMinutes >= 1) {
      return '${diff.inMinutes} min fa';
    }
    return 'Adesso';
  }

  /// Short date format: "5 ott 2026"
  String toShortDate() {
    const months = [
      'gen', 'feb', 'mar', 'apr', 'mag', 'giu',
      'lug', 'ago', 'set', 'ott', 'nov', 'dic',
    ];
    return '$day ${months[month - 1]} $year';
  }

  bool get isExpired => isBefore(DateTime.now());

  bool get isToday {
    final now = DateTime.now();
    return year == now.year && month == now.month && day == now.day;
  }
}

extension StringX on String {
  /// Capitalises only the first character.
  String get capitalised =>
      isEmpty ? this : '${this[0].toUpperCase()}${substring(1)}';

  bool get isValidEmail =>
      RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$').hasMatch(this);

  bool get isValidUrl =>
      RegExp(r'^https?://.+\..+').hasMatch(this);
}

extension ContextX on BuildContext {
  ThemeData get theme => Theme.of(this);
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  TextTheme get textTheme => Theme.of(this).textTheme;
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  double get screenWidth => MediaQuery.of(this).size.width;
  double get screenHeight => MediaQuery.of(this).size.height;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;

  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError
            ? colorScheme.error
            : colorScheme.primaryContainer,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }
}

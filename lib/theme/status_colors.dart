import 'package:flutter/material.dart';

/// Semantic color extensions for status indicators.
///
/// Use these instead of hardcoded [Colors.green]/[Colors.red] so that
/// the palette adapts to both light and dark themes.
extension StatusColors on ColorScheme {
  Color get success => brightness == Brightness.dark
      ? const Color(0xFF4CAF50)
      : const Color(0xFF2E7D32);

  Color get statusError => brightness == Brightness.dark
      ? Colors.red
      : const Color(0xFFC62828);

  Color get warning => brightness == Brightness.dark
      ? const Color(0xFFFFA726)
      : const Color(0xFFEF6C00);

  Color get loading => brightness == Brightness.dark
      ? const Color(0xFF9E9E9E)
      : const Color(0xFF757575);
}

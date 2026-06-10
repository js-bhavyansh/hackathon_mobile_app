import 'package:flutter/material.dart';

class AppUtils {
  // Get theme colors easily
  static ColorScheme getColorScheme(BuildContext context) {
    return Theme.of(context).colorScheme;
  }

  // Get text theme
  static TextTheme getTextTheme(BuildContext context) {
    return Theme.of(context).textTheme;
  }
}
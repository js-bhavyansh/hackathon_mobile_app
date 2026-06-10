import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    surface: Colors.grey.shade300,
    onSurface: Colors.grey.shade900,
    primary: Colors.grey.shade400,
    secondary: Colors.grey.shade700,
    primaryFixed: Colors.white,
    primaryFixedDim: Colors.grey.shade200,
    tertiary: Colors.brown.shade700,
    tertiaryContainer: Colors.brown.shade300,
  ),
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    surface: Colors.grey.shade900,
    onSurface: Colors.grey.shade100,
    primary: Colors.grey.shade700,
    secondary: Colors.grey.shade300,
    primaryFixed: Colors.grey.shade300,
    primaryFixedDim: Colors.grey.shade800,
    tertiary: Colors.brown.shade500,
    tertiaryContainer: Colors.brown.shade300,
  ),
);

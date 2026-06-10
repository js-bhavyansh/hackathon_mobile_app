import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    surface: Color(0xFFEDEBDD),
    onSurface: Color(0xFF181717),
    primary: Colors.grey.shade400,
    secondary: Colors.grey.shade700,
    primaryFixed: Colors.white,
    primaryFixedDim: Colors.grey.shade200,
    tertiary: Color(0xFF630000),
    tertiaryContainer: Colors.brown.shade300,
  ),
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    surface: Color(0xFF000000),
    onSurface: Color(0xFFFFFFFF),
    primary: Colors.grey.shade700,
    secondary: Colors.grey.shade300,
    primaryFixed: Color(0xFF1C1C1C),
    primaryFixedDim: Colors.grey.shade800,
    tertiary: Colors.brown.shade500,
    tertiaryContainer: Colors.brown.shade300,
  ),
);

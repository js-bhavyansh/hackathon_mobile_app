import 'package:booking_slot_app/utils/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class ThemeProvider with ChangeNotifier {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  ThemeData _themeData;

  ThemeData get themeData => _themeData;
  bool get isDarkMode => _themeData.brightness == Brightness.dark;

  ThemeProvider(this._themeData);

  void toggleTheme() {
    _themeData = (_themeData == lightMode) ? darkMode : lightMode;
    _saveTheme();
    notifyListeners();
  }

  Future<void> _saveTheme() async {
    await _storage.write(
      key: "isDarkMode",
      value: isDarkMode.toString(),
    );
  }
}
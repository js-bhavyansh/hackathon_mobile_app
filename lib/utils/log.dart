import 'package:flutter/foundation.dart';

class Log {
  static void d(Object message) {
    if (kDebugMode) {
      debugPrint(message.toString());
    }
  }

  static void e(Object message) {
    if (kDebugMode) {
      debugPrint("ERROR: $message");
    }
  }

  static void w(Object message) {
    if (kDebugMode) {
      debugPrint("WARNING: $message");
    }
  }

  static void i(Object message) {
    if (kDebugMode) {
      debugPrint("ℹ️ INFO: $message");
    }
  }
}

import 'package:dio/dio.dart';

// Shared API error classifier — detects network vs server errors
class ApiErrorHandler {
  // True when there is no internet or the host is unreachable
  static bool isNetworkError(dynamic e) {
    if (e is DioException) {
      return e.type == DioExceptionType.connectionError ||
          e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.sendTimeout;
    }
    final msg = e.toString().toLowerCase();
    return msg.contains('socketexception') ||
        msg.contains('network is unreachable') ||
        msg.contains('failed host lookup') ||
        msg.contains('connection refused');
  }

  // User-facing message for any thrown error
  static String message(dynamic e) {
    if (isNetworkError(e)) {
      return 'No internet connection.\nPlease connect and try again.';
    }
    if (e is DioException) {
      final data = e.response?.data;
      if (data is Map && data['message'] != null) {
        return data['message'].toString();
      }
    }
    return 'Something went wrong. Please try again.';
  }
}

import 'package:dio/dio.dart';

class ApiErrorHandler {
  static String parse(dynamic e) {
    if (e is DioException) {
      // 1. Check for specific server response (e.g., {"detail": "..."})
      if (e.response != null && e.response!.data != null) {
        final data = e.response!.data;
        if (data is Map) {
          if (data['detail'] != null) return data['detail'].toString();
          if (data['message'] != null) return data['message'].toString();
          if (data['error'] != null) return data['error'].toString();
        }
      }

      // 2. HTTP Status Code Mapping
      if (e.response != null) {
        switch (e.response!.statusCode) {
          case 400:
            return "Invalid request. Please try again.";
          case 401:
          case 403:
            return "Session expired or access denied. Please login again.";
          case 404:
            return "Resource not found.";
          case 429:
            return "Too many requests. Please wait a moment.";
          case 500:
          case 502:
          case 503:
            return "Server is currently unavailable. Please try again later.";
        }
      }

      // 3. Network Type Mapping
      switch (e.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return "Connection timed out. Please check your internet.";
        case DioExceptionType.connectionError:
          return "No internet connection. Please check your settings.";
        case DioExceptionType.cancel:
          return "Request was cancelled.";
        default:
          return "Network error occurred. Please try again.";
      }
    }

    // 4. Non-Dio Exceptions (SocketException, etc.)
    final errorString = e.toString().toLowerCase();
    if (errorString.contains("socketexception") ||
        errorString.contains("connection refused")) {
      return "No internet connection. Please check your settings.";
    }

    // 5. Catch-all
    return "Something went wrong. Please try again.";
  }
}

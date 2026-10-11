import 'package:dio/dio.dart';

/// A readable error the UI can show directly.
class ApiException implements Exception {
  ApiException(this.message, {this.statusCode, this.code});

  final String message;
  final int? statusCode;
  final String? code;

  factory ApiException.fromDio(DioException e) {
    final data = e.response?.data;

    // Backend errors look like { success: false, message, code? }
    if (data is Map && data['message'] is String) {
      return ApiException(
        data['message'] as String,
        statusCode: e.response?.statusCode,
        code: data['code'] as String?,
      );
    }

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(
          'The server took too long to respond. Please try again.',
        );
      case DioExceptionType.connectionError:
        return ApiException(
          'Cannot reach the server. Check your connection and try again.',
        );
      default:
        return ApiException(
          'Something went wrong. Please try again.',
          statusCode: e.response?.statusCode,
        );
    }
  }

  @override
  String toString() => message;
}

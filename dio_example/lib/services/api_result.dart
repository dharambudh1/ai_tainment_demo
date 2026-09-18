import "package:dio/dio.dart";

class ApiResult {
  ApiResult({
    required this.success,
    required this.message,
    required this.data,
    required this.dioError,
  });

  ApiResult.success({
    required this.success,
    required this.message,
    required this.data,
    this.dioError,
  });

  ApiResult.failure({
    required this.success,
    required this.message,
    this.data,
    this.dioError,
  });

  final bool success;
  final String message;
  final dynamic data;
  final DioException? dioError;
}

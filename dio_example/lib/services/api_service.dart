import "package:dio/dio.dart";
import "package:dio_example/services/api_config.dart";
import "package:dio_example/services/api_result.dart";
import "package:dio_example/services/interceptors/auth_interceptor.dart";
import "package:dio_example/services/interceptors/cache_interceptor.dart";
import "package:dio_example/services/interceptors/logger_interceptor.dart";
import "package:dio_example/services/interceptors/retry_interceptor.dart";
import "package:fresh_dio/fresh_dio.dart";

enum MethodType { get, post, put, patch, delete }

class ApiService {
  ApiService._();
  static final ApiService instance = ApiService._();

  final Dio dio = Dio();

  late final Fresh<OAuth2Token> freshInterceptor = buildAuthInterceptor();

  void addInterceptors() {
    dio.options
      ..baseUrl = apiBaseURL
      ..connectTimeout = timeoutForConn
      ..headers.addAll(staticHeaders);

    dio.interceptors.clear();

    // Dio runs request, response and error callbacks in the order added.
    // Cache first, so a hit resolves without paying for the queued token
    // check inside Fresh. Logger last, so it sees the final headers.
    dio.interceptors.add(buildCacheInterceptor());
    dio.interceptors.add(freshInterceptor);
    dio.interceptors.add(buildRetryInterceptor(dio));
    dio.interceptors.add(buildLoggerInterceptor());
  }

  Future<ApiResult> request({
    required String url,
    MethodType method = MethodType.get,
    Map<String, dynamic> queryParameters = const <String, dynamic>{},
    Map<String, dynamic> headers = const <String, dynamic>{},
    Object? body,
    FormData? formData,
  }) async {
    // Timeouts go per request, never on dio.options: those are shared, so
    // concurrent calls would overwrite each other's values.
    final Duration timeout = formData != null ? timeoutForFile : timeoutForJSON;

    final Object? data = formData ?? body;

    try {
      final Response<dynamic> response = await dio.request<dynamic>(
        url,
        // A body on GET has no defined semantics and gets dropped.
        data: method == MethodType.get ? null : data,
        queryParameters: queryParameters,
        options: Options(
          method: method.name.toUpperCase(),
          headers: headers,
          sendTimeout: timeout,
          receiveTimeout: timeout,
        ),
      );

      return ApiResult(
        success: isSuccess(response.statusCode),
        message: constructMessage(response, null),
        data: response.data,
        dioError: null,
      );
    } on DioException catch (error) {
      return ApiResult(
        success: false,
        message: constructMessage(null, error),
        data: null,
        dioError: error,
      );
    }
  }

  bool isSuccess(int? statusCode) {
    return statusCode != null && statusCode >= 200 && statusCode < 300;
  }

  String constructMessage(Response<dynamic>? response, DioException? error) {
    if (error?.error is RevokeTokenException) {
      return "Your session has expired. Please sign in again.";
    }

    final dynamic data = error?.response?.data ?? response?.data;

    if (data is Map) {
      final Object? message = data["message"] ?? data["error"];

      if (message != null) {
        return message.toString();
      }
    }

    // A timeout or dropped connection has no body at all, which would
    // otherwise reach the user as an empty snackbar.
    if (error != null) {
      return describeError(error);
    }

    return response?.statusMessage ?? "";
  }

  String describeError(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.connectionError => "No internet connection.",
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.transformTimeout =>
        "The server took too long to respond. Please try again.",
      DioExceptionType.badCertificate =>
        "The server's security certificate is not valid.",
      DioExceptionType.cancel => "The request was cancelled.",
      DioExceptionType.badResponse ||
      DioExceptionType.unknown => "Something went wrong. Please try again.",
    };
  }
}

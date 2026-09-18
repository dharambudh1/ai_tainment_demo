import "dart:async";

import "package:dio/dio.dart";
import "package:dio_smart_retry/dio_smart_retry.dart";
import "package:fresh_dio/fresh_dio.dart";

/// Safe to send twice. Anything else may already have landed server side.
const Set<String> idempotentMethods = <String>{"GET", "HEAD", "PUT", "DELETE"};

RetryInterceptor buildRetryInterceptor(Dio dio) {
  return RetryInterceptor(dio: dio, retryEvaluator: _shouldRetry);
}

FutureOr<bool> _shouldRetry(DioException error, int attempt) {
  final int? statusCode = error.response?.statusCode;
  
  final String method = error.requestOptions.method.toUpperCase();

  // Fresh reports a revoked session as an untyped DioException, which the
  // default evaluator would happily retry.
  if (error.error is RevokeTokenException ||
      statusCode == 401 ||
      statusCode == 403 ||
      !idempotentMethods.contains(method)) {
    return false;
  }

  return RetryInterceptor.defaultRetryEvaluator(error, attempt);
}

import "package:dio/dio.dart";
import "package:dio_example/services/api_config.dart";
import "package:flutter/foundation.dart";
import "package:pretty_dio_logger/pretty_dio_logger.dart";

PrettyDioLogger buildLoggerInterceptor() {
  return PrettyDioLogger(
    // ignore: avoid_redundant_argument_values
    enabled: kDebugMode,
    logPrint: (Object object) => debugPrint(object.toString()),
    filter: _shouldLog,
  );
}

/// Auth is skipped even though bodies and headers are already off: its
/// request body holds the password and its response body holds both tokens.
bool _shouldLog(RequestOptions options, FilterArgs args) {
  return !whitelistPaths.contains(options.uri.path);
}

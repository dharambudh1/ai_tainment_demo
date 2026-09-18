import "dart:developer";

import "package:dio/dio.dart";
import "package:dio_example/models/login_response.dart";
import "package:dio_example/models/refresh_token_response.dart";
import "package:dio_example/services/api_config.dart";
import "package:dio_example/services/db_service.dart";
import "package:fresh_dio/fresh_dio.dart";
import "package:jwt_decoder/jwt_decoder.dart";

/// Refresh this early, else a token with milliseconds left 401s in flight.
const Duration refreshLeeway = Duration(seconds: 30);

Fresh<OAuth2Token> buildAuthInterceptor() {
  return Fresh.oAuth2(
    // Its own client, with its own timeouts. A refresh runs inside Fresh's
    // queued onRequest, so a hung one would stall every other request.
    httpClient: Dio(
      BaseOptions(
        baseUrl: apiBaseURL,
        connectTimeout: timeoutForConn,
        receiveTimeout: timeoutForJSON,
      ),
    ),
    tokenStorage: _DbTokenStorage(),
    isTokenRequired: _isTokenRequired,
    tokenHeader: _tokenHeader,
    shouldRefresh: _shouldRefresh,
    shouldRefreshBeforeRequest: _shouldRefreshBeforeRequest,
    refreshToken: _refreshToken,
  );
}

bool _isTokenRequired(RequestOptions options) {
  return !whitelistPaths.contains(options.uri.path);
}

Map<String, String> _tokenHeader(OAuth2Token token) {
  return <String, String>{"Authorization": "Bearer ${token.accessToken}"};
}

bool _shouldRefresh(Response<dynamic>? response) {
  return response?.statusCode == 401;
}

bool _shouldRefreshBeforeRequest(RequestOptions options, OAuth2Token? token) {
  final String accessToken = token?.accessToken ?? "";

  if (accessToken.isEmpty) {
    return false;
  }

  // A token with no "exp" throws NoSuchMethodError, not FormatException.
  try {
    return JwtDecoder.getRemainingTime(accessToken) < refreshLeeway;
  } on Object {
    return false;
  }
}

/// Any failure must become [RevokeTokenException]: Fresh clears the stored
/// token only for that type, and rethrows anything else untouched, which
/// would leave a dead token looping forever.
Future<OAuth2Token> _refreshToken(OAuth2Token? token, Dio httpClient) async {
  try {
    final Response<dynamic> response = await httpClient.post(
      "auth/refresh",
      data: <String, dynamic>{
        "refreshToken": token?.refreshToken,
        "expiresInMins": tokenExpiryInMins,
      },
    );

    final RefreshTokenResponse newToken = RefreshTokenResponse.fromJson(
      response.data,
    );

    // Fresh hands this to setToken, which writes it through the storage
    // below - there is no second copy to keep in sync.
    return OAuth2Token(
      accessToken: newToken.accessToken,
      refreshToken: newToken.refreshToken,
    );
  } on Object catch (error, stack) {
    log("Failure in _refreshToken()", error: error, stackTrace: stack);

    throw RevokeTokenException();
  }
}

/// Keeps the token on the stored user record. Fresh reads it on startup and
/// writes through it on every setToken, refresh and clearToken.
class _DbTokenStorage implements TokenStorage<OAuth2Token> {
  @override
  Future<OAuth2Token?> read() async {
    final LoginResponse? user = DbService.instance.getUser();

    final String accessToken = user?.accessToken ?? "";
    
    final String refreshToken = user?.refreshToken ?? "";

    if (accessToken.isEmpty || refreshToken.isEmpty) {
      return null;
    }

    return OAuth2Token(accessToken: accessToken, refreshToken: refreshToken);
  }

  @override
  Future<void> write(OAuth2Token token) async {
    final LoginResponse? user = DbService.instance.getUser();

    if (user == null) {
      return;
    }

    await DbService.instance.setUser(
      user: user.copyWith(
        accessToken: token.accessToken,
        refreshToken: token.refreshToken,
      ),
    );
  }

  @override
  Future<void> delete() async {
    await DbService.instance.removeUser();
  }
}

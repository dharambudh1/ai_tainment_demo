# dio_example

A login-and-dashboard app whose point is everything *between* the controller and the
network. One `Dio` instance carries four interceptors — cache, auth with silent token
refresh, conditional retry, and filtered logging — wired in a deliberate order, with
the failure modes each one guards against written down.

Part of the [ai_tainment_demo](..) monorepo.

## What it demonstrates

- A **token lifecycle** that refreshes *before* expiry rather than reacting to 401s, and that revokes cleanly when refresh fails.
- **Interceptor ordering** as a design decision, not an accident.
- **Retry that knows what's safe to repeat** — idempotent methods only, never an auth failure.
- **Logging that can't leak credentials**, by path rather than by hoping bodies stay off.
- Every `DioException` type mapped to a sentence a user can act on.

## Stack

| Package | Role |
| --- | --- |
| [`dio`](https://pub.dev/packages/dio) `^5.11.1` | HTTP client |
| [`fresh_dio`](https://pub.dev/packages/fresh_dio) `^0.6.0` | OAuth2 token storage, injection, and queued refresh |
| [`dio_cache_interceptor`](https://pub.dev/packages/dio_cache_interceptor) `^4.0.7` | Response caching |
| [`dio_smart_retry`](https://pub.dev/packages/dio_smart_retry) `^7.0.1` | Retry with backoff |
| [`pretty_dio_logger`](https://pub.dev/packages/pretty_dio_logger) `^1.4.0` | Request/response logging |
| [`jwt_decoder`](https://pub.dev/packages/jwt_decoder) `^2.0.1` | Reading `exp` for pre-emptive refresh |
| [`get`](https://pub.dev/packages/get) `^4.7.3` | Routing, DI, reactivity |
| [`get_storage`](https://pub.dev/packages/get_storage) `^2.1.1` | Persisting the user record and its tokens |

## Running

```bash
flutter pub get
flutter run
```

No local server needed — it talks to [dummyjson.com](https://dummyjson.com).

**Test credentials:**

| Username | Password |
| --- | --- |
| `emilys` | `emilyspass` |

Any user from [dummyjson.com/users](https://dummyjson.com/users) works; the password
is always the username followed by `pass`.

### Watching the refresh happen

`api_config.dart` requests a **1-minute** access token:

```dart
const int tokenExpiryInMins = 1;
```

Combined with a 30-second refresh leeway, that means: log in, sit on the dashboard
for ~30 seconds, then pull the user again — you'll see `auth/refresh` fire in the
console *before* any request has been rejected. Raise this value for normal use; it
is short purely to make the mechanism observable.

## Architecture

```
lib/
├── main.dart                    # init storage, wire interceptors, choose initial route
├── services/
│   ├── api_config.dart          # base URL, timeouts, whitelisted paths
│   ├── api_service.dart         # the Dio singleton + request() + error messaging
│   ├── api_result.dart          # success / message / data / dioError
│   ├── db_service.dart          # get_storage wrapper for the user record
│   └── interceptors/
│       ├── cache_interceptor.dart
│       ├── auth_interceptor.dart
│       ├── retry_interceptor.dart
│       └── logger_interceptor.dart
├── repository/auth_repository.dart
├── controllers/ · bindings/ · screens/ · models/
└── utils/pretty_print_util.dart
```

On launch, `main()` initialises storage, installs the interceptors, then picks the
start route from whether a user record exists — so a returning user lands on the
dashboard without a round trip:

```dart
final String initialRoute =
    DbService.instance.getUser() != null ? "/dashboard" : "/login";
```

## The interceptor chain

Dio invokes request, response, and error callbacks **in the order added**. The order
here is load-bearing:

```dart
dio.interceptors.add(buildCacheInterceptor());   // 1
dio.interceptors.add(freshInterceptor);          // 2
dio.interceptors.add(buildRetryInterceptor(dio));// 3
dio.interceptors.add(buildLoggerInterceptor());  // 4
```

1. **Cache first** — a cache hit short-circuits the request without paying for the
   queued token check inside Fresh.
2. **Auth second** — attaches the bearer token, and refreshes if needed.
3. **Retry third** — so a retried request is re-issued with the *refreshed* token.
4. **Logger last** — it sees the final headers, after auth has added them.

### 1 · Cache

A `MemCacheStore` held at library level so logout can reach it:

```dart
/// Cleared on logout, so one account is never served another's responses.
final CacheStore cacheStore = MemCacheStore();
```

`AuthRepository.requestLogout()` calls `cacheStore.clean()` alongside clearing the
token and the user record. Without that, signing in as a different user could be
served the previous user's cached `auth/me`.

### 2 · Auth — `fresh_dio`

Built via `Fresh.oAuth2`, with five decisions worth reading:

**Its own HTTP client.** The refresh call cannot share the main `Dio`:

```dart
httpClient: Dio(BaseOptions(
  baseUrl: apiBaseURL,
  connectTimeout: timeoutForConn,
  receiveTimeout: timeoutForJSON,
)),
```

A refresh runs inside Fresh's *queued* `onRequest`. If it hung on the shared client's
(possibly per-request, possibly absent) timeouts, every other request would stall
behind it.

**Refresh before expiry, not after rejection.**

```dart
const Duration refreshLeeway = Duration(seconds: 30);

bool _shouldRefreshBeforeRequest(RequestOptions options, OAuth2Token? token) {
  // ...
  try {
    return JwtDecoder.getRemainingTime(accessToken) < refreshLeeway;
  } on Object {
    return false;
  }
}
```

A token with milliseconds left would otherwise 401 *in flight*. The `catch` is
`on Object` rather than `on Exception` deliberately — a JWT with no `exp` claim makes
`jwt_decoder` throw `NoSuchMethodError`, which is an `Error`, not an `Exception`.
`shouldRefresh` still handles reactive 401s as a backstop.

**Any refresh failure must become `RevokeTokenException`.**

```dart
} on Object catch (error, stack) {
  log("Failure in _refreshToken()", error: error, stackTrace: stack);
  throw RevokeTokenException();
}
```

Fresh clears the stored token for *that type only* and rethrows anything else
untouched — which would leave a dead token retrying forever.

**Tokens live on the user record.** `_DbTokenStorage` implements Fresh's
`TokenStorage` by reading and writing through `DbService`, so there is exactly one
persisted copy and nothing to keep in sync:

```dart
@override
Future<void> write(OAuth2Token token) async {
  final LoginResponse? user = DbService.instance.getUser();
  if (user == null) return;
  await DbService.instance.setUser(
    user: user.copyWith(accessToken: token.accessToken, refreshToken: token.refreshToken),
  );
}
```

**Auth endpoints are exempt.** `isTokenRequired` consults a shared whitelist, so
login and refresh don't carry (or wait for) a token:

```dart
const List<String> whitelistPaths = <String>["/auth/login", "/auth/refresh"];
```

### 3 · Retry

The default evaluator is too eager, so retries are gated first:

```dart
const Set<String> idempotentMethods = <String>{"GET", "HEAD", "PUT", "DELETE"};

if (error.error is RevokeTokenException ||
    statusCode == 401 || statusCode == 403 ||
    !idempotentMethods.contains(method)) {
  return false;
}
return RetryInterceptor.defaultRetryEvaluator(error, attempt);
```

- **POST and PATCH are never retried** — they may already have landed server-side.
- **401/403 are never retried** — refreshing is Fresh's job; retrying just burns attempts.
- **A revoked session is never retried.** Fresh reports it as an *untyped*
  `DioException`, which the default evaluator would happily repeat.

### 4 · Logging

```dart
PrettyDioLogger(
  enabled: kDebugMode,
  logPrint: (Object object) => debugPrint(object.toString()),
  filter: _shouldLog,
);
```

Off entirely in release. Auth paths are filtered out by path even though bodies and
headers are already disabled — belt and braces, because the login *request* body
holds the password and the login *response* body holds both tokens.

## Request and error handling

`ApiService.request()` returns an `ApiResult` (`success`, `message`, `data`,
`dioError`) instead of throwing, so callers branch on a value.

**Timeouts are per request, never on `dio.options`:**

```dart
final Duration timeout = formData != null ? timeoutForFile : timeoutForJSON;
```

`dio.options` is shared mutable state — setting timeouts there means two concurrent
calls overwrite each other's values. File uploads get 5 minutes, JSON 30 seconds,
connect 5 seconds.

**A body on `GET` is dropped**, since it has no defined semantics:

```dart
data: method == MethodType.get ? null : data,
```

**Every failure produces a usable sentence.** `constructMessage` prefers the server's
`message`/`error` field, then falls back to `describeError` — because a timeout or
dropped connection has no body at all and would otherwise surface as an empty
snackbar:

```dart
return switch (error.type) {
  DioExceptionType.connectionTimeout ||
  DioExceptionType.connectionError => "No internet connection.",
  DioExceptionType.sendTimeout ||
  DioExceptionType.receiveTimeout ||
  DioExceptionType.transformTimeout =>
      "The server took too long to respond. Please try again.",
  DioExceptionType.badCertificate => "The server's security certificate is not valid.",
  DioExceptionType.cancel => "The request was cancelled.",
  DioExceptionType.badResponse ||
  DioExceptionType.unknown => "Something went wrong. Please try again.",
};
```

A `RevokeTokenException` is special-cased ahead of all of it: *"Your session has
expired. Please sign in again."*

## Flows

**Login** — `LoginController` validates the form, `AuthRepository.requestLogin` posts
to `auth/login`, then persists the user *and* hands the tokens to Fresh via
`setToken`, which writes them through `_DbTokenStorage`. Then `Get.offAllNamed("/dashboard")`.

**Dashboard** — `onReady` calls `auth/me` and renders the response as pretty-printed
JSON, which makes the token state visible while you experiment.

**Logout** — clear the Fresh token, remove the user record, clean the cache, then
`Get.offAllNamed("/login")`.

## Endpoints used

| Method | Path | Notes |
| --- | --- | --- |
| `POST` | `auth/login` | whitelisted: no token, never logged |
| `POST` | `auth/refresh` | whitelisted; called on its own `Dio` |
| `GET` | `auth/me` | requires a bearer token |

## Configuration

All in `lib/services/api_config.dart`:

| Constant | Value | Purpose |
| --- | --- | --- |
| `apiBaseURL` | `https://dummyjson.com/` | base URL |
| `timeoutForConn` | 5 s | connect timeout |
| `timeoutForJSON` | 30 s | send/receive for JSON |
| `timeoutForFile` | 5 min | send/receive when a `FormData` is present |
| `tokenExpiryInMins` | 1 | requested access-token lifetime |
| `whitelistPaths` | login, refresh | skip token injection and logging |
| `refreshLeeway` (in `auth_interceptor.dart`) | 30 s | refresh this far before `exp` |

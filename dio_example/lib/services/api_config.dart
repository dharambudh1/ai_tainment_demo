/// Values shared by the API client and more than one interceptor.
const String apiBaseURL = "https://dummyjson.com/";

/// Headers that are always added to the request.
const Map<String, dynamic> staticHeaders = <String, dynamic>{
  "Connection": "keep-alive",
  "Accept": "*/*",
};

const Duration timeoutForConn = Duration(seconds: 05);

const Duration timeoutForJSON = Duration(seconds: 30);

const Duration timeoutForFile = Duration(minutes: 05);

const int tokenExpiryInMins = 1;

/// Endpoints that carry no token and are never logged.
const List<String> whitelistPaths = <String>["/auth/login", "/auth/refresh"];

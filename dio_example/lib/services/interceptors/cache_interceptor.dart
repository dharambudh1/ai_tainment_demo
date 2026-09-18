import "package:dio_cache_interceptor/dio_cache_interceptor.dart";

/// Cleared on logout, so one account is never served another's responses.
final CacheStore cacheStore = MemCacheStore();

/// Returns a new instance of [DioCacheInterceptor].
DioCacheInterceptor buildCacheInterceptor() {
  return DioCacheInterceptor(options: CacheOptions(store: cacheStore));
}

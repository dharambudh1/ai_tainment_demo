import "package:dio_example/models/login_request.dart";
import "package:dio_example/models/login_response.dart";
import "package:dio_example/services/api_result.dart";
import "package:dio_example/services/api_service.dart";
import "package:dio_example/services/db_service.dart";
import "package:dio_example/services/interceptors/cache_interceptor.dart";
import "package:flutter/material.dart";
import "package:fresh_dio/fresh_dio.dart";
import "package:get/get.dart";

class AuthRepository {
  AuthRepository._();

  static final AuthRepository instance = AuthRepository._();

  Future<LoginResponse> requestLogin(LoginRequest request) async {
    final ApiResult result = await ApiService.instance.request(
      url: "auth/login",
      method: MethodType.post,
      body: request.toJson(),
    );

    if (result.success) {
      final LoginResponse response = LoginResponse.fromJson(
        result.data as Map<String, dynamic>,
      );

      /// save user data in db
      await DbService.instance.setUser(user: response);

      /// set token in fresh_dio
      await ApiService.instance.freshInterceptor.setToken(
        OAuth2Token(
          accessToken: response.accessToken ?? "",
          refreshToken: response.refreshToken ?? "",
        ),
      );

      return response;
    } else {
      ScaffoldMessenger.of(
        Get.context!,
      ).showSnackBar(SnackBar(content: Text(result.message)));

      throw Exception(result.message);
    }
  }

  Future<void> requestLogout() async {
    /// clear token in fresh_dio
    await ApiService.instance.freshInterceptor.clearToken();

    /// remove user data from db
    await DbService.instance.removeUser();

    /// clear cache
    await cacheStore.clean();

    return Future<void>.value();
  }

  Future<LoginResponse> requestGetUser() async {
    final ApiResult result = await ApiService.instance.request(url: "auth/me");

    if (result.success) {
      final LoginResponse response = LoginResponse.fromJson(
        result.data as Map<String, dynamic>,
      );

      return response;
    } else {
      ScaffoldMessenger.of(
        Get.context!,
      ).showSnackBar(SnackBar(content: Text(result.message)));

      throw Exception(result.message);
    }
  }
}

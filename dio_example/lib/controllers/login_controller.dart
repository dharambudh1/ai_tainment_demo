import "package:dio_example/models/login_request.dart";
import "package:dio_example/repository/auth_repository.dart";
import "package:dio_example/services/api_config.dart";
import "package:flutter/material.dart";
import "package:get/get.dart" hide Response;

class LoginController extends GetxController {
  final AuthRepository authRepository = AuthRepository.instance;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> login() async {
    if (!(formKey.currentState?.validate() ?? false)) {
      return;
    }

    final LoginRequest request = LoginRequest(
      username: usernameController.text.trim(),
      password: passwordController.text.trim(),
      expiresInMins: tokenExpiryInMins,
    );

    await authRepository.requestLogin(request);

    /// go to dashboard page
    await Get.offAllNamed("/dashboard");
  }

  @override
  void onClose() {
    usernameController.dispose();
    passwordController.dispose();

    super.onClose();
  }
}

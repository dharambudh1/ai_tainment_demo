import "dart:async";

import "package:dio_example/models/login_response.dart";
import "package:dio_example/repository/auth_repository.dart";
import "package:get/get.dart";

class DashboardController extends GetxController {
  final AuthRepository authRepository = AuthRepository.instance;

  final Rx<LoginResponse?> user = Rx<LoginResponse?>(null);

  @override
  Future<void> onReady() async {
    super.onReady();

    /// load user data
    await loadUser();
  }

  Future<void> loadUser() async {
    user.value = await authRepository.requestGetUser();

    return Future<void>.value();
  }

  Future<void> logout() async {
    await authRepository.requestLogout();

    /// go to login page
    await Get.offAllNamed("/login");

    return Future<void>.value();
  }
}

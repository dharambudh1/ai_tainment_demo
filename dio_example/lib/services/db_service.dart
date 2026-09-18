import "dart:developer";

import "package:dio_example/models/login_response.dart";
import "package:get_storage/get_storage.dart";

class DbService {
  DbService._();
  static final DbService instance = DbService._();

  final GetStorage getConnect = GetStorage();
  final String keyUser = "user";

  Future<bool> init() async {
    try {
      await GetStorage.init();
      log("Success in DBService.init()");

      return true;
    } on Exception catch (error, stack) {
      log("Failure in DBService.init()", error: error, stackTrace: stack);

      return false;
    }
  }

  Future<bool> write({required Map<String, dynamic> value}) async {
    try {
      await getConnect.write(keyUser, value);
      log("Success in DBService.write()");

      return true;
    } on Exception catch (error, stack) {
      log("Failure in DBService.write()", error: error, stackTrace: stack);

      return false;
    }
  }

  Map<String, dynamic> read() {
    try {
      final dynamic result = getConnect.read(keyUser);

      if (result != null && result is Map<String, dynamic>) {
        log("Success in DBService.read()");

        return result;
      } else {
        log("Failure in DBService.read() - result is null or not a map");

        return <String, dynamic>{};
      }
    } on Exception catch (error, stack) {
      log("Failure in DBService.read()", error: error, stackTrace: stack);

      return <String, dynamic>{};
    }
  }

  LoginResponse? getUser() {
    try {
      final Map<String, dynamic> result = read();

      if (result.isNotEmpty) {
        log("Success in DBService.user() - user exists");

        return LoginResponse.fromJson(result);
      } else {
        log("Failure in DBService.user() - user does not exist");

        return null;
      }
    } on Exception catch (error, stack) {
      log("Failure in DBService.user()", error: error, stackTrace: stack);

      return null;
    }
  }

  Future<bool> setUser({required LoginResponse user}) async {
    try {
      await write(value: user.toJson());
      log("Success in DBService.setUser()");

      return true;
    } on Exception catch (error, stack) {
      log("Failure in DBService.setUser()", error: error, stackTrace: stack);

      return false;
    }
  }

  Future<bool> removeUser() async {
    try {
      await getConnect.remove(keyUser);
      log("Success in DBService.removeUser()");

      return true;
    } on Exception catch (error, stack) {
      log("Failure in DBService.deleteUser()", error: error, stackTrace: stack);

      return false;
    }
  }
}

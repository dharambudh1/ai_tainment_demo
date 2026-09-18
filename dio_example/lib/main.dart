import "package:dio_example/bindings/dashboard_binding.dart";
import "package:dio_example/bindings/login_binding.dart";
import "package:dio_example/screens/dashboard_screen.dart";
import "package:dio_example/screens/login_screen.dart";
import "package:dio_example/services/api_service.dart";
import "package:dio_example/services/db_service.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await DbService.instance.init();

  ApiService.instance.addInterceptors();

  final String initialRoute = DbService.instance.getUser() != null
      ? "/dashboard"
      : "/login";

  runApp(MainApp(initialRoute: initialRoute));
}

class MainApp extends StatelessWidget {
  const MainApp({required this.initialRoute, super.key});

  final String initialRoute;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "Dio Example",
      initialRoute: initialRoute,
      debugShowCheckedModeBanner: false,
      getPages: <GetPage<dynamic>>[
        GetPage<dynamic>(
          name: "/login",
          page: LoginScreen.new,
          binding: LoginBinding(),
        ),
        GetPage<dynamic>(
          name: "/dashboard",
          page: DashboardScreen.new,
          binding: DashboardBinding(),
        ),
      ],
    );
  }
}

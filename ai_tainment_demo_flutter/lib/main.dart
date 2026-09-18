import "package:ai_tainment_demo_flutter/repository/mock_repository_offline.dart";
import "package:ai_tainment_demo_flutter/repository/mock_repository_online.dart";
import "package:ai_tainment_demo_flutter/services/storage_service.dart";
import "package:ai_tainment_demo_flutter/utils/app_routes.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:get_storage/get_storage.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await GetStorage.init();

  Get
    ..lazyPut(StorageService.new, fenix: true)
    ..lazyPut(MockRepositoryOffline.new, fenix: true)
    ..lazyPut(MockRepositoryOnline.new, fenix: true);

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: "AI Tainment Demo",
      getPages: AppRoutes().routes,
      debugShowCheckedModeBanner: false,
      enableLog: false,
    );
  }
}

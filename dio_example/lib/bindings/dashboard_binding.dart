import "package:dio_example/controllers/dashboard_controller.dart";
import "package:get/get.dart";

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DashboardController>(DashboardController.new);
  }
}

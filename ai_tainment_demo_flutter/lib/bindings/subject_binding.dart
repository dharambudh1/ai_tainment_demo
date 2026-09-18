import "package:ai_tainment_demo_flutter/controllers/subject_controller.dart";
import "package:get/get.dart";

class SubjectBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SubjectController>(SubjectController.new);
  }
}

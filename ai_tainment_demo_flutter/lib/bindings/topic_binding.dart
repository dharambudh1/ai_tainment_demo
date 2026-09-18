import "package:ai_tainment_demo_flutter/controllers/topic_controller.dart";
import "package:get/get.dart";

class TopicBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TopicController>(TopicController.new);
  }
}

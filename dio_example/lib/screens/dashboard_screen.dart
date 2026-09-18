import "package:dio_example/controllers/dashboard_controller.dart";
import "package:dio_example/models/login_response.dart";
import "package:dio_example/utils/pretty_print_util.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";

class DashboardScreen extends GetView<DashboardController> {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: controller.logout,
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Obx(() {
            final LoginResponse? user = controller.user.value;
            return user != null
                ? Text(PrettyPrintUtil.instance.prettyPrint(user.toJson()))
                : const SizedBox();
          }),
        ),
      ),
    );
  }
}

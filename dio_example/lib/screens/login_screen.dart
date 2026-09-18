import "package:dio_example/controllers/login_controller.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";

class LoginScreen extends GetView<LoginController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Dashboard")),
      body: SafeArea(
        child: Form(
          key: controller.formKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              children: <Widget>[
                TextFormField(
                  controller: controller.usernameController,
                  decoration: const InputDecoration(labelText: "Username"),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter username";
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: controller.passwordController,
                  decoration: const InputDecoration(labelText: "Password"),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter password";
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: controller.login,
                  child: const Text("Login"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

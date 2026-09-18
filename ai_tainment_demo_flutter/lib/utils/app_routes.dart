import "package:ai_tainment_demo_flutter/bindings/subject_binding.dart";
import "package:ai_tainment_demo_flutter/bindings/topic_binding.dart";
import "package:ai_tainment_demo_flutter/screens/subject_screen.dart";
import "package:ai_tainment_demo_flutter/screens/topic_screen.dart";
import "package:get/get.dart";

class AppRoutes {
  static const String subjectRoute = "/";
  static const String topicRoute = "/topic";

  final List<GetPage<dynamic>> routes = <GetPage<dynamic>>[
    GetPage<dynamic>(
      name: subjectRoute,
      page: SubjectScreen.new,
      binding: SubjectBinding(),
    ),

    GetPage<dynamic>(
      name: topicRoute,
      page: TopicScreen.new,
      binding: TopicBinding(),
    ),
  ];
}

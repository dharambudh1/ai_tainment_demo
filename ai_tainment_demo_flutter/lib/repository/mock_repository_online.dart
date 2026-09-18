import "dart:developer";

import "package:ai_tainment_demo_flutter/models/subject_model.dart";
import "package:ai_tainment_demo_flutter/models/topic_model.dart";
import "package:get/get.dart";

class MockRepositoryOnline extends GetConnect {
  MockRepositoryOnline() {
    httpClient.baseUrl = baseURL;
    httpClient.timeout = const Duration(minutes: 2);
    httpClient.defaultContentType = "application/json";
    httpClient.sendUserAgent = true;
  }

  final String baseURL = "https://ai-tainment-demo.onrender.com/";

  Future<List<SubjectModel>> getSubjects(
    int subjectPage,
    int subjectLimit,
  ) async {
    try {
      final Response<dynamic> response = await get(
        "api/subjects?page=$subjectPage&limit=$subjectLimit",
      );

      if (!response.isOk || response.body == null) {
        throw Exception(
          // ignore: lines_longer_than_80_chars
          "Failed to load subjects: [${response.statusCode}] ${response.statusText}",
        );
      }

      if (response.body is! List) {
        throw Exception(
          // ignore: lines_longer_than_80_chars
          "Expected List from subjects API, got: ${response.body.runtimeType}",
        );
      }

      final List<dynamic> data = response.body as List<dynamic>;

      return data.map((Object? item) {
        return SubjectModel.fromJson(
          Map<String, dynamic>.from(item! as Map<String, dynamic>),
        );
      }).toList();
    } catch (error, stackTrace) {
      log("Error in getSubjects: $error", error: error, stackTrace: stackTrace);
      rethrow;
    }
  }

  Future<List<TopicModel>> getTopics(
    SubjectModel subject,
    int topicPage,
    int topicLimit,
  ) async {
    try {
      final Response<dynamic> response = await get(
        "api/subjects/${subject.subjectId}/topics?page=$topicPage&limit=$topicLimit",
      );

      if (!response.isOk || response.body == null) {
        throw Exception(
          // ignore: lines_longer_than_80_chars
          "Failed to load topics: [${response.statusCode}] ${response.statusText}",
        );
      }

      if (response.body is! List) {
        throw Exception(
          // ignore: lines_longer_than_80_chars
          "Expected List from topics API, got: ${response.body.runtimeType}",
        );
      }

      final List<dynamic> data = response.body as List<dynamic>;

      return data.map((Object? item) {
        return TopicModel.fromJson(
          Map<String, dynamic>.from(item! as Map<String, dynamic>),
        );
      }).toList();
    } catch (error, stackTrace) {
      log("Error in getTopics: $error", error: error, stackTrace: stackTrace);
      rethrow;
    }
  }
}

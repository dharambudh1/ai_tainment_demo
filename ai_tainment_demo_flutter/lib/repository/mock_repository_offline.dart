import "package:ai_tainment_demo_flutter/config/page_config.dart";
import "package:ai_tainment_demo_flutter/models/subject_model.dart";
import "package:ai_tainment_demo_flutter/models/topic_model.dart";
import "package:get/get.dart";

Duration duration = const Duration(milliseconds: 500);

class MockRepositoryOffline extends GetxService {
  Future<List<SubjectModel>> getSubjects(
    int subjectPage,
    int subjectLimit,
  ) async {
    // Fake latency to mimic network calls.
    await Future<void>.delayed(duration);

    final List<SubjectModel> subjects = <SubjectModel>[];

    final int offset = (subjectPage - 1) * subjectLimit;

    for (int i = 0; i < subjectLimit; i++) {
      final int s = offset + i + 1;

      if (s > totalSubjects) {
        break;
      }

      final SubjectModel subject = SubjectModel(
        subjectId: "subject_$s",
        subjectTitle: "Subject $s",
        topicCount: topicsPerSubject,
        topics: const <TopicModel>[],
      );

      subjects.add(subject);
    }

    return subjects;
  }

  Future<List<TopicModel>> getTopics(
    SubjectModel subject,
    int topicPage,
    int topicLimit,
  ) async {
    // Fake latency to mimic network calls.
    await Future<void>.delayed(duration);

    final List<TopicModel> topics = <TopicModel>[];

    final int offset = (topicPage - 1) * topicLimit;

    for (int i = 0; i < topicLimit; i++) {
      final int s = offset + i + 1;

      if (s > subject.topicCount) {
        break;
      }

      final TopicModel topic = TopicModel(
        topicId: "${subject.subjectId}_topic_$s",
        topicTitle: "Topic $s",
      );

      topics.add(topic);
    }

    return topics;
  }
}

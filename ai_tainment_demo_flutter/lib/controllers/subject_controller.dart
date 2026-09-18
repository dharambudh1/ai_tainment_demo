import "package:ai_tainment_demo_flutter/config/page_config.dart";
import "package:ai_tainment_demo_flutter/factory/pagination_factory.dart";
import "package:ai_tainment_demo_flutter/models/memory_model.dart";
import "package:ai_tainment_demo_flutter/models/subject_model.dart";
import "package:ai_tainment_demo_flutter/models/topic_model.dart";
import "package:ai_tainment_demo_flutter/services/storage_service.dart";
import "package:ai_tainment_demo_flutter/utils/app_routes.dart";
import "package:get/get.dart";
import "package:super_paging/super_paging.dart";

class SubjectController extends GetxController {
  final StorageService storage = Get.find<StorageService>();

  final Map<dynamic, dynamic> subjectPager = <dynamic, dynamic>{};

  final Map<String, Pager<int, TopicModel>> topicPagers =
      <String, Pager<int, TopicModel>>{};

  Pager<int, SubjectModel> getSubjectPager() {
    return subjectPager.putIfAbsent("", () {
      final List<MemoryModel> items = storage.sortByLatestToLeastLatest();

      return Pager<int, SubjectModel>(
        initialKey: items.isNotEmpty ? items.first.subjectPageIndex : 1,
        config: config,
        pagingSourceFactory: () {
          return SubjectPaginationFactory();
        },
      );
    });
  }

  Pager<int, TopicModel> topicPager(SubjectModel subject) {
    return topicPagers.putIfAbsent(subject.subjectId, () {
      final MemoryModel existing = storage.topicMemoryFromSubjectMemory(
        subject,
      );

      return Pager<int, TopicModel>(
        initialKey: existing.topicPageIndex,
        config: config,
        pagingSourceFactory: () {
          return TopicPaginationFactory(subject: subject);
        },
      );
    });
  }

  int countBySubjectId(SubjectModel subject) {
    final MemoryModel item = storage.topicMemoryFromSubjectMemory(subject);
    return item.topicIds.length;
  }

  int countByTopicId(TopicModel topic) {
    final MemoryModel item = storage.subjectMemoryFromTopicMemory(topic);
    return item.topicIds.contains(topic.topicId) ? 1 : 0;
  }

  int topicCount(SubjectModel subject) {
    return subject.topicCount;
  }

  double getPercentage(SubjectModel subject) {
    if (subject.topicCount <= 0) {
      return 0.0;
    }

    return ((countBySubjectId(subject) / subject.topicCount) * 100).clamp(
      0.0,
      100.0,
    );
  }

  Future<void> navigation({
    required SubjectModel subject,
    required int subjectPageIndex,
    required int subjectItemIndex,
  }) async {
    await Get.toNamed(
      AppRoutes.topicRoute,
      arguments: <String, Object>{
        "subject": subject,
        "subjectPageIndex": subjectPageIndex,
        "subjectItemIndex": subjectItemIndex,
      },
    );

    return;
  }

  @override
  void onClose() {
    for (final Pager<dynamic, dynamic> subjectPager in subjectPager.values) {
      subjectPager.dispose();
    }

    for (final Pager<int, TopicModel> topicPager in topicPagers.values) {
      topicPager.dispose();
    }

    super.onClose();
  }

  bool isLatestSubject(SubjectModel subject) {
    final List<MemoryModel> items = storage.sortByLatestToLeastLatest();

    final MemoryModel last = items.firstOrNull ?? const MemoryModel.empty();

    return last.subjectId == subject.subjectId;
  }

  bool isLatestTopic(SubjectModel subject, TopicModel topic) {
    final MemoryModel existing = storage.topicMemoryFromSubjectMemory(subject);

    return isLatestSubject(subject) &&
        existing.topicIds.isNotEmpty &&
        existing.topicIds.last == topic.topicId;
  }
}

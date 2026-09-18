import "package:ai_tainment_demo_flutter/config/page_config.dart";
import "package:ai_tainment_demo_flutter/factory/pagination_factory.dart";
import "package:ai_tainment_demo_flutter/models/memory_model.dart";
import "package:ai_tainment_demo_flutter/models/subject_model.dart";
import "package:ai_tainment_demo_flutter/models/topic_model.dart";
import "package:ai_tainment_demo_flutter/services/storage_service.dart";
import "package:get/get.dart";
import "package:super_paging/super_paging.dart";

class TopicController extends GetxController {
  final StorageService storage = Get.find<StorageService>();

  final Rx<SubjectModel> subject = const SubjectModel.empty().obs;

  int subjectPageIndex = 1;
  int subjectItemIndex = 1;

  final Map<String, Pager<int, TopicModel>> topicPagers =
      <String, Pager<int, TopicModel>>{};

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

  @override
  void onInit() {
    super.onInit();

    final dynamic arguments = Get.arguments;

    if (arguments is Map) {
      if (arguments["subject"] is SubjectModel) {
        subject.value = arguments["subject"];
      }

      if (arguments["subjectPageIndex"] is int) {
        subjectPageIndex = arguments["subjectPageIndex"];
      }

      if (arguments["subjectItemIndex"] is int) {
        subjectItemIndex = arguments["subjectItemIndex"];
      }
    }
  }

  bool exists(TopicModel topic) {
    final MemoryModel existing = storage.topicMemoryFromSubjectMemory(
      subject.value,
    );

    return existing.topicIds.contains(topic.topicId);
  }

  Future<void> registerTap({
    required int topicPageIndex,
    required int topicItemIndex,
    required TopicModel topic,
  }) async {
    final MemoryModel existing = storage.topicMemoryFromSubjectMemory(
      subject.value,
    );

    final List<String> rememberedIds = List<String>.from(existing.topicIds);

    (!rememberedIds.contains(topic.topicId))
        ? rememberedIds.add(topic.topicId)
        : rememberedIds.remove(topic.topicId);

    final MemoryModel item = MemoryModel(
      subjectPageIndex: subjectPageIndex,
      subjectItemIndex: subjectItemIndex,
      topicPageIndex: topicPageIndex,
      topicItemIndex: topicItemIndex,
      subjectId: subject.value.subjectId,
      topicIds: rememberedIds,
      updated: DateTime.now().toIso8601String(),
    );

    await storage.update(item);
  }

  @override
  void onClose() {
    for (final Pager<int, TopicModel> topicPager in topicPagers.values) {
      topicPager.dispose();
    }

    super.onClose();
  }

  bool isLatestTopic(SubjectModel subject, TopicModel topic) {
    final MemoryModel existing = storage.topicMemoryFromSubjectMemory(subject);

    return existing.topicIds.isNotEmpty &&
        existing.topicIds.last == topic.topicId;
  }
}

import "package:ai_tainment_demo_flutter/models/memory_model.dart";
import "package:ai_tainment_demo_flutter/models/subject_model.dart";
import "package:ai_tainment_demo_flutter/models/topic_model.dart";
import "package:get/get.dart";
import "package:get_storage/get_storage.dart";

class StorageService extends GetxService {
  final GetStorage storage = GetStorage();

  final String storageKey = "storageKey";

  final RxList<MemoryModel> rememberedItems = <MemoryModel>[].obs;

  @override
  void onInit() {
    super.onInit();

    rememberedItems.addAll(readRememberedItems());
  }

  List<MemoryModel> readRememberedItems() {
    final dynamic result = storage.read<dynamic>(storageKey);

    if (result is List<dynamic> && result.isNotEmpty) {
      return result.map((Object? item) {
        if (item is MemoryModel) {
          return item;
        }

        final Map<String, dynamic> json = Map<String, dynamic>.from(
          item! as Map<dynamic, dynamic>,
        );

        return MemoryModel.fromJson(json);
      }).toList();
    }

    return <MemoryModel>[];
  }

  Future<void> update(MemoryModel remember) async {
    final int index = rememberedItems.indexWhere((MemoryModel element) {
      return element.subjectId == remember.subjectId;
    });

    if (index != -1) {
      rememberedItems[index] = remember;
    } else {
      rememberedItems.add(remember);
    }

    await storage.write(
      storageKey,
      rememberedItems.map((MemoryModel element) {
        return element.toJson();
      }).toList(),
    );

    return;
  }

  List<MemoryModel> sortByLatestToLeastLatest() {
    final List<MemoryModel> items = rememberedItems.toList()
      ..sort((MemoryModel a, MemoryModel b) {
        final DateTime dateA =
            DateTime.tryParse(a.updated) ??
            DateTime.fromMillisecondsSinceEpoch(0);
        final DateTime dateB =
            DateTime.tryParse(b.updated) ??
            DateTime.fromMillisecondsSinceEpoch(0);

        return dateB.compareTo(dateA);
      });

    return items;
  }

  MemoryModel subjectMemoryFromTopicMemory(TopicModel topic) {
    return rememberedItems.firstWhere((MemoryModel element) {
      return element.topicIds.contains(topic.topicId);
    }, orElse: MemoryModel.empty);
  }

  MemoryModel topicMemoryFromSubjectMemory(SubjectModel subject) {
    return rememberedItems.firstWhere((MemoryModel element) {
      return element.subjectId == subject.subjectId;
    }, orElse: MemoryModel.empty);
  }
}

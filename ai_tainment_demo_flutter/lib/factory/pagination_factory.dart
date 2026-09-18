import "dart:developer";

import "package:ai_tainment_demo_flutter/models/subject_model.dart";
import "package:ai_tainment_demo_flutter/models/topic_model.dart";
import "package:ai_tainment_demo_flutter/repository/mock_repository_offline.dart";
import "package:ai_tainment_demo_flutter/repository/mock_repository_online.dart";
import "package:get/get.dart";
import "package:super_paging/super_paging.dart";

class SubjectPaginationFactory extends PagingSource<int, SubjectModel> {
  SubjectPaginationFactory({this.onPageLoaded, this.useOnline = true});

  final Future<void> Function(int page)? onPageLoaded;
  final bool useOnline;

  @override
  Future<LoadResult<int, SubjectModel>> load(LoadParams<int> params) async {
    try {
      final int page = params.key ?? 1;

      final List<SubjectModel> items = useOnline
          ? await Get.find<MockRepositoryOnline>().getSubjects(
              page,
              params.loadSize,
            )
          : await Get.find<MockRepositoryOffline>().getSubjects(
              page,
              params.loadSize,
            );

      await onPageLoaded?.call(page);

      final bool hasNextPage = items.length == params.loadSize;

      return LoadResult<int, SubjectModel>.page(
        items: items,
        prevKey: page > 1 ? page - 1 : null,
        nextKey: hasNextPage ? page + 1 : null,
      );
    } on Exception catch (error, stackTrace) {
      log("Error : $error", error: error, stackTrace: stackTrace);

      return LoadResult<int, SubjectModel>.error(error);
    }
  }
}

class TopicPaginationFactory extends PagingSource<int, TopicModel> {
  TopicPaginationFactory({
    required this.subject,
    this.onPageLoaded,
    this.useOnline = true,
  });

  final SubjectModel subject;
  final Future<void> Function(int page)? onPageLoaded;
  final bool useOnline;

  @override
  Future<LoadResult<int, TopicModel>> load(LoadParams<int> params) async {
    try {
      final int page = params.key ?? 1;

      final List<TopicModel> items = useOnline
          ? await Get.find<MockRepositoryOnline>().getTopics(
              subject,
              page,
              params.loadSize,
            )
          : await Get.find<MockRepositoryOffline>().getTopics(
              subject,
              page,
              params.loadSize,
            );

      await onPageLoaded?.call(page);

      final bool hasNextPage =
          items.length == params.loadSize &&
          (subject.topicCount <= 0 ||
              page * params.loadSize < subject.topicCount);

      return LoadResult<int, TopicModel>.page(
        items: items,
        prevKey: page > 1 ? page - 1 : null,
        nextKey: hasNextPage ? page + 1 : null,
      );
    } on Exception catch (error, stackTrace) {
      log("Error : $error", error: error, stackTrace: stackTrace);

      return LoadResult<int, TopicModel>.error(error);
    }
  }
}

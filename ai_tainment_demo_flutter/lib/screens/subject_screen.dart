import "package:ai_tainment_demo_flutter/config/page_config.dart";
import "package:ai_tainment_demo_flutter/controllers/subject_controller.dart";
import "package:ai_tainment_demo_flutter/models/subject_model.dart";
import "package:ai_tainment_demo_flutter/models/topic_model.dart";
import "package:ai_tainment_demo_flutter/widgets/auto_scroll_item.dart";
import "package:ai_tainment_demo_flutter/widgets/common_states.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:super_paging/super_paging.dart";

class SubjectScreen extends GetView<SubjectController> {
  const SubjectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Subject Screen",
          style: TextStyle(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SafeArea(child: subjectPagerBidirectionalPagingListView()),
    );
  }

  Widget subjectPagerBidirectionalPagingListView() {
    final Pager<int, SubjectModel> subjectPager = controller.getSubjectPager();

    return BidirectionalPagingListView<int, SubjectModel>(
      pager: subjectPager,
      itemBuilder: (BuildContext context, int index) {
        final SubjectModel subject = subjectPager.items.elementAt(index);
        final int subjectPageIndex = (index ~/ config.pageSize) + 1;
        final int subjectItemIndex = index % config.pageSize;

        return AutoScrollItem(
          shouldScroll: controller.isLatestSubject(subject),
          child: Card.outlined(
            key: GlobalObjectKey(subject.subjectId),
            elevation: 0,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () async {
                await controller.navigation(
                  subject: subject,
                  subjectPageIndex: subjectPageIndex,
                  subjectItemIndex: subjectItemIndex,
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const SizedBox(width: 4.0),
                              Expanded(
                                child: Text(
                                  subject.subjectId,
                                  style: const TextStyle(),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 4.0),
                              Obx(() {
                                return Text(
                                  "${controller.countBySubjectId(subject)}",
                                  style: const TextStyle(fontSize: 10),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                );
                              }),
                              const SizedBox(width: 4.0),
                              Obx(() {
                                final int completed = controller
                                    .countBySubjectId(subject);
                                final int total = controller.topicCount(
                                  subject,
                                );

                                return Expanded(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Text(
                                        "${controller.getPercentage(subject)}%",
                                        style: const TextStyle(fontSize: 10),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 4.0),
                                      LinearProgressIndicator(
                                        value: total == 0
                                            ? 0.0
                                            : (completed / total).clamp(
                                                0.0,
                                                1.0,
                                              ),
                                      ),
                                    ],
                                  ),
                                );
                              }),
                              const SizedBox(width: 4.0),
                              Text(
                                "${subject.topicCount}",
                                style: const TextStyle(fontSize: 10),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(width: 16.0),
                              SizedBox(
                                height: 24,
                                width: 24,
                                child: IconButton.outlined(
                                  iconSize: 16,
                                  padding: EdgeInsets.zero,
                                  visualDensity: VisualDensity.compact,
                                  icon: const Icon(
                                    Icons.arrow_forward,
                                    size: 16,
                                  ),
                                  onPressed: () async {
                                    await controller.navigation(
                                      subject: subject,
                                      subjectPageIndex: subjectPageIndex,
                                      subjectItemIndex: subjectItemIndex,
                                    );
                                  },
                                ),
                              ),
                              const SizedBox(width: 4.0),
                            ],
                          ),
                          SizedBox(
                            height: kToolbarHeight - 12,
                            width: double.infinity,
                            child: topicPagerBidirectionalPagingListView(
                              subject,
                              subjectPageIndex: subjectPageIndex,
                              subjectItemIndex: subjectItemIndex,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
      loadingBuilder: loadingBuilder,
      emptyBuilder: emptyBuilder,
      errorBuilder: errorBuilder,
      prependStateBuilder: prependStateBuilder,
      appendStateBuilder: appendStateBuilder,
    );
  }

  Widget topicPagerBidirectionalPagingListView(
    SubjectModel subject, {
    required int subjectPageIndex,
    required int subjectItemIndex,
  }) {
    final Pager<int, TopicModel> topicPager = controller.topicPager(subject);

    return BidirectionalPagingListView<int, TopicModel>(
      pager: topicPager,
      scrollDirection: Axis.horizontal,
      itemBuilder: (BuildContext context, int index) {
        final TopicModel topic = topicPager.items.elementAt(index);

        return AutoScrollItem(
          shouldScroll: controller.isLatestTopic(subject, topic),
          child: Card.outlined(
            key: GlobalObjectKey(topic.topicId),
            elevation: 0,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () async {
                await controller.navigation(
                  subject: subject,
                  subjectPageIndex: subjectPageIndex,
                  subjectItemIndex: subjectItemIndex,
                );
              },
              child: Obx(() {
                return ChoiceChip(
                  elevation: 0,
                  selected: controller.countByTopicId(topic) > 0,
                  onSelected: (bool value) {},
                  label: Text(
                    topic.topicId,
                    style: const TextStyle(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }),
            ),
          ),
        );
      },
      loadingBuilder: loadingBuilder,
      emptyBuilder: emptyBuilder,
      errorBuilder: errorBuilder,
      prependStateBuilder: prependStateBuilder,
      appendStateBuilder: appendStateBuilder,
    );
  }
}

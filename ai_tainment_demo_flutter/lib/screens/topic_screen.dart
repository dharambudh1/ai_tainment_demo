import "package:ai_tainment_demo_flutter/config/page_config.dart";
import "package:ai_tainment_demo_flutter/controllers/topic_controller.dart";
import "package:ai_tainment_demo_flutter/models/topic_model.dart";
import "package:ai_tainment_demo_flutter/widgets/auto_scroll_item.dart";
import "package:ai_tainment_demo_flutter/widgets/common_states.dart";
import "package:flutter/material.dart";
import "package:get/get.dart";
import "package:super_paging/super_paging.dart";

class TopicScreen extends GetView<TopicController> {
  const TopicScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Obx(() {
          return Text(
            controller.subject.value.subjectTitle,
            style: const TextStyle(),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          );
        }),
      ),
      body: SafeArea(child: subjectPagerBidirectionalPagingListView()),
    );
  }

  Widget subjectPagerBidirectionalPagingListView() {
    final Pager<int, TopicModel> topicPager = controller.topicPager(
      controller.subject.value,
    );

    return BidirectionalPagingListView<int, TopicModel>(
      pager: topicPager,
      itemBuilder: (BuildContext context, int index) {
        final TopicModel topic = topicPager.items.elementAt(index);
        final int topicPageIndex = (index ~/ config.pageSize) + 1;
        final int topicItemIndex = index % config.pageSize;

        return AutoScrollItem(
          shouldScroll: controller.isLatestTopic(
            controller.subject.value,
            topic,
          ),
          child: Card.outlined(
            key: GlobalObjectKey(topic.topicId),
            elevation: 0,
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const SizedBox(width: 4.0),
                      Obx(() {
                        return Checkbox(
                          value: controller.exists(topic),
                          onChanged: (bool? value) async {
                            await controller.registerTap(
                              topicPageIndex: topicPageIndex,
                              topicItemIndex: topicItemIndex,
                              topic: topic,
                            );
                          },
                        );
                      }),
                      const SizedBox(width: 4.0),
                      Expanded(
                        child: Text(
                          topic.topicId,
                          style: const TextStyle(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4.0),
                    ],
                  ),
                ],
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
}

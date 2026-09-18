import "package:ai_tainment_demo_flutter/models/topic_model.dart";
import "package:flutter/foundation.dart";

@immutable
class SubjectModel {
  const SubjectModel({
    required this.subjectId,
    required this.subjectTitle,
    required this.topicCount,
    required this.topics,
  });

  const SubjectModel.empty()
    : subjectId = "",
      subjectTitle = "",
      topicCount = 0,
      topics = const <TopicModel>[];

  factory SubjectModel.fromJson(Map<String, dynamic> json) {
    return SubjectModel(
      subjectId: json["subjectId"] ?? "",
      subjectTitle: json["subjectTitle"] ?? "",
      topicCount: json["topicCount"] ?? 0,
      topics: json["topics"] != null
          ? List<TopicModel>.from(
              (json["topics"] as List<dynamic>).map((Object? item) {
                return TopicModel.fromJson(item! as Map<String, dynamic>);
              }),
            )
          : <TopicModel>[],
    );
  }

  final String subjectId;
  final String subjectTitle;
  final int topicCount;
  final List<TopicModel> topics;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "subjectId": subjectId,
      "subjectTitle": subjectTitle,
      "topicCount": topicCount,
      "topics": List<dynamic>.from(
        topics.map((TopicModel item) {
          return item.toJson();
        }),
      ),
    };
  }

  SubjectModel copyWith({
    String? subjectId,
    String? subjectTitle,
    int? topicCount,
    List<TopicModel>? topics,
  }) {
    return SubjectModel(
      subjectId: subjectId ?? this.subjectId,
      subjectTitle: subjectTitle ?? this.subjectTitle,
      topicCount: topicCount ?? this.topicCount,
      topics: topics ?? this.topics,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SubjectModel &&
            runtimeType == other.runtimeType &&
            subjectId == other.subjectId;
  }

  @override
  int get hashCode {
    return subjectId.hashCode;
  }
}

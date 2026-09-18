import "package:flutter/foundation.dart";

@immutable
class TopicModel {
  const TopicModel({required this.topicId, required this.topicTitle});

  const TopicModel.empty() : topicId = "", topicTitle = "";

  factory TopicModel.fromJson(Map<String, dynamic> json) {
    return TopicModel(
      topicId: json["topicId"] ?? "",
      topicTitle: json["topicTitle"] ?? "",
    );
  }

  final String topicId;
  final String topicTitle;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{"topicId": topicId, "topicTitle": topicTitle};
  }

  TopicModel copyWith({
    String? topicId,
    String? topicTitle,
    bool? isCompleted,
  }) {
    return TopicModel(
      topicId: topicId ?? this.topicId,
      topicTitle: topicTitle ?? this.topicTitle,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
      other is TopicModel &&
          runtimeType == other.runtimeType &&
          topicId == other.topicId;
  }

  @override
  int get hashCode {
    return topicId.hashCode;
  }
}

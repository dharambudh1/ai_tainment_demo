import "package:flutter/foundation.dart";

@immutable
class MemoryModel {
  const MemoryModel({
    required this.subjectPageIndex,
    required this.subjectItemIndex,
    required this.topicPageIndex,
    required this.topicItemIndex,
    required this.subjectId,
    required this.topicIds,
    required this.updated,
  });

  const MemoryModel.empty()
    : subjectPageIndex = 1,
      subjectItemIndex = 1,
      topicPageIndex = 1,
      topicItemIndex = 1,
      subjectId = "",
      topicIds = const <String>[],
      updated = "";

  factory MemoryModel.fromJson(Map<String, dynamic> json) {
    return MemoryModel(
      subjectPageIndex: json["subjectPageIndex"] ?? 1,
      subjectItemIndex: json["subjectItemIndex"] ?? 1,
      topicPageIndex: json["topicPageIndex"] ?? 1,
      topicItemIndex: json["topicItemIndex"] ?? 1,
      subjectId: json["subjectId"] as String? ?? "",
      topicIds: json["topicIds"] != null
          ? List<String>.from(json["topicIds"] as Iterable<dynamic>)
          : <String>[],
      updated: json["updated"] ?? "",
    );
  }

  final int subjectPageIndex;
  final int subjectItemIndex;
  final int topicPageIndex;
  final int topicItemIndex;
  final String subjectId;
  final List<String> topicIds;
  final String updated;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      "subjectPageIndex": subjectPageIndex,
      "subjectItemIndex": subjectItemIndex,
      "topicPageIndex": topicPageIndex,
      "topicItemIndex": topicItemIndex,
      "subjectId": subjectId,
      "topicIds": topicIds,
      "updated": updated,
    };
  }

  MemoryModel copyWith({
    int? subjectPageIndex,
    int? subjectItemIndex,
    int? topicPageIndex,
    int? topicItemIndex,
    String? subjectId,
    List<String>? topicIds,
    String? updated,
  }) {
    return MemoryModel(
      subjectPageIndex: subjectPageIndex ?? this.subjectPageIndex,
      subjectItemIndex: subjectItemIndex ?? this.subjectItemIndex,
      topicPageIndex: topicPageIndex ?? this.topicPageIndex,
      topicItemIndex: topicItemIndex ?? this.topicItemIndex,
      subjectId: subjectId ?? this.subjectId,
      topicIds: topicIds ?? this.topicIds,
      updated: updated ?? this.updated,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is MemoryModel &&
            runtimeType == other.runtimeType &&
            subjectId == other.subjectId;
  }

  @override
  int get hashCode {
    return subjectId.hashCode;
  }
}

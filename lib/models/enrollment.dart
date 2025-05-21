class Enrollment {
  final String id;
  final String userId;
  final String courseId;
  final Set<String> viewedMaterialIds;

  Enrollment({
    required this.id,
    required this.userId,
    required this.courseId,
    Set<String>? viewedMaterialIds,
  }) : viewedMaterialIds = viewedMaterialIds ?? {};

  int calculateCompletionRate(int totalCourseMaterials) {
    if (totalCourseMaterials == 0) return 0;
    return ((viewedMaterialIds.length / totalCourseMaterials) * 100).round();
  }

  factory Enrollment.fromJson(Map<String, dynamic> json) {
    return Enrollment(
      id: json['\$id'],
      userId: json['userId'],
      courseId: json['courseId'] ?? 'No courseId available',
      viewedMaterialIds: Set<String>.from(json['viewedMaterialIds'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
    'userId': userId,
    'courseId': courseId,
    'viewedMaterialIds': viewedMaterialIds.toList(),
  };

  Enrollment copyWith({
    String? id,
    String? userId,
    String? courseId,
    Set<String>? viewedMaterialIds,
  }) {
    return Enrollment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      courseId: courseId ?? this.courseId,
      viewedMaterialIds: viewedMaterialIds ?? this.viewedMaterialIds,
    );
  }
}
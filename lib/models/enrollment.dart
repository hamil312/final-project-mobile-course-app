class Enrollment {
  final String id;
  final String userId;
  final String courseId;

  Enrollment({required this.id, required this.userId, required this.courseId});

  factory Enrollment.fromJson(Map<String, dynamic> json) {
    return Enrollment(
      id: json['\$id'],
      userId: json['userId'],
      courseId: json['courseId'] ?? 'No courseId available',
    );
  }

  Enrollment copyWith({
    String? id,
    String? userId,
    String? courseId,
  }) {
    return Enrollment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      courseId: courseId ?? this.courseId,
    );
  }

  Map<String, dynamic> toJson() => {'userId': userId, 'courseId': courseId};
}

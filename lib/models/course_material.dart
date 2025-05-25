import 'package:hive/hive.dart';

part 'course_material.g.dart';

@HiveType(typeId: 2)
class CourseMaterial extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String title;
  @HiveField(2)
  final String url;
  @HiveField(3)
  final int sizeBytes;
  @HiveField(4)
  final String sectionId;

  CourseMaterial({
    required this.id,
    required this.title,
    required this.url,
    required this.sizeBytes,
    required this.sectionId,
  });

  factory CourseMaterial.fromJson(Map<String, dynamic> json) => CourseMaterial(
    id: json['\$id'],
    title: json['title'],
    url: json['url'],
    sizeBytes: json['sizeBytes'] ?? 0,
    sectionId: json['sectionId'],
  );

  CourseMaterial copyWith({
    String? id,
    String? title,
    String? url,
    int? sizeBytes,
    String? sectionId,
  }) {
    return CourseMaterial(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      sectionId: sectionId ?? this.sectionId,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'url': url,
    'sizeBytes': sizeBytes,
    'sectionId': sectionId,
  };
}
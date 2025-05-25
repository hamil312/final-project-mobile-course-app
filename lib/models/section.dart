import 'package:final_project/models/course_material.dart';
import 'package:hive/hive.dart';

part 'section.g.dart';

@HiveType(typeId: 1)
class Section extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String courseId;
  @HiveField(2)
  final String name;
  @HiveField(3)
  final String description;

  Section({
    required this.id,
    required this.courseId,
    required this.name,
    required this.description,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      id: json['\$id'],
      courseId: json['courseId'],
      name: json['name'],
      description: json['description'],
    );
  }

  Section copyWith({
    String? id,
    String? courseId,
    String? name,
    String? description,
    List<CourseMaterial>? materials,
  }) {
    return Section(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      name: name ?? this.name,
      description: description ?? this.description,
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'courseId': courseId,
  };
}
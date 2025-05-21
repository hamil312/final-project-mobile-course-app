import 'package:final_project/models/course_material.dart';

class Section {
  final String id;
  final String courseId;
  final String name;
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

  factory Section.fromMap(Map<String, dynamic> map) {
    return Section(
      id: map['id'],
      courseId: map['courseId'],
      name: map['name'],
      description: map['description'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'courseId': courseId,
      'name': name,
      'description': description,
    };
  }
}
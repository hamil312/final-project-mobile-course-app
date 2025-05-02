import 'package:final_project/models/course_material.dart';

class Section {
  final String id;
  final String courseId;
  final String name;
  final String description;
  final List<CourseMaterial> materials;

  Section({
    required this.id,
    required this.courseId,
    required this.name,
    required this.description,
    this.materials = const [],
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      id: json['\$id'],
      courseId: json['courseId'], // 👈 parseo
      name: json['name'],
      description: json['description'],
      materials: (json['materials'] as List<dynamic>? ?? [])
          .map((m) => CourseMaterial.fromJson(m))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'courseId': courseId, // 👈 incluir en creación
    'materials': materials.map((m) => m.toJson()).toList(),
  };
}
import 'package:final_project/models/section.dart';

class Course {
  final String id;
  final String name;
  final String description;
  final String? authorId;
  final List<String> themes;
  final List<Section> sections;

  Course({required this.id, required this.name, required this.authorId, required this.themes, required this.sections, required this.description});

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['\$id'],
      name: json['name'],
      description: json['description'] ?? 'No description available',
      authorId: json['authorId'],
      themes: List<String>.from(json['themes'] ?? []),
      sections: (json['sections'] as List<dynamic>? ?? [])
          .map((sectionJson) => Section.fromJson(sectionJson))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'authorId': authorId, 'description': description, 'themes': themes, 'sections': sections.map((section) => section.toJson()).toList()};
}

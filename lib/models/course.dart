import 'package:hive/hive.dart';
import 'section.dart';

part 'course.g.dart';

@HiveType(typeId: 0)
class Course extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final String description;
  @HiveField(3)
  final String? authorId;
  @HiveField(4)
  final List<String> themes;

  Course({required this.id, required this.name, required this.authorId, required this.themes, required this.description});

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['\$id'],
      name: json['name'],
      description: json['description'] ?? 'No description available',
      authorId: json['authorId'],
      themes: List<String>.from(json['themes'] ?? []),
    );
  }

  Course copyWith({
    String? id,
    String? name,
    String? description,
    String? authorId,
    List<String>? themes,
    List<Section>? sections,
  }) {
    return Course(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      authorId: authorId ?? this.authorId,
      themes: themes ?? this.themes,
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'authorId': authorId, 'description': description, 'themes': themes};
}

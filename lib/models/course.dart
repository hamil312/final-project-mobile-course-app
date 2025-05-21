import 'package:final_project/models/section.dart';

class Course {
  final String id;
  final String name;
  final String description;
  final String? authorId;
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

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      id: map['id'],
      name: map['name'],
      description: map['description'],
      authorId: map['authorId'],
      themes: List<String>.from(map['themes'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'authorId': authorId,
      'themes': themes,
    };
  }
}

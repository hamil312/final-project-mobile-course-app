class LocalCourse {
  final String id;
  final String name;
  final String description;
  final String? authorId;
  final String themes;

  LocalCourse({
    required this.id,
    required this.name,
    required this.description,
    required this.authorId,
    required this.themes,
  });

  factory LocalCourse.fromMap(Map<String, dynamic> map) => LocalCourse(
    id: map['id'],
    name: map['name'],
    description: map['description'],
    authorId: map['authorId'],
    themes: map['themes'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'description': description,
    'authorId': authorId,
    'themes': themes,
  };
}
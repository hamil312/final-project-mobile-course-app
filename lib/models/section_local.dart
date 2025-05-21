class LocalSection {
  final String id;
  final String courseId;
  final String name;
  final String description;

  LocalSection({
    required this.id,
    required this.courseId,
    required this.name,
    required this.description,
  });

  factory LocalSection.fromMap(Map<String, dynamic> map) => LocalSection(
    id: map['id'],
    courseId: map['courseId'],
    name: map['name'],
    description: map['description'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'courseId': courseId,
    'name': name,
    'description': description,
  };
}
class CourseMaterial {
  final String id;
  final String title;
  final String url;
  final int sizeBytes;
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
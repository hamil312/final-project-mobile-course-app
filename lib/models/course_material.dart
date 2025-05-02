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

  Map<String, dynamic> toJson() => {
    'title': title,
    'url': url,
    'sizeBytes': sizeBytes,
    'sectionId': sectionId,
  };
}
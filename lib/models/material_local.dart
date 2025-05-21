class LocalMaterial {
  final String id;
  final String title;
  final String url;
  final int sizeBytes;
  final String sectionId;

  LocalMaterial({
    required this.id,
    required this.title,
    required this.url,
    required this.sizeBytes,
    required this.sectionId,
  });

  factory LocalMaterial.fromMap(Map<String, dynamic> map) => LocalMaterial(
    id: map['id'],
    title: map['title'],
    url: map['url'],
    sizeBytes: map['sizeBytes'],
    sectionId: map['sectionId'],
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'url': url,
    'sizeBytes': sizeBytes,
    'sectionId': sectionId,
  };
}
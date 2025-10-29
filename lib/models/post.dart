class MediaModel {
  final String id;
  final String path;
  final String type; // 'image' | 'video'
  final String? title;
  final DateTime createdAt;

  MediaModel({
    required this.id,
    required this.path,
    required this.type,
    this.title,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'path': path,
    'type': type,
    'title': title,
    'createdAt': createdAt.toIso8601String(),
  };

  factory MediaModel.fromMap(Map<String, dynamic> m) => MediaModel(
    id: m['id'] as String,
    path: m['path'] as String,
    type: m['type'] as String,
    title: m['title'] as String?,
    createdAt: DateTime.parse(m['createdAt'] as String),
  );
}

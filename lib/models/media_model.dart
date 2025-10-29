class MediaModel {
  final String id;
  final String path;
  final String type; // 'image' hoặc 'video'
  final DateTime createdAt; // <- thêm property này

  MediaModel({
    required this.id,
    required this.path,
    required this.type,
    required this.createdAt, // <- bắt buộc khi tạo instance
  });

  // Nếu bạn muốn từ JSON
  factory MediaModel.fromJson(Map<String, dynamic> json) {
    return MediaModel(
      id: json['id'],
      path: json['path'],
      type: json['type'],
      createdAt: DateTime.parse(json['createdAt']), // parse từ String
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'path': path,
      'type': type,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String userId;
  final String username;
  final String userAvatarUrl;
  final String imageUrl; // URL ảnh hoặc video
  final String caption;
  final List<String> likes; // UID của người đã like
  final int commentCount;
  final DateTime createdAt;
  final bool isVideo; // Ảnh hay video

  const PostModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.userAvatarUrl,
    required this.imageUrl,
    required this.caption,
    required this.likes,
    required this.commentCount,
    required this.createdAt,
    this.isVideo = false,
  });

  /// ✅ Tạo PostModel từ Firestore Snapshot (an toàn null)
  factory PostModel.fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>? ?? {};

    return PostModel(
      id: snap.id,
      userId: (data['userId'] ?? '').toString(),
      username: (data['username'] ?? '').toString(),
      userAvatarUrl: (data['userAvatarUrl'] ?? '').toString(),
      imageUrl: (data['imageUrl'] ?? '').toString(),
      caption: (data['caption'] ?? '').toString(),
      likes: (data['likes'] is List)
          ? List<String>.from(data['likes'])
          : <String>[],
      commentCount: _parseIntSafe(data['commentCount']),
      createdAt: _parseDateSafe(data['createdAt']),
      isVideo: data['isVideo'] == true,
    );
  }

  /// ✅ Chuyển sang JSON để lưu Firestore
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'username': username,
      'userAvatarUrl': userAvatarUrl,
      'imageUrl': imageUrl,
      'caption': caption,
      'likes': likes,
      'commentCount': commentCount,
      'createdAt': FieldValue.serverTimestamp(),
      'isVideo': isVideo,
    };
  }

  /// 🔹 Hàm tiện ích parse số nguyên an toàn
  static int _parseIntSafe(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  /// 🔹 Hàm tiện ích parse ngày an toàn
  static DateTime _parseDateSafe(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return DateTime.now();
  }
}

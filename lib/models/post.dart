import 'package:cloud_firestore/cloud_firestore.dart';

class PostModel {
  final String id;
  final String userId;
  final String username;
  final String userAvatarUrl;
  final String imageUrl; // URL của ảnh/video
  final String caption;
  final List<String> likes; // Danh sách UID của người đã like
  final int commentCount;
  final DateTime createdAt;
  final bool isVideo; // Thêm trường này để biết là ảnh hay video

  PostModel({
    required this.id,
    required this.userId,
    required this.username,
    required this.userAvatarUrl,
    required this.imageUrl,
    required this.caption,
    required this.likes,
    required this.commentCount,
    required this.createdAt,
    this.isVideo = false, // Mặc định là ảnh
  });

  // Chuyển đổi từ Firestore snapshot sang PostModel
  factory PostModel.fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>;
    return PostModel(
      id: snap.id,
      userId: data['userId'] ?? '',
      username: data['username'] ?? '',
      userAvatarUrl: data['userAvatarUrl'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      caption: data['caption'] ?? '',
      likes: List<String>.from(data['likes'] ?? []),
      commentCount: data['commentCount'] ?? 0,
      createdAt: (data['createdAt'] as Timestamp? ?? Timestamp.now()).toDate(),
      isVideo: data['isVideo'] ?? false,
    );
  }

  // Chuyển đổi sang Map (để tạo bài đăng mới)
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
}


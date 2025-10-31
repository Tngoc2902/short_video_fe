import 'package:cloud_firestore/cloud_firestore.dart';

// Định nghĩa các loại thông báo
enum NotificationType {
  like,
  comment,
  follow,
}

class NotificationModel {
  final String id;
  final String userId; // ID của người nhận thông báo
  final String fromUserId; // ID của người thực hiện hành động (like, follow)
  final String fromUsername;
  final String fromUserAvatarUrl;
  final NotificationType type;
  final String? postId; // ID của bài đăng (nếu là like hoặc comment)
  final String? postImageUrl; // Ảnh thumbnail của bài đăng
  final String? commentText; // Nội dung bình luận (nếu là comment)
  final DateTime createdAt;
  bool isRead;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.fromUserId,
    required this.fromUsername,
    required this.fromUserAvatarUrl,
    required this.type,
    this.postId,
    this.postImageUrl,
    this.commentText,
    required this.createdAt,
    this.isRead = false,
  });

  // Chuyển đổi từ Firestore Snapshot
  factory NotificationModel.fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>? ?? {};

    // Chuyển đổi String từ DB sang Enum
    NotificationType type;
    switch (data['type']) {
      case 'like':
        type = NotificationType.like;
        break;
      case 'comment':
        type = NotificationType.comment;
        break;
      case 'follow':
        type = NotificationType.follow;
        break;
      default:
      // Mặc định hoặc xử lý lỗi
        type = NotificationType.follow;
    }

    return NotificationModel(
      id: snap.id,
      userId: data['userId'] ?? '',
      fromUserId: data['fromUserId'] ?? '',
      fromUsername: data['fromUsername'] ?? '',
      fromUserAvatarUrl: data['fromUserAvatarUrl'] ?? '',
      type: type,
      postId: data['postId'],
      postImageUrl: data['postImageUrl'],
      commentText: data['commentText'],
      createdAt: (data['createdAt'] as Timestamp? ?? Timestamp.now()).toDate(),
      isRead: data['isRead'] ?? false,
    );
  }

  // Chuyển đổi sang Map để ghi vào Firestore
  Map<String, dynamic> toJson() {
    // Chuyển đổi Enum sang String để lưu
    String typeString;
    switch (type) {
      case NotificationType.like:
        typeString = 'like';
        break;
      case NotificationType.comment:
        typeString = 'comment';
        break;
      case NotificationType.follow:
        typeString = 'follow';
        break;
    }

    return {
      'userId': userId,
      'fromUserId': fromUserId,
      'fromUsername': fromUsername,
      'fromUserAvatarUrl': fromUserAvatarUrl,
      'type': typeString,
      'postId': postId,
      'postImageUrl': postImageUrl,
      'commentText': commentText,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': isRead,
    };
  }
}

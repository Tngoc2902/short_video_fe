import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String username;
  final String email;
  final String? profilePicture;
  final String? bio;
  final List<String> followers; // Danh sách các UID
  final List<String> following; // Danh sách các UID

  final bool isFollowing; // (Trường này có thể không cần lưu trữ trong DB, mà nên tính toán)
  final String avatarUrl;
  final String status;
  final DateTime? createTime;
  final DateTime? updateTime;
  final String? nickname;
  final String? link;
  final String? gender;

  User({
    required this.id,
    required this.username,
    required this.email,
    this.profilePicture,
    this.bio,
    required this.followers, // Yêu cầu List<String>
    required this.following, // Yêu cầu List<String>
    required this.isFollowing,
    required this.avatarUrl,
    required this.status,
    this.createTime,
    this.updateTime,
    this.nickname,
    this.link,
    this.gender,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? json['uid'] ?? '', // Thêm uid để tương thích
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      profilePicture: json['profilePicture'],
      bio: json['bio'],

      // === THAY ĐỔI: Chuyển đổi List<dynamic> sang List<String> ===
      followers: List<String>.from(json['followers'] ?? []),
      following: List<String>.from(json['following'] ?? []),
      // === KẾT THÚC THAY ĐỔI ===

      isFollowing: json['isFollowing'] ?? false,
      avatarUrl: json['avatarUrl'] ?? '',
      status: json['status'] ?? 'ACTIVE',

      // Chuyển đổi Timestamp (từ Firestore) hoặc String
      createTime: (json['createTime'] is Timestamp)
          ? (json['createTime'] as Timestamp).toDate()
          : (json['createTime'] != null
          ? DateTime.tryParse(json['createTime'])
          : null),
      updateTime: (json['updateTime'] is Timestamp)
          ? (json['updateTime'] as Timestamp).toDate()
          : (json['updateTime'] != null
          ? DateTime.tryParse(json['updateTime'])
          : null),

      nickname: json['nickname'],
      link: json['link'],
      gender: json['gender'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': id, // Thêm uid để truy vấn dễ dàng
      'username': username,
      'email': email,
      'profilePicture': profilePicture,
      'bio': bio,
      'followers': followers, // Lưu List<String>
      'following': following, // Lưu List<String>
      'isFollowing': isFollowing,
      'avatarUrl': avatarUrl,
      'status': status,
      // Nên dùng FieldValue.serverTimestamp() khi tạo/cập nhật
      'createTime': createTime?.toIso8601String(),
      'updateTime': updateTime?.toIso8601String(),
      'nickname': nickname,
      'link': link,
      'gender': gender,
    };
  }
}


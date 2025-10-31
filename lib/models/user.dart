import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String username;
  final String email;
  final String? profilePicture;
  final String? bio;

  final List<String> followers; // Danh sách các UID
  final List<String> following; // Danh sách các UID

  final bool isFollowing;
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
    required this.followers,
    required this.following,
    required this.isFollowing,
    required this.avatarUrl,
    required this.status,
    this.createTime,
    this.updateTime,
    this.nickname,
    this.link,
    this.gender,
  });

  // === SỬA: Thêm factory 'fromSnapshot' ===
  /// Tạo User từ DocumentSnapshot (lấy cả doc.id)
  factory User.fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>? ?? {}; // An toàn null

    return User(
      id: snap.id, // <-- SỬA LỖI QUAN TRỌNG: Lấy ID từ snapshot
      username: data['username'] ?? '',
      email: data['email'] ?? '',
      profilePicture: data['profilePicture'],
      bio: data['bio'],
      followers: List<String>.from(data['followers'] ?? []),
      following: List<String>.from(data['following'] ?? []),
      isFollowing: data['isFollowing'] ?? false,
      avatarUrl: data['avatarUrl'] ?? '',
      status: data['status'] ?? 'ACTIVE',
      createTime: (data['createTime'] is Timestamp)
          ? (data['createTime'] as Timestamp).toDate()
          : (data['createTime'] != null
          ? DateTime.tryParse(data['createTime'])
          : null),
      updateTime: (data['updateTime'] is Timestamp)
          ? (data['updateTime'] as Timestamp).toDate()
          : (data['updateTime'] != null
          ? DateTime.tryParse(data['updateTime'])
          : null),
      nickname: data['nickname'],
      link: data['link'],
      gender: data['gender'],
    );
  }

  // fromJson dùng khi data đã có sẵn 'id' (ví dụ: từ API khác)
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? json['uid'] ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      profilePicture: json['profilePicture'],
      bio: json['bio'],
      followers: List<String>.from(json['followers'] ?? []),
      following: List<String>.from(json['following'] ?? []),
      isFollowing: json['isFollowing'] ?? false,
      avatarUrl: json['avatarUrl'] ?? '',
      status: json['status'] ?? 'ACTIVE',
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

  // toJson() để ghi lên Firestore (Đã chính xác)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': id,
      'username': username,
      'email': email,
      'profilePicture': profilePicture,
      'bio': bio,
      'followers': followers,
      'following': following,
      'isFollowing': isFollowing,
      'avatarUrl': avatarUrl,
      'status': status,
      'createTime': createTime,
      'updateTime': updateTime,
      'nickname': nickname,
      'link': link,
      'gender': gender,
    };
  }
}


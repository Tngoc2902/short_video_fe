// lib/models/tagged_user.dart

class TaggedUser {
  final String id;
  final String username;
  final String? nickname;
  final String? avatarUrl;

  TaggedUser({
    required this.id,
    required this.username,
    this.nickname,
    this.avatarUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'nickname': nickname,
      'avatarUrl': avatarUrl,
    };
  }

  factory TaggedUser.fromJson(Map<String, dynamic> json) {
    return TaggedUser(
      id: json['id'],
      username: json['username'],
      nickname: json['nickname'],
      avatarUrl: json['avatarUrl'],
    );
  }
}

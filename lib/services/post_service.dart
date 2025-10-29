// lib/models/post.dart

import '../models/post.dart';
import '../models/tagged_user.dart';

class Post {
  final String? id;
  final String? content;
  final String? location;
  final String optionView; // Public, Friends, OnlyMe
  final List<String>? hashtags;
  final List<TaggedUser>? tags;
  final DateTime createdAt;
  final String? audioUrl;

  Post({
    this.id,
    this.content,
    this.location,
    this.optionView = 'Public',
    this.hashtags,
    this.tags,
    required this.createdAt,
    this.audioUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'location': location,
      'optionView': optionView,
      'hashtags': hashtags,
      'tags': tags?.map((t) => t.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'audioUrl': audioUrl,
    };
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      content: json['content'],
      location: json['location'],
      optionView: json['optionView'] ?? 'Public',
      hashtags: json['hashtags'] != null ? List<String>.from(json['hashtags']) : null,
      tags: json['tags'] != null
          ? (json['tags'] as List).map((e) => TaggedUser.fromJson(e)).toList()
          : null,
      createdAt: DateTime.parse(json['createdAt']),
      audioUrl: json['audioUrl'],
    );
  }
}

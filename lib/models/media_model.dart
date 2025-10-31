import 'package:cloud_firestore/cloud_firestore.dart';

class MediaModel {
  final String id;
  final String mediaUrl;
  final String? mediaBase64;
  final String mediaType;
  final String caption;
  final List<String> hashtags;
  final List<String> tags;
  final String location;
  final String audioUrl;
  final String audioName;
  final String userId;
  final DateTime createdAt;

  MediaModel({
    required this.id,
    required this.mediaUrl,
    this.mediaBase64,
    required this.mediaType,
    required this.caption,
    required this.hashtags,
    required this.tags,
    required this.location,
    required this.audioUrl,
    required this.audioName,
    required this.userId,
    required this.createdAt,
  });

  factory MediaModel.fromJson(Map<String, dynamic> json, String id) {
    String fixedUrl = json['mediaUrl'] ?? '';

    return MediaModel(
      id: id,
      mediaUrl: fixedUrl,
      mediaBase64: json['mediaBase64'],
      mediaType: json['mediaType'] ?? 'image',
      caption: json['caption'] ?? '',
      hashtags: List<String>.from(json['hashtags'] ?? []),
      tags: List<String>.from(json['tags'] ?? []),
      location: json['location'] ?? '',
      audioUrl: json['audioUrl'] ?? '',
      audioName: json['audioName'] ?? '',
      userId: json['userId'] ?? '',
      createdAt: (json['createdAt'] is Timestamp)
          ? (json['createdAt'] as Timestamp).toDate()
          : DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'mediaUrl': mediaUrl,
      'mediaBase64': mediaBase64,
      'mediaType': mediaType,
      'caption': caption,
      'hashtags': hashtags,
      'tags': tags,
      'location': location,
      'audioUrl': audioUrl,
      'audioName': audioName,
      'userId': userId,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}

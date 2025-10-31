import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/media_model.dart';

class MediaProvider extends ChangeNotifier {
  final CollectionReference postsRef = FirebaseFirestore.instance.collection('posts');

  List<MediaModel> mediaList = [];
  bool isLoading = false;

  Future<void> fetchMedia() async {
    isLoading = true;
    notifyListeners();

    try {
      final snapshot = await postsRef.orderBy('createdAt', descending: true).get();
      mediaList = snapshot.docs.map((doc) => MediaModel.fromJson(doc.data() as Map<String, dynamic>, doc.id)).toList();
    } catch (e) {
      debugPrint('Fetch media error: $e');
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> deleteMedia(String id) async {
    try {
      await postsRef.doc(id).delete();
      mediaList.removeWhere((m) => m.id == id);
      notifyListeners();
    } catch (e) {
      debugPrint('Delete media error: $e');
    }
  }
}

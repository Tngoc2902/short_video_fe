import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/media_model.dart';

class MediaService {
  final CollectionReference _postsRef =
  FirebaseFirestore.instance.collection('posts');

  Future<List<MediaModel>> loadAll() async {
    try {
      final snapshot =
      await _postsRef.orderBy('createdAt', descending: true).get();
      print("✅ Loaded ${snapshot.docs.length} posts");
      return snapshot.docs
          .map((doc) =>
          MediaModel.fromJson(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      print("❌ Error loading posts: $e");
      return [];
    }
  }

  Future<void> add(MediaModel media) async {
    await _postsRef.add(media.toJson());
  }

  Future<void> delete(String id) async {
    await _postsRef.doc(id).delete();
  }
}

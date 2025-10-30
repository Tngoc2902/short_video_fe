import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuthPkg;
import 'package:firebase_storage/firebase_storage.dart';
import '../models/post.dart';
import '../models/user.dart';

class PostService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuthPkg.FirebaseAuth _auth = FirebaseAuthPkg.FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String? get _currentUserId => _auth.currentUser?.uid;

  // === HÀM TẢI FILE LÊN STORAGE  ===
  Future<String> _uploadFile(File file, String path) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = ref.putFile(file);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading file ($path): $e");
      throw Exception("File upload failed");
    }
  }

  // === HÀM TẠO BÀI ĐĂNG MỚI (Firebase) ===
  Future<void> createPost({
    required String caption,
    required File imageFile,
    required User currentUser,
    bool isVideo = false,
  }) async {
    if (_currentUserId == null) throw Exception('User not logged in');

    try {
      // 1. Tải file ảnh/video lên Firebase Storage
      String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
      String filePath = 'posts/$_currentUserId/$uniqueFileName';
      String downloadUrl = await _uploadFile(imageFile, filePath);

      // 2. Tạo đối tượng PostModel mới
      PostModel newPost = PostModel(
        id: '', // Firestore sẽ tự tạo ID
        userId: _currentUserId!,
        username: currentUser.username,
        userAvatarUrl: currentUser.avatarUrl,
        imageUrl: downloadUrl,
        caption: caption,
        likes: [],
        commentCount: 0,
        createdAt: DateTime.now(),
        isVideo: isVideo,
      );

      // 3. Lưu document vào Firestore
      // (Hàm toJson() trong PostModel sẽ dùng FieldValue.serverTimestamp())
      await _firestore.collection('posts').add(newPost.toJson());

    } catch (e) {
      print("Error creating post: $e");
      throw Exception("Failed to create post");
    }
  }


  // === HÀM LẤY BÀI ĐĂNG CỦA USER ===
  Future<List<PostModel>> getPostsForUser(String userId) async {
    if (userId.isEmpty) return [];
    try {
      final snapshot = await _firestore
          .collection('posts')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) => PostModel.fromSnapshot(doc)).toList();

    } catch (e) {
      print("Error getting posts for user $userId: $e");
      throw Exception("Failed to load user posts");
    }
  }

  // === HÀM LẤY FEED (CHO HOMESCREEN) ===
  Future<List<PostModel>> getFeedPosts({DocumentSnapshot? startAfter}) async {
    try {
      var query = _firestore
          .collection('posts')
          .orderBy('createdAt', descending: true)
          .limit(10);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final snapshot = await query.get();
      return snapshot.docs.map((doc) => PostModel.fromSnapshot(doc)).toList();
    } catch (e) {
      print("Error getting feed posts: $e");
      throw Exception("Failed to load feed");
    }
  }

  // === HÀM LIKE BÀI ĐĂNG ===
  Future<void> likePost(String postId) async {
    if (_currentUserId == null) throw Exception('User not logged in');
    try {
      await _firestore.collection('posts').doc(postId).update({
        'likes': FieldValue.arrayUnion([_currentUserId])
      });
    } catch (e) {
      print("Error liking post $postId: $e");
      throw Exception("Failed to like post");
    }
  }

  // === HÀM UNLIKE BÀI ĐĂNG ===
  Future<void> unlikePost(String postId) async {
    if (_currentUserId == null) throw Exception('User not logged in');
    try {
      await _firestore.collection('posts').doc(postId).update({
        'likes': FieldValue.arrayRemove([_currentUserId])
      });
    } catch (e) {
      print("Error unliking post $postId: $e");
      throw Exception("Failed to unlike post");
    }
  }

  // === HÀM XÓA BÀI ĐĂNG ===
  Future<void> deletePost(String postId) async {
    if (_currentUserId == null) throw Exception('User not logged in');
    try {
      // TODO: Cần xóa cả file trong Firebase Storage (phức tạp hơn)
      // Tạm thời chỉ xóa document trong Firestore
      await _firestore.collection('posts').doc(postId).delete();
    } catch (e) {
      print("Error deleting post $postId: $e");
      throw Exception("Failed to delete post");
    }
  }
}


import 'dart:io'; // Thêm File
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart'; // Thêm Storage
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;
import '../models/user.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance; // Thêm Storage

  // Lấy User ID hiện tại
  String? get _currentUserId => FirebaseAuth.FirebaseAuth.instance.currentUser?.uid;

  // Hàm tạo profile (Giữ nguyên)
  Future<void> createUserProfile(FirebaseAuth.User user, String username) async {
    final newUser = User(
      id: user.uid,
      username: username,
      email: user.email ?? '',
      followers: [],
      following: [],
      isFollowing: false,
      avatarUrl: '',
      status: 'ACTIVE',
    );
    var data = newUser.toJson();
    data['createTime'] = FieldValue.serverTimestamp();
    await _firestore.collection('users').doc(user.uid).set(data);
  }

  // Hàm kiểm tra username (Giữ nguyên)
  Future<bool> checkUsernameAvailability(String username) async {
    final result = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    return result.docs.isEmpty;
  }

  // Hàm search users (Giữ nguyên)
  Future<List<User>> searchUsers(String query) async {
    if (query.isEmpty) return [];
    final result = await _firestore
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: query)
        .where('username', isLessThanOrEqualTo: '$query\uf8ff')
        .limit(10)
        .get();
    return result.docs.map((doc) => User.fromJson(doc.data())).toList();
  }

  // Hàm lấy danh sách following (Giữ nguyên)
  Future<List<User>> getFollowingList(String userId) async {
    if (userId.isEmpty) return [];
    final userDoc = await _firestore.collection('users').doc(userId).get();
    if (!userDoc.exists) return [];
    final followingIds = List<String>.from(userDoc.data()?['following'] ?? []);
    if (followingIds.isEmpty) return [];
    final usersSnapshot = await _firestore
        .collection('users')
        .where(FieldPath.documentId, whereIn: followingIds)
        .get();
    return usersSnapshot.docs.map((doc) => User.fromJson(doc.data())).toList();
  }

  // Hàm lấy thông tin profile (Giữ nguyên)
  Future<User> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return User.fromJson(doc.data()!);
      } else {
        throw Exception('User not found in Firestore');
      }
    } catch (e) {
      print("Error getting user profile: $e");
      rethrow;
    }
  }

  // === HÀM MỚI: Tải Avatar lên Storage ===
  Future<String> uploadAvatar(File imageFile, String uid) async {
    try {
      String filePath = 'avatars/$uid/avatar.jpg';
      final ref = _storage.ref().child(filePath);
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading avatar: $e");
      throw Exception("Avatar upload failed");
    }
  }

  // === HÀM MỚI: Cập nhật thông tin Profile ===
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      // Thêm thời gian cập nhật
      data['updateTime'] = FieldValue.serverTimestamp();
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      print("Error updating user profile: $e");
      throw Exception("Profile update failed");
    }
  }
}


import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
// Đổi tên để tránh xung đột
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth ;
import '../models/user.dart'; // Import User model của bạn (từ Canvas)

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  String? get _currentUserId => FirebaseAuth.FirebaseAuth.instance.currentUser?.uid;

  // === TẠO PROFILE ===
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

  // === KIỂM TRA TÊN NGƯỜI DÙNG ===
  Future<bool> checkUsernameAvailability(String username) async {
    final result = await _firestore
        .collection('users')
        .where('username', isEqualTo: username)
        .limit(1)
        .get();
    return result.docs.isEmpty;
  }

  // === TÌM KIẾM NGƯỜI DÙNG (TẤT CẢ) ===
  Future<List<User>> searchUsers(String query) async {
    if (query.isEmpty) return [];
    final result = await _firestore
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: query)
        .where('username', isLessThanOrEqualTo: '$query\uf8ff')
        .limit(10)
        .get();
    // Dùng fromSnapshot để lấy doc.id
    return result.docs.map((doc) => User.fromSnapshot(doc)).toList();
  }

  // === LẤY DANH SÁCH ĐANG THEO DÕI ===
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
    // Dùng fromSnapshot để lấy doc.id
    return usersSnapshot.docs.map((doc) => User.fromSnapshot(doc)).toList();
  }

  // === TÌM KIẾM TRONG DANH SÁCH FOLLOWING ===
  Future<List<User>> searchFollowing(String userId, String query) async {
    if (userId.isEmpty) return [];
    // Lấy danh sách đầy đủ
    final followingList = await getFollowingList(userId);

    // Nếu không có query, trả về tất cả
    if (query.isEmpty) return followingList;

    // Nếu có query, lọc danh sách
    final lowerQuery = query.toLowerCase();
    return followingList
        .where((u) =>
    u.username.toLowerCase().contains(lowerQuery) ||
        (u.nickname?.toLowerCase().contains(lowerQuery) ?? false))
        .toList();
  }

  // === LẤY PROFILE NGƯỜI DÙNG ===
  Future<User> getUserProfile(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    if (!doc.exists) throw Exception('User not found');
    // Dùng fromSnapshot để lấy doc.id
    return User.fromSnapshot(doc);
  }

  // === UPLOAD ẢNH ĐẠI DIỆN ===
  Future<String> uploadAvatar(File imageFile, String uid) async {
    try {
      final ref = _storage.ref().child('avatars/$uid/avatar.jpg');
      final uploadTask = ref.putFile(imageFile);
      final snapshot = await uploadTask;
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      print("Error uploading avatar: $e");
      throw Exception("Avatar upload failed");
    }
  }

  // === CẬP NHẬT THÔNG TIN NGƯỜI DÙNG ===
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      data['updateTime'] = FieldValue.serverTimestamp();
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      print("Error updating profile: $e");
      throw Exception("Profile update failed");
    }
  }

  // === HÀM THEO DÕI USER ===
  Future<void> followUser(String otherUserId) async {
    final currentUserId = _currentUserId;
    if (currentUserId == null) throw Exception("User not logged in");
    if (currentUserId == otherUserId) throw Exception("Cannot follow yourself");

    final currentUserRef = _firestore.collection('users').doc(currentUserId);
    final otherUserRef = _firestore.collection('users').doc(otherUserId);
    final batch = _firestore.batch();

    // 1. Thêm otherUserId vào danh sách 'following' của currentUser
    batch.update(currentUserRef, {
      'following': FieldValue.arrayUnion([otherUserId])
    });

    // 2. Thêm currentUserId vào danh sách 'followers' của otherUser
    batch.update(otherUserRef, {
      'followers': FieldValue.arrayUnion([currentUserId])
    });

    await batch.commit();
  }

  // === HÀM BỎ THEO DÕI USER ===
  Future<void> unfollowUser(String otherUserId) async {
    final currentUserId = _currentUserId;
    if (currentUserId == null) throw Exception("User not logged in");

    final currentUserRef = _firestore.collection('users').doc(currentUserId);
    final otherUserRef = _firestore.collection('users').doc(otherUserId);
    final batch = _firestore.batch();

    // 1. Xóa otherUserId khỏi 'following' của currentUser
    batch.update(currentUserRef, {
      'following': FieldValue.arrayRemove([otherUserId])
    });

    // 2. Xóa currentUserId khỏi 'followers' của otherUser
    batch.update(otherUserRef, {
      'followers': FieldValue.arrayRemove([currentUserId])
    });

    await batch.commit();
  }
}


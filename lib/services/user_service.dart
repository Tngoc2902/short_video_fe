import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserService {
  // Tham chiếu đến Cloud Firestore
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. Tạo hồ sơ người dùng trong Firestore
  //    Hàm này được gọi bởi AuthProvider NGAY SAU KHI đăng ký thành công
  Future<void> createUserProfile(User user, String username) async {
    try {
      // Tạo một document mới trong collection 'users'
      // với ID là ID của người dùng (user.uid)
      await _db.collection('users').doc(user.uid).set({
        'username': username,
        'email': user.email,
        'createdAt': FieldValue.serverTimestamp(),
        // Bạn có thể thêm các trường khác ở đây, ví dụ:
        // 'avatarUrl': 'url_avatar_mac_dinh',
        // 'bio': ''
      });
    } catch (e) {
      throw Exception('Failed to create user profile: ${e.toString()}');
    }
  }

  // 2. Kiểm tra xem username đã tồn tại chưa
  //    Hàm này được gọi bởi AuthProvider khi người dùng gõ username
  Future<bool> checkUsernameAvailability(String username) async {
    try {
      // Tìm kiếm trong collection 'users' xem có doc nào có username này không
      final result = await _db
          .collection('users')
          .where('username', isEqualTo: username)
          .limit(1)
          .get();

      // Nếu kết quả tìm kiếm là trống (không có docs nào),
      // có nghĩa là username CÓ SẴN (available)
      return result.docs.isEmpty;
    } catch (e) {
      // Nếu có lỗi, an toàn nhất là trả về 'false' (không có sẵn)
      // để tránh tạo trùng lặp
      print('Error checking username: $e');
      return false;
    }
  }
}


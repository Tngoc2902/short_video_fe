import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // 1. Khai báo biến
  final FirebaseAuth _firebaseAuth;

  // 2. Hàm khởi tạo (Constructor) - Đã sửa lỗi
  AuthService(this._firebaseAuth);

  // 3. Stream để lắng nghe trạng thái đăng nhập
  // AuthProvider sẽ lắng nghe stream này.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // 4. Lấy User hiện tại (nếu có)
  User? get currentUser => _firebaseAuth.currentUser;

  // 5. Đăng nhập bằng Email và Password
  Future<UserCredential> signIn(String email, String password) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      // Ném ra (throw) lỗi để AuthProvider có thể bắt và hiển thị
      throw Exception(e.message ?? 'Login failed. Please check your credentials.');
    } catch (e) {
      throw Exception('An unknown error occurred during login.');
    }
  }

  // 6. Đăng ký bằng Email và Password
  Future<UserCredential> signUp(String email, String password) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? 'Sign up failed. Please try again.');
    } catch (e) {
      throw Exception('An unknown error occurred during sign up.');
    }
  }

  // 7. Đăng xuất
  Future<void> signOut() async {
    // Không cần try/catch ở đây, signOut của Firebase hiếm khi lỗi
    // và AuthProvider sẽ tự động cập nhật qua stream
    await _firebaseAuth.signOut();
  }
}


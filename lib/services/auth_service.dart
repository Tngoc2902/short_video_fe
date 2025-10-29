import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  AuthService(FirebaseAuth instance);

  // 1. Stream để lắng nghe trạng thái đăng nhập
  // Đây là "nguồn chân lý" (source of truth) cho việc người dùng đã đăng nhập hay chưa.
  // AuthProvider sẽ lắng nghe stream này.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // 2. Lấy User hiện tại (nếu có)
  User? get currentUser => _firebaseAuth.currentUser;

  // 3. Đăng nhập bằng Email và Password
  Future<UserCredential> signIn(String email, String password) async {
    try {
      return await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      // Ném ra (throw) lỗi để AuthProvider có thể bắt và hiển thị
      // Ví dụ: "user-not-found", "wrong-password"
      throw Exception(e.message);
    }
  }

  // 4. Đăng ký bằng Email và Password
  Future<UserCredential> signUp(String email, String password) async {
    try {
      return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      // Ví dụ: "email-already-in-use", "weak-password"
      throw Exception(e.message);
    }
  }

  // 5. Đăng xuất
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}


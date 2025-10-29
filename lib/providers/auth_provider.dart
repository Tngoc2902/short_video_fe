import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:short_video_fe/services/auth_service.dart';
import 'package:short_video_fe/services/user_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  final UserService _userService;

  User? _user;
  bool _isLoading = true;
  String? _error;
  bool _isUsernameAvailable = true; // Biến mà tệp SignUpScreen đang tìm

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isUsernameAvailable => _isUsernameAvailable;

  AuthProvider(this._authService, this._userService) {
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  // Lắng nghe stream thay đổi trạng thái của Firebase
  Future<void> _onAuthStateChanged(User? user) async {
    _user = user;
    if (_isLoading) {
      _isLoading = false;
    }
    notifyListeners();
  }

  // Hàm đăng nhập
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _authService.signIn(email, password);
      return true;
    } on FirebaseAuthException catch (e) {
      _error = e.message ?? "An unknown error occurred.";
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Hàm đăng ký
  Future<bool> register(String email, String password, String username) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      // 1. Tạo tài khoản trong Firebase Auth
      UserCredential userCredential = await _authService.signUp(email, password);
      User? user = userCredential.user;

      if (user != null) {
        // 2. Lưu username vào Firestore
        await _userService.createUserProfile(user, username);
        return true;
      }
      _error = "Failed to create user.";
      return false;
    } on FirebaseAuthException catch (e) {
      _error = e.message ?? "An unknown error occurred.";
      return false;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Hàm đăng xuất
  Future<void> logout() async {
    await _authService.signOut();
  }

  // Hàm kiểm tra username
  Future<void> checkUsernameAvailability(String username) async {
    _isLoading = true; // Bạn có thể muốn một biến loading riêng
    notifyListeners();

    _isUsernameAvailable = await _userService.checkUsernameAvailability(username);

    _isLoading = false;
    notifyListeners();
  }

  // Xóa lỗi
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Đặt lỗi (dùng cho logic validation)
  void setError(String message) {
    _error = message;
    notifyListeners();
  }
}


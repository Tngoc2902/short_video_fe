import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:short_video_fe/services/auth_service.dart';
import 'package:short_video_fe/services/user_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  final UserService _userService;

  User? _user;
  // Bắt đầu với isLoading = true để chờ kiểm tra trạng thái đầu tiên
  bool _isLoading = true;
  String? _error;
  bool _isUsernameAvailable = true;
  bool _initialCheckDone = false; // Cờ để chỉ logout một lần khi khởi động

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isUsernameAvailable => _isUsernameAvailable;

  AuthProvider(this._authService, this._userService) {
    // Lắng nghe thay đổi trạng thái đăng nhập từ Firebase
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  // Lắng nghe stream thay đổi trạng thái của Firebase
  Future<void> _onAuthStateChanged(User? user) async {
    print('AuthProvider: _onAuthStateChanged called with user: ${user?.uid}'); // Debug

    // === THAY ĐỔI LOGIC: TỰ ĐỘNG LOGOUT KHI KHỞI ĐỘNG ===
    if (!_initialCheckDone) {
      _initialCheckDone = true; // Đánh dấu đã kiểm tra lần đầu
      if (user != null) {
        // Nếu Firebase nhớ user từ phiên trước, logout ngay lập tức
        print('AuthProvider: User found on initial check, logging out...'); // Debug
        await _authService.signOut();
        // Sau khi signOut, stream sẽ phát ra giá trị null, hàm này sẽ được gọi lại
        _user = null; // Cập nhật user thành null ngay
        _isLoading = false; // Hoàn tất kiểm tra ban đầu
        notifyListeners();
        print('AuthProvider: Logout complete after initial check.'); // Debug
        return; // Dừng xử lý ở đây cho lần gọi này
      } else {
        // Nếu không có user nào được nhớ
        print('AuthProvider: No user found on initial check.'); // Debug
        _user = null;
      }
    } else {
      // Các lần thay đổi trạng thái sau (đăng nhập/đăng xuất bình thường)
      _user = user;
      print('AuthProvider: Subsequent auth state change, user: ${user?.uid}'); // Debug
    }
    // === KẾT THÚC THAY ĐỔI LOGIC ===

    // Chỉ cập nhật isLoading = false sau lần kiểm tra đầu tiên
    if (_isLoading) {
      _isLoading = false;
    }

    print('AuthProvider: Notifying listeners (isLoading: $_isLoading, user: ${_user?.uid})'); // Debug
    notifyListeners();
  }


  // --- Các hàm còn lại giữ nguyên ---

  // Hàm đăng nhập
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _authService.signIn(email, password);
      // Không cần set _user ở đây, _onAuthStateChanged sẽ xử lý
      return true;
    } on FirebaseAuthException catch (e) {
      _error = e.message ?? "An unknown error occurred.";
      _isLoading = false; // Đặt lại isLoading khi có lỗi
      notifyListeners(); // Thông báo lỗi và dừng loading
      return false;
    } catch (e) { // Bắt các lỗi khác
      _error = "An unexpected error occurred during login.";
      _isLoading = false;
      notifyListeners();
      return false;
    }
    // Không cần finally ở đây nữa vì đã xử lý isLoading trong catch
  }

  // Hàm đăng ký
  Future<bool> register(String email, String password, String username) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      UserCredential userCredential = await _authService.signUp(email, password);
      User? newUser = userCredential.user;

      if (newUser != null) {
        await _userService.createUserProfile(newUser, username);
        // Không cần set _user ở đây, _onAuthStateChanged sẽ xử lý
        return true;
      }
      _error = "Failed to create user.";
      _isLoading = false; // Đặt lại isLoading khi có lỗi
      notifyListeners(); // Thông báo lỗi và dừng loading
      return false;
    } on FirebaseAuthException catch (e) {
      _error = e.message ?? "An unknown error occurred during registration.";
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _error = "An unexpected error occurred: ${e.toString()}";
      _isLoading = false;
      notifyListeners();
      return false;
    }
    // Không cần finally ở đây nữa
  }

  // Hàm đăng xuất
  Future<void> logout() async {
    // Không cần set isLoading ở đây, vì khi signOut thành công,
    // _onAuthStateChanged sẽ được gọi với user=null và tự cập nhật
    try {
      await _authService.signOut();
    } catch (e) {
      print("AuthProvider: Error during logout: $e");
      // Có thể muốn set lỗi ở đây nếu cần
      // _error = "Failed to log out.";
      // notifyListeners();
    }
  }

  // Hàm kiểm tra username
  Future<void> checkUsernameAvailability(String username) async {
    // Sử dụng biến loading riêng nếu không muốn ảnh hưởng isLoading chính
    // bool _checkingUsername = true;
    // notifyListeners();
    _error = null; // Xóa lỗi cũ trước khi kiểm tra

    try {
      _isUsernameAvailable = await _userService.checkUsernameAvailability(username);
    } catch (e) {
      print("AuthProvider: Error checking username: $e");
      _error = "Could not check username availability.";
      // Mặc định coi như không có sẵn để tránh lỗi đăng ký
      _isUsernameAvailable = false;
    } finally {
      // _checkingUsername = false;
      notifyListeners(); // Cập nhật trạng thái username và lỗi (nếu có)
    }

  }

  // Xóa lỗi
  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  // Đặt lỗi (dùng cho logic validation trong màn hình)
  void setError(String message) {
    _error = message;
    notifyListeners();
  }
}


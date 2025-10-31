import 'package:flutter/foundation.dart';
// SỬA: Import toàn bộ thư viện với bí danh 'FirebaseAuth'
import 'package:firebase_auth/firebase_auth.dart' as FirebaseAuth;
import 'package:short_video_fe/services/auth_service.dart';
import 'package:short_video_fe/services/user_service.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService;
  final UserService _userService;

  // Đây là user của Firebase Auth
  FirebaseAuth.User? _user;
  // === THÊM MỚI (Lỗi 1): Dữ liệu chi tiết của user từ Firestore ===
  User? _currentUserData;

  bool _isLoading = true;
  String? _error;
  bool _isUsernameAvailable = true;
  bool _initialCheckDone = false; // Cờ để chỉ logout một lần khi khởi động

  bool _isSearching = false;
  List<User> _searchResults = []; // Sử dụng 'User'

  FirebaseAuth.User? get user => _user;
  // === THÊM MỚI (Lỗi 1): Getter cho currentUserData ===
  User? get currentUserData => _currentUserData;

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isUsernameAvailable => _isUsernameAvailable;
  bool get isSearching => _isSearching;
  List<User> get searchResults => _searchResults; // Trả về List<User>

  AuthProvider(this._authService, this._userService) {
    // Lắng nghe thay đổi trạng thái đăng nhập từ Firebase
    _authService.authStateChanges.listen(_onAuthStateChanged);
  }

  // Lắng nghe stream thay đổi trạng thái của Firebase
  Future<void> _onAuthStateChanged(FirebaseAuth.User? user) async {
    print('AuthProvider: _onAuthStateChanged called with user: ${user?.uid}'); // Debug
    _user = user; // Cập nhật user của Firebase Auth

    // === SỬA (Lỗi 1): Tải hoặc xóa dữ liệu chi tiết ===
    if (_user != null) {
      // Nếu đăng nhập, tải thông tin chi tiết
      try {
        _currentUserData = await _userService.getUserProfile(_user!.uid);
      } catch (e) {
        _currentUserData = null;
        print("Error loading current user data: $e");
      }
    } else {
      // Nếu đăng xuất, xóa thông tin chi tiết
      _currentUserData = null;
    }
    // === KẾT THÚC SỬA ===

    // Logic tự động logout (Giữ nguyên)
    if (!_initialCheckDone) {
      _initialCheckDone = true; // Đánh dấu đã kiểm tra lần đầu
      if (user != null) {
        // Nếu Firebase nhớ user từ phiên trước, logout ngay lập tức
        print('AuthProvider: User found on initial check, logging out...'); // Debug
        await _authService.signOut();
        _user = null; // Cập nhật user thành null ngay
        _currentUserData = null; // SỬA: Xóa data
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
      _user = user;
      print('AuthProvider: Subsequent auth state change, user: ${user?.uid}'); // Debug
    }

    // Chỉ cập nhật isLoading = false sau lần kiểm tra đầu tiên
    if (_isLoading) {
      _isLoading = false;
    }

    print('AuthProvider: Notifying listeners (isLoading: $_isLoading, user: ${_user?.uid})'); // Debug
    notifyListeners();
  }


  // Hàm đăng nhập (Giữ nguyên)
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _authService.signIn(email, password);
      // _onAuthStateChanged sẽ tự động tải _currentUserData
      return true;
    } on FirebaseAuth.FirebaseAuthException catch (e) {
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
  }

  // Hàm đăng ký (Giữ nguyên)
  Future<bool> register(String email, String password, String username) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      FirebaseAuth.UserCredential userCredential = await _authService.signUp(email, password);
      FirebaseAuth.User? newUser = userCredential.user;

      if (newUser != null) {
        await _userService.createUserProfile(newUser, username);
        // SỬA: Tự động logout sau khi đăng ký (như logic của bạn)
        await _authService.signOut();
        return true;
      }
      _error = "Failed to create user.";
      _isLoading = false; // Đặt lại isLoading khi có lỗi
      notifyListeners(); // Thông báo lỗi và dừng loading
      return false;
    } on FirebaseAuth.FirebaseAuthException catch (e) {
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
  }

  // Hàm đăng xuất (Giữ nguyên)
  Future<void> logout() async {
    try {
      await _authService.signOut();
      // _onAuthStateChanged sẽ tự động xóa _currentUserData
    } catch (e) {
      print("AuthProvider: Error during logout: $e");
    }
  }

  // Hàm kiểm tra username (Giữ nguyên)
  Future<void> checkUsernameAvailability(String username) async {
    _error = null; // Xóa lỗi cũ trước khi kiểm tra
    try {
      _isUsernameAvailable = await _userService.checkUsernameAvailability(username);
    } catch (e) {
      print("AuthProvider: Error checking username: $e");
      _error = "Could not check username availability.";
      _isUsernameAvailable = false;
    } finally {
      notifyListeners(); // Cập nhật trạng thái username và lỗi (nếu có)
    }
  }

  // Hàm tìm kiếm user (Giữ nguyên)
  Future<void> searchUsers(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      _isSearching = false;
      notifyListeners();
      return;
    }
    _isSearching = true;
    _error = null; // Xóa lỗi cũ
    notifyListeners();
    try {
      // Gọi UserService (đã được sửa để trả về List<User>)
      _searchResults = await _userService.searchUsers(query);
    } catch (e) {
      _error = "Search failed: ${e.toString()}";
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  // Hàm xóa lỗi (Giữ nguyên)
  void clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  // Hàm đặt lỗi (Giữ nguyên)
  void setError(String message) {
    _error = message;
    notifyListeners();
  }

  // === THÊM MỚI (Lỗi 2): Hàm tải lại dữ liệu ===
  /// Tải lại dữ liệu người dùng (ví dụ: sau khi follow/unfollow)
  void refreshCurrentUserData() async {
    if (_user != null) { // Chỉ tải lại nếu đang đăng nhập
      try {
        _currentUserData = await _userService.getUserProfile(_user!.uid);
        notifyListeners(); // Thông báo cho UI (OtherUserProfileScreen)
      } catch (e) {
        print("Lỗi khi refresh CurrentUserData: $e");
        _error = "Failed to refresh user data";
        notifyListeners();
      }
    }
  }
}


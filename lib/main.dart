import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// SỬA LỖI: Thêm 'hide AuthProvider' để tránh xung đột tên
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'services/auth_service.dart';
import 'services/user_service.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
// import 'screens/home_screen.dart'; // ĐÃ XÓA
import 'theme/app_theme.dart';

// Khai báo một GlobalKey cho Navigator
// (Chúng ta đã xóa nó khỏi AuthService, nhưng để ở đây nếu bạn cần sau này)
// final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  // Đảm bảo Flutter đã được khởi tạo
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Khởi tạo các service
  final authService = AuthService(FirebaseAuth.instance);
  final userService = UserService(); // Đã xóa Firestore instance, vì nó được tạo bên trong

  runApp(
    // Sử dụng MultiProvider để cung cấp các service và provider cho toàn bộ ứng dụng
    MultiProvider(
      providers: [
        // Cung cấp AuthService
        Provider<AuthService>(
          create: (_) => authService,
        ),
        // Cung cấp UserService
        Provider<UserService>(
          create: (_) => userService,
        ),
        // AuthProvider sẽ lắng nghe AuthService
        ChangeNotifierProvider<AuthProvider>(
          // SỬA LỖI 1, 2, 3: Thay đổi thành tham số vị trí
          create: (context) => AuthProvider(
            context.read<AuthService>(),
            context.read<UserService>(),
          ),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Short Video App',
      // navigatorKey: navigatorKey, // Gán key nếu bạn cần truy cập từ bên ngoài
      theme: AppTheme.darkTheme, // Sử dụng theme tối chúng ta đã định nghĩa
      home: const AuthWrapper(), // Bắt đầu với AuthWrapper
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (img) => const SignUpScreen(),
        // '/home': (context) => const HomeScreen(), // ĐÃ XÓA
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

// AuthWrapper là một widget quan trọng
// Nó lắng nghe AuthProvider và quyết định hiển thị màn hình nào
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  // SỬA LỖI 4: Xóa 'async' và 'Future<Widget>', trả về 'Widget'
  Widget build(BuildContext context) {
    // Lấy trạng thái người dùng từ AuthProvider
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isLoading) {
      // Hiển thị màn hình loading khi đang kiểm tra trạng thái đăng nhập
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    } else if (authProvider.user != null) {
      // SỬA LỖI 5: Đã thay thế HomeScreen bằng một Scaffold tạm thời
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          title: const Text('Đã Đăng Nhập'),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
              onPressed: () {
                // Gọi hàm logout từ provider
                context.read<AuthProvider>().logout();
              },
            )
          ],
        ),
        body: const Center(
          child: Text('Bạn đã đăng nhập thành công!',
              style: TextStyle(color: Colors.white)),
        ),
      );
    } else {
      // Nếu chưa đăng nhập, hiển thị LoginScreen
      return const LoginScreen();
    }
  }
}


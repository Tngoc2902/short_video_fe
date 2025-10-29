import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/media_provider.dart'; // Đảm bảo import MediaProvider
import 'services/auth_service.dart';
import 'services/user_service.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/media_list_screen.dart'; // Thêm lại import MediaListScreen
// Xóa import MainScreen đơn giản nếu không dùng nữa
// import 'screens/home_screen.dart'; // Ví dụ
// import 'screens/search_screen.dart'; // Ví dụ
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Khởi tạo các service
  final authService = AuthService(FirebaseAuth.instance);
  final userService = UserService();

  runApp(
    MultiProvider(
      providers: [
        // Các provider cốt lõi
        Provider<AuthService>(create: (_) => authService),
        Provider<UserService>(create: (_) => userService),
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            context.read<AuthService>(),
            context.read<UserService>(),
          ),
        ),
        // === ĐẢM BẢO MEDIAPROVIDER ĐƯỢC CUNG CẤP ===
        ChangeNotifierProvider<MediaProvider>(
          create: (_) => MediaProvider()..loadMedia(), // Giả sử hàm loadMedia tồn tại
        ),
        // ===                                   ===
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
      theme: AppTheme.lightTheme, // Sử dụng theme sáng (hoặc tối tùy bạn)
      home: const AuthWrapper(), // Bắt đầu với AuthWrapper
      routes: {
        // Chỉ giữ lại route cần thiết cho luồng auth và màn hình chính
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/media': (context) => const MediaListScreen(), // Route cho màn hình chính
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

// AuthWrapper điều hướng đến MediaListScreen sau khi login
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black, // Hoặc màu nền của theme
        body: Center(child: CircularProgressIndicator()),
      );
    } else if (authProvider.user != null) {
      print("AuthWrapper: User is logged in, navigating to MediaListScreen.");
      // === THAY ĐỔI: Điều hướng đến MediaListScreen ===
      return const MediaListScreen();
      // ===                                     ===
    } else {
      print("AuthWrapper: User is not logged in, showing LoginScreen.");
      return const LoginScreen();
    }
  }
}


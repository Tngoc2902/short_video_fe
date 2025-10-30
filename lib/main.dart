import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;

import 'firebase_options.dart';
import 'providers/auth_provider.dart';
import 'providers/media_provider.dart';
import 'services/auth_service.dart';
import 'services/user_service.dart';
import 'screens/login_screen.dart';
import 'screens/search_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/media_list_screen.dart';
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
        ChangeNotifierProvider<MediaProvider>(
          create: (_) => MediaProvider()..loadMedia(),
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
      theme: AppTheme.lightTheme,
      home: const AuthWrapper(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/media': (context) => const MediaListScreen(),
        '/search': (context) => const SearchScreen(),
        // '/activity': (context) => const ActivityScreen(),
        '/profile': (context) => const ProfileScreen(),
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
      return const MediaListScreen();
    } else {
      print("AuthWrapper: User is not logged in, showing LoginScreen.");
      return const LoginScreen();
    }
  }
}


import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;

// Import các tệp Firebase
import 'firebase_options.dart';

// Import các Provider và Service cốt lõi của MVP
import 'providers/auth_provider.dart';
import 'providers/media_provider.dart';
import 'services/auth_service.dart';
import 'services/user_service.dart';
import 'services/post_service.dart'; // Service cho ProfileScreen

// Import các màn hình
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/media_list_screen.dart'; // Màn hình Home (Tab 1)
import 'screens/search_screen.dart';   // Màn hình Search (Tab 2)
import 'screens/create_post_screen.dart'; // Màn hình Create Post (Tab 3)
import 'screens/profile_screen.dart';   // Màn hình Profile (Tab 5)
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final authService = AuthService(FirebaseAuth.instance);
  final userService = UserService();
  final postService = PostService();

  runApp(
    MultiProvider(
      providers: [
        Provider<AuthService>(create: (_) => authService),
        Provider<UserService>(create: (_) => userService),
        Provider<PostService>(create: (_) => postService),
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
        '/home': (context) => const MainScreen(),
        '/media': (context) => const MediaListScreen(),
        '/search': (context) => const SearchScreen(),
        '/create_post': (context) => const CreatePostScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    if (authProvider.isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (authProvider.user != null) {
      return const MainScreen();
    } else {
      return const LoginScreen();
    }
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  // Fix lỗi: thêm placeholder cho Activity (index 3)
  final List<Widget> _screens = [
    const MediaListScreen(),    // Index 0: Home
    const SearchScreen(),       // Index 1: Search
    const SizedBox.shrink(),    // Index 2: nút Add
    const SizedBox.shrink(),    // Index 3: Activity placeholder
    const ProfileScreen(),      // Index 4: Profile
  ];

  void _onTabTapped(int index) {
    if (index == 2) {
      Navigator.pushNamed(context, '/create_post').then((result) {
        if (result == true) {
          print("Quay lại từ CreatePost. Cần refresh feed.");
        }
      });
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey[600],
        showSelectedLabels: false,
        showUnselectedLabels: false,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.add_box_outlined, size: 30), label: 'Add'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: 'Activity'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}

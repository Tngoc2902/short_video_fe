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
// import 'screens/main_screen.dart'; // Màn hình chính chứa BottomNav
import 'screens/media_list_screen.dart'; // Màn hình Home (Tab 1)
import 'screens/search_screen.dart';   // Màn hình Search (Tab 2)
import 'screens/create_post_screen.dart'; // Màn hình Create Post (Tab 3)
// import 'screens/activity_screen.dart';  // Màn hình Activity (Tab 4)
import 'screens/profile_screen.dart';   // Màn hình Profile (Tab 5)
import 'theme/app_theme.dart';

void main() async {
  // Đảm bảo Flutter đã được khởi tạo
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Khởi tạo các service
  final authService = AuthService(FirebaseAuth.instance);
  final userService = UserService();
  final postService = PostService();

  runApp(
    // Sử dụng MultiProvider để cung cấp các service và provider
    MultiProvider(
      providers: [
        // Cung cấp các service
        Provider<AuthService>(create: (_) => authService),
        Provider<UserService>(create: (_) => userService),
        Provider<PostService>(create: (_) => postService),

        // Cung cấp AuthProvider (phiên bản Firebase)
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            context.read<AuthService>(),
            context.read<UserService>(),
          ),
        ),

        // Cung cấp MediaProvider (cho tab Home)
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
      theme: AppTheme.lightTheme, // Sử dụng theme của bạn
      home: const AuthWrapper(), // Bắt đầu với AuthWrapper
      routes: {
        // Các route cơ bản
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/home': (context) => const MainScreen(),
        // Đảm bảo các route này khớp với các tệp màn hình của bạn
        '/media': (context) => const MediaListScreen(),
        '/search': (context) => const SearchScreen(),
        '/create_post': (context) => const CreatePostScreen(),
        // '/activity': (context) => const ActivityScreen(),
        '/profile': (context) => const ProfileScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}

// === Lớp AuthWrapper (Kiểm tra đăng nhập) ===
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // 1. Dùng authProvider.isLoading
    if (authProvider.isLoading) {
      print('AuthWrapper: Đang tải (kiểm tra trạng thái đăng nhập)...');
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    // 2. Dùng authProvider.user != null
    if (authProvider.user != null) {
      print('AuthWrapper: Đã đăng nhập, hiển thị MainScreen.');
      return const MainScreen(); // Đi đến Màn hình chính (có BottomNav)
    }
    // 3. Nếu user == null -> Hiển thị LoginScreen
    else {
      print('AuthWrapper: Chưa đăng nhập, hiển thị LoginScreen.');
      return const LoginScreen();
    }
  }
}

// === Lớp MainScreen (Với BottomNavigationBar 5 tab) ===
// (Đây là phiên bản đơn giản, không dùng CurvedNavigationBar)
class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0; // Tab hiện tại

  // Danh sách các màn hình (widget) cho các tab
  final List<Widget> _screens = [
    const MediaListScreen(),    // Index 0: Home (Màn hình chính của bạn)
    const SearchScreen(),       // Index 1: Search
    const SizedBox.shrink(),    // Index 2: Placeholder cho nút Add
    // const ActivityScreen(),     // Index 3: Activity (Trái tim)
    const ProfileScreen(),      // Index 4: Profile
  ];

  // Hàm xử lý khi nhấn vào một tab
  void _onTabTapped(int index) {
    // Xử lý riêng cho nút "Add" (index 2)
    if (index == 2) {
      // Mở màn hình CreatePostScreen dưới dạng một trang mới (Push)
      Navigator.pushNamed(context, '/create_post').then((result) {
        // (Tùy chọn) Xử lý khi quay lại từ CreatePostScreen
        if (result == true) {
          print("Quay lại từ CreatePost. Cần refresh feed.");
          // TODO: Gọi refresh cho provider của bạn
          // ví dụ: Provider.of<MediaProvider>(context, listen: false).loadMedia();
        }
      });
    } else {
      // Nếu không phải nút "Add", chỉ cần cập nhật index
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Nền đen
      body: _screens[_currentIndex], // Hiển thị màn hình của tab hiện tại
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed, // Đảm bảo 5 tab luôn hiển thị
        backgroundColor: Colors.white, // Nền trắng cho thanh nav
        selectedItemColor: Colors.black, // Icon được chọn màu đen
        unselectedItemColor: Colors.grey[600], // Icon chưa chọn màu xám
        showSelectedLabels: false, // Ẩn văn bản
        showUnselectedLabels: false, // Ẩn văn bản

        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined, size: 30), // Icon dấu +
            label: 'Add',
          ),
          BottomNavigationBarItem(
            // Sử dụng icon trái tim (như trong ảnh của bạn)
            icon: Icon(Icons.favorite_border),
            label: 'Activity',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'edit_profile_screen.dart'; // Màn hình edit
import '../services/user_service.dart';
import '../services/post_service.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart'; // Model User chi tiết
import '../models/post.dart'; // Model Post mới
import '../widgets/post_grid_view.dart';
import 'create_post_screen.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Dữ liệu sẽ được lấy từ Provider và Service
  User? _currentUser;
  List<PostModel> _userPosts = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Lấy dữ liệu ngay khi widget được tạo
    // Dùng addPostFrameCallback để đảm bảo Provider đã sẵn sàng
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadUserData();
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Lấy dữ liệu người dùng và bài đăng
  Future<void> _loadUserData() async {
    if (!mounted) return;

    // Lấy services từ Provider
    final userService = Provider.of<UserService>(context, listen: false);
    final postService = Provider.of<PostService>(context, listen: false);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final String? currentUid = authProvider.user?.uid;
    if (currentUid == null) {
      setState(() {
        _isLoading = false;
        _error = "User not logged in.";
      });
      return;
    }

    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      // 1. Lấy thông tin chi tiết người dùng (sử dụng User model)
      final userData = await userService.getUserProfile(currentUid);

      // 2. Lấy các bài đăng của người dùng (sử dụng PostModel)
      final posts = await postService.getPostsForUser(currentUid);

      if (!mounted) return;
      setState(() {
        _currentUser = userData;
        _userPosts = posts;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      print('Error loading user data: $e');
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  // Đăng xuất (thông qua AuthProvider)
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey[900],
          title: const Text('Đăng xuất', style: TextStyle(color: Colors.white)),
          content: const Text(
            'Bạn có chắc chắn muốn đăng xuất?',
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy', style: TextStyle(color: Colors.blue)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Đóng dialog
                // Gọi logout từ Provider
                Provider.of<AuthProvider>(context, listen: false).logout();
                // AuthWrapper sẽ tự động xử lý điều hướng
              },
              child: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Lỗi: $_error',
                style: const TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadUserData,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    if (_currentUser == null) {
      // Trường hợp này xảy ra nếu UID null hoặc không tìm thấy user
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.black),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Không thể tải thông tin người dùng.',
                style: TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    Provider.of<AuthProvider>(context, listen: false).logout(),
                child: const Text('Đăng nhập lại'),
              ),
            ],
          ),
        ),
      );
    }

    // Nếu đã tải xong
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title: Text(_currentUser!.username, // Tên người dùng trên AppBar
            style:
            const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_box_outlined, color: Colors.white),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => CreatePostScreen()));
            },
          ),
          IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: () {
              _showMenuOptions();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        color: Colors.white,
        backgroundColor: Colors.grey[900],
        // Dùng NestedScrollView để AppBar và Header cuộn cùng nhau
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              // Header chứa thông tin Profile
              SliverToBoxAdapter(
                child: _buildProfileHeader(),
              ),
              // Thanh TabBar
              SliverPersistentHeader(
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    controller: _tabController,
                    indicatorColor: Colors.white,
                    indicatorWeight: 1,
                    tabs: const [
                      Tab(icon: Icon(Icons.grid_on, color: Colors.white)),
                      Tab(
                          icon: Icon(Icons.person_pin_outlined,
                              color: Colors.white)),
                    ],
                  ),
                ),
                pinned: true, // Ghim TabBar khi cuộn
              ),
            ];
          },
          // Nội dung của TabBarView
          body: TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: Lưới bài đăng của người dùng
              PostGridView(
                posts: _userPosts,
                onTap: (post) {
                  // TODO: Điều hướng đến chi tiết bài đăng
                  print('Mở chi tiết bài đăng: ${post.id}');
                  // if (post.isVideo) {
                  //   Navigator.push(context, MaterialPageRoute(builder: (_) => FullScreenVideoScreen(post: post)));
                  // } else {
                  //   Navigator.push(context, MaterialPageRoute(builder: (_) => PostDetailScreen(postId: post.id)));
                  // }
                },
              ),
              // Tab 2: Lưới bài đăng được gắn thẻ (Placeholder)
              const Center(
                child: Text(
                  'Các bài đăng được gắn thẻ (Chưa có)',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget hiển thị thông tin header
  Widget _buildProfileHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 44,
                backgroundColor: Colors.grey[800],
                backgroundImage: _currentUser!.avatarUrl.isNotEmpty
                    ? NetworkImage(_currentUser!.avatarUrl)
                    : null,
                child: _currentUser!.avatarUrl.isEmpty
                    ? const Icon(Icons.person, size: 44, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 24),
              // Stats
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatColumn('Posts', _userPosts.length.toString()),
                    // === SỬA LỖI: Dùng .length ===
                    _buildStatColumn(
                        'Followers', _currentUser!.followers.length.toString()),
                    _buildStatColumn(
                        'Following', _currentUser!.following.length.toString()),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Nickname
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2),
          child: Text(
            _currentUser!.nickname ?? _currentUser!.username,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16),
          ),
        ),
        // Bio
        if (_currentUser!.bio != null && _currentUser!.bio!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2),
            child: Text(
              _currentUser!.bio!,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        // Link
        if (_currentUser!.link != null && _currentUser!.link!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 2),
            child: Text(
              _currentUser!.link!,
              style: const TextStyle(color: Colors.blueAccent),
            ),
          ),
        // Nút Edit Profile
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.grey),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                ).then((wasProfileUpdated) {
                  // Nếu quay lại và kết quả là true (đã cập nhật)
                  if (wasProfileUpdated == true) {
                    _loadUserData(); // Tải lại dữ liệu
                  }
                });
              },
              child: const Text('Edit Profile'),
            ),
          ),
        ),
        // const SizedBox(height: 10),
      ],
    );
  }

  // Widget hiển thị cột thống kê (Posts, Followers, ...)
  Widget _buildStatColumn(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(value,
            style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.white)),
      ],
    );
  }

  // Bottom sheet cho menu (Logout, v.v.)
  void _showMenuOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ListTile(
              //   leading: const Icon(Icons.settings, color: Colors.white),
              //   title: const Text('Settings', style: TextStyle(color: Colors.white)),
              //   onTap: () {
              //     Navigator.pop(context);
              //     // Navigate to settings
              //   },
              // ),
              ListTile(
                leading: const Icon(Icons.logout, color: Colors.red),
                title: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.pop(context); // Đóng bottom sheet
                  _showLogoutDialog(); // Hiển thị dialog xác nhận
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// Lớp helper để ghim TabBar
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.black, // Nền đen cho TabBar
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}


import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/user_service.dart';
import '../services/post_service.dart';
import '../providers/auth_provider.dart';
import '../models/user.dart';
import '../models/post.dart';
import '../widgets/post_grid_view.dart'; // Import widget từ Canvas

class OtherUserProfileScreen extends StatefulWidget {
  final String userId; // Nhận userId từ SearchScreen

  const OtherUserProfileScreen({Key? key, required this.userId})
      : super(key: key);

  @override
  _OtherUserProfileScreenState createState() => _OtherUserProfileScreenState();
}

class _OtherUserProfileScreenState extends State<OtherUserProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late UserService _userService;
  late PostService _postService;
  late AuthProvider _authProvider; // Lấy AuthProvider

  User? _profileUser; // Profile của người đang xem
  User? _currentUser;  // Profile của chính mình (để check follow)
  List<PostModel> _userPosts = [];
  bool _isLoading = true;
  String? _error;
  bool _isFollowing = false;
  bool _isFollowingMe = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Lấy các service và provider từ context
    _userService = Provider.of<UserService>(context, listen: false);
    _postService = Provider.of<PostService>(context, listen: false);
    _authProvider = Provider.of<AuthProvider>(context, listen: false);

    _loadUserData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final currentUserId = _authProvider.user?.uid;
      if (currentUserId == null) throw Exception("User not logged in");

      // 1. Lấy thông tin người dùng hiện tại (để check follow)
      // (Sử dụng data đã lưu trong AuthProvider)
      final currentUserData = _authProvider.currentUserData;
      if (currentUserData == null) {
        // Nếu chưa có, tải lại (dự phòng)
        _currentUser = await _userService.getUserProfile(currentUserId);
      } else {
        _currentUser = currentUserData;
      }

      // 2. Lấy thông tin profile của người đang xem
      final profileUserData = await _userService.getUserProfile(widget.userId);

      // 3. Lấy bài đăng của người đang xem
      final posts = await _postService.getPostsForUser(widget.userId);

      // 4. Kiểm tra trạng thái Follow
      final isFollowing = _currentUser!.following.contains(widget.userId);
      final isFollowingMe = profileUserData.following.contains(currentUserId);

      if (mounted) {
        setState(() {
          _profileUser = profileUserData;
          _userPosts = posts;
          _isFollowing = isFollowing;
          _isFollowingMe = isFollowingMe;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  // Logic Follow/Unfollow (Sử dụng hàm từ UserService)
  Future<void> _toggleFollow() async {
    if (_profileUser == null || _currentUser == null) return;

    final originalFollowingState = _isFollowing;

    // Cập nhật UI ngay lập tức
    setState(() {
      _isFollowing = !_isFollowing;
      // Cập nhật số lượng follower (UI)
      if (_isFollowing) {
        _profileUser!.followers.add(_currentUser!.id);
      } else {
        _profileUser!.followers.remove(_currentUser!.id);
      }
    });

    try {
      if (originalFollowingState) {
        // Nếu đang follow -> Unfollow
        await _userService.unfollowUser(_profileUser!.id);
      } else {
        // Nếu chưa follow -> Follow
        await _userService.followUser(_profileUser!.id);
      }
      // === CẬP NHẬT AUTHPROVIDER ===
      // Yêu cầu AuthProvider tải lại dữ liệu user của chính mình
      // để nó có danh sách 'following' mới nhất
      _authProvider.refreshCurrentUserData();

    } catch (e) {
      print('Error toggling follow: $e');
      // Hoàn tác lỗi
      setState(() {
        _isFollowing = originalFollowingState;
        if (_isFollowing) {
          _profileUser!.followers.add(_currentUser!.id);
        } else {
          _profileUser!.followers.remove(_currentUser!.id);
        }
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Hành động thất bại: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // (Các hàm UI helper: _getFollowButtonText, _getFollowButtonColor)
  String _getFollowButtonText(bool isFollowing) {
    if (isFollowing) {
      return 'Đang theo dõi';
    } else {
      return 'Theo dõi';
    }
  }

  Color _getFollowButtonColor(bool isFollowing) {
    if (isFollowing) {
      return Colors.grey[800]!;
    } else {
      return Colors.blue;
    }
  }

  Future<void> _goToMessageDetail() async {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Chức năng nhắn tin chưa được hỗ trợ')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(backgroundColor: Colors.black, iconTheme: const IconThemeData(color: Colors.white)),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Lỗi: $_error', style: const TextStyle(color: Colors.red)),
              ElevatedButton(
                  onPressed: _loadUserData, child: const Text('Thử lại')),
            ],
          ),
        ),
      );
    }

    if (_profileUser == null) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
            child:
            Text('Không tìm thấy người dùng', style: TextStyle(color: Colors.white))),
      );
    }

    // Giao diện chính
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        title:
        Text(_profileUser!.username, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: _loadUserData,
        color: Colors.white,
        backgroundColor: Colors.grey[900],
        child: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverToBoxAdapter(child: _buildProfileHeader()),
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                TabBar(
                  controller: _tabController,
                  indicatorColor: Colors.white,
                  tabs: const [
                    Tab(icon: Icon(Icons.grid_on, color: Colors.white)),
                    Tab(icon: Icon(Icons.person_pin_outlined, color: Colors.white)),
                  ],
                ),
              ),
              pinned: true,
            ),
          ],
          body: TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: Lưới bài đăng
              PostGridView(
                posts: _userPosts,
                onTap: (post) {
                  print('Mở chi tiết bài đăng: ${post.id}');
                },
              ),
              // Tab 2: Lưới bài đăng được gắn thẻ (Placeholder)
              const Center(
                child: Text(
                  'Các bài đăng được gắn thẻ (Chưa có)',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget hiển thị Header
  Widget _buildProfileHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              CircleAvatar(
                radius: 44,
                backgroundColor: Colors.grey[800],
                backgroundImage: _profileUser!.avatarUrl.isNotEmpty
                    ? NetworkImage(_profileUser!.avatarUrl)
                    : null,
                child: _profileUser!.avatarUrl.isEmpty
                    ? const Icon(Icons.person, size: 44, color: Colors.white)
                    : null,
              ),
              const SizedBox(width: 24),
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatColumn('Posts', _userPosts.length.toString()),
                    _buildStatColumn(
                        'Followers', _profileUser!.followers.length.toString()),
                    _buildStatColumn(
                        'Following', _profileUser!.following.length.toString()),
                  ],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            _profileUser!.nickname ?? _profileUser!.username,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        if (_profileUser!.bio != null && _profileUser!.bio!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
            child: Text(_profileUser!.bio!,
                style: const TextStyle(color: Colors.white)),
          ),

        // Nút Follow/Message
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _toggleFollow,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _getFollowButtonColor(_isFollowing),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                      _getFollowButtonText(_isFollowing)),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: _goToMessageDetail,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Nhắn tin'),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget _buildStatColumn
  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
        Text(label, style: const TextStyle(color: Colors.white70)),
      ],
    );
  }
}


// Lớp helper để ghim TabBar
class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;
  _SliverAppBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Colors.black, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) => false;
}


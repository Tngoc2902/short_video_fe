import 'package:flutter/material.dart';
import '../models/user.dart';

class TagFriendsScreen extends StatefulWidget {
  // Danh sách bạn bè đã được chọn ban đầu
  final List<User> initiallySelected;
  // Callback để trả về danh sách đã chọn (tùy chọn)
  final Function(List<User>)? onSelected;

  const TagFriendsScreen({
    super.key,
    this.initiallySelected = const [],
    this.onSelected,
  });

  @override
  State<TagFriendsScreen> createState() => _TagFriendsScreenState();
}

class _TagFriendsScreenState extends State<TagFriendsScreen> {
  late List<User> _friends; // Danh sách tất cả bạn bè/following
  late Set<User> _selectedFriends; // Dùng Set để quản lý việc chọn/bỏ chọn
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // Khởi tạo danh sách đã chọn từ widget.initiallySelected
    _selectedFriends = Set<User>.from(widget.initiallySelected);
    // Tải danh sách bạn bè
    _fetchFriends();
  }

  // Hàm tải danh sách bạn bè (Giả lập)
  Future<void> _fetchFriends() async {
    setState(() { _isLoading = true; });

    // === TẠO DỮ LIỆU GIẢ LẬP (MOCK DATA) ===
    // Dữ liệu giả lập này được tạo để khớp với User model
    // (hiện đang mở trên Canvas) có nhiều trường 'required'.
    // Trong ứng dụng thật, bạn sẽ tải danh sách này từ UserService/Firestore.
    await Future.delayed(const Duration(milliseconds: 500)); // Giả lập độ trễ mạng

    final List<User> mockFriends = List.generate(12, (i) => User(
      id: 'mock_id_${i+1}',
      username: 'friend_${i+1}',
      email: 'friend${i+1}@example.com',
      // === Cập nhật: Khớp với User model mới (List<String>) ===
      followers: List.generate(i * 2, (j) => 'follower_id_$j'), // Trường required (List<String>)
      following: List.generate(i + 1, (j) => 'following_id_$j'),  // Trường required (List<String>)
      // ===
      isFollowing: i % 2 == 0, // Trường required (bool)
      avatarUrl: 'https://placehold.co/100x100/E8D5C4/A98F7A?text=F${i+1}', // Trường required (String)
      status: 'ACTIVE', // Trường required (String)
      nickname: 'Friend ${i+1}', // Tùy chọn
      bio: 'This is a mock bio for friend ${i+1}', // Tùy chọn
    ));
    // === KẾT THÚC DỮ LIỆU GIẢ LẬP ===

    if (mounted) {
      setState(() {
        _friends = mockFriends;
        _isLoading = false;
      });
    }
  }

  // Xử lý khi nhấn chọn/bỏ chọn một người
  void _onToggleSelection(User user) {
    setState(() {
      // Dùng id để so sánh
      final existing = _selectedFriends.firstWhere((u) => u.id == user.id, orElse: () => user);

      if (_selectedFriends.contains(existing)) {
        _selectedFriends.removeWhere((u) => u.id == user.id);
      } else {
        _selectedFriends.add(user);
      }
    });
  }

  // Xử lý khi nhấn nút "Done"
  void _onDone() {
    final selectedList = _selectedFriends.toList();
    // 1. Gọi callback (nếu có)
    widget.onSelected?.call(selectedList);
    // 2. Quay lại màn hình trước và trả về danh sách đã chọn
    Navigator.of(context).pop(selectedList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Sử dụng nền tối
      appBar: AppBar(
        title: const Text('Tag Friends'),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white), // Nút back màu trắng
        actions: [
          // Nút "Done" để xác nhận
          TextButton(
            onPressed: _onDone,
            child: const Text(
              'Done',
              style: TextStyle(
                color: Colors.blueAccent,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: _friends.length,
        itemBuilder: (context, i) {
          final user = _friends[i];
          // Kiểm tra xem user đã được chọn chưa (dựa trên id)
          final isSelected = _selectedFriends.any((u) => u.id == user.id);

          // Sử dụng CheckboxListTile để dễ dàng chọn
          return CheckboxListTile(
            activeColor: Colors.blueAccent,
            checkColor: Colors.white,
            tileColor: Colors.black,
            title: Text(
              user.username,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              user.nickname ?? '(No nickname)',
              style: const TextStyle(color: Colors.grey),
            ),
            secondary: CircleAvatar(
              backgroundImage: user.avatarUrl.isNotEmpty ? NetworkImage(user.avatarUrl) : null,
              backgroundColor: Colors.grey[800],
            ),
            value: isSelected,
            onChanged: (bool? value) {
              _onToggleSelection(user);
            },
          );
        },
      ),
    );
  }
}


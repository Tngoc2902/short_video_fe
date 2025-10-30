import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../providers/auth_provider.dart';
// import '../models/user.dart';
// import 'profile_screen.dart';


class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  // Hàm xử lý khi gõ tìm kiếm
  void _onSearchChanged(String query) {
    // Hủy timer cũ (nếu có)
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
        // Gọi hàm search từ AuthProvider
        Provider.of<AuthProvider>(context, listen: false).searchUsers(query);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        // Thanh tìm kiếm
        title: Container(
          height: 40,
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: BorderRadius.circular(10),
          ),
          child: TextField(
            controller: _searchController,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Tìm kiếm người dùng...',
              hintStyle: TextStyle(color: Colors.white54),
              border: InputBorder.none,
              prefixIcon: Icon(Icons.search, color: Colors.white54),
            ),
            onChanged: _onSearchChanged, // Gọi hàm khi gõ
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // Ẩn bàn phím khi nhấn ra ngoài
        child: _buildSearchResults(), // Hiển thị kết quả
      ),
    );
  }

  // Widget hiển thị kết quả tìm kiếm
  Widget _buildSearchResults() {
    // Lắng nghe trạng thái searching và kết quả từ AuthProvider
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isSearching) {
          // Hiển thị loading khi đang tìm
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (authProvider.searchResults.isEmpty &&
            _searchController.text.isNotEmpty) {
          // Không tìm thấy kết quả
          return const Center(
            child: Text(
              'Không tìm thấy người dùng.',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        if (authProvider.searchResults.isEmpty &&
            _searchController.text.isEmpty) {
          // Màn hình trống ban đầu
          return const Center(
            child: Text(
              'Nhập tên người dùng để tìm kiếm.',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        // Hiển thị danh sách kết quả
        return ListView.builder(
          itemCount: authProvider.searchResults.length,
          itemBuilder: (context, index) {
            // 'user' ở đây sẽ là 'User' (từ user.dart)
            final user = authProvider.searchResults[index];

            return ListTile(
              leading: CircleAvatar(
                radius: 24,
                backgroundImage: user.avatarUrl.isNotEmpty
                    ? NetworkImage(user.avatarUrl)
                    : null,
                backgroundColor: Colors.grey[800],
                child: user.avatarUrl.isEmpty
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              title: Text(
                user.username,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                user.email, // Hiển thị email
                style: const TextStyle(color: Colors.grey),
              ),
              // onTap: () {
              //   // Điều hướng đến trang profile của người đó
              //   Navigator.push(
              //     // context,
              //     // MaterialPageRoute(
              //     //   // 'OtherUserProfileScreen' cũng phải chấp nhận 'User'
              //     //   // builder: (context) => OtherUserProfileScreen(user: user),
              //     // ),
              //   );
              // },
            );
          },
        );
      },
    );
  }
}


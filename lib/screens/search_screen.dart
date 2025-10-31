import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async'; // Cho Timer (debounce)
import '../providers/auth_provider.dart'; // Để gọi hàm search
import '../models/user.dart'; // Import 'User' model
import 'other_user_profile_screen.dart'; // Import màn hình profile

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

  // Hàm xử lý khi gõ tìm kiếm (Đã đúng)
  void _onSearchChanged(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (mounted) {
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
            onChanged: _onSearchChanged,
          ),
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: _buildSearchResults(),
      ),
    );
  }

  // Widget hiển thị kết quả tìm kiếm
  Widget _buildSearchResults() {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isSearching) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (authProvider.searchResults.isEmpty && _searchController.text.isNotEmpty) {
          return const Center(
            child: Text(
              'Không tìm thấy người dùng.',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        if (authProvider.searchResults.isEmpty && _searchController.text.isEmpty) {
          return const Center(
            child: Text(
              'Nhập tên người dùng để tìm kiếm.',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        return ListView.builder(
          itemCount: authProvider.searchResults.length,
          itemBuilder: (context, index) {
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
                user.nickname ?? user.email, // Hiển thị nickname hoặc email
                style: const TextStyle(color: Colors.grey),
              ),
              // === SỬA LỖI TẠI ĐÂY: Bỏ comment và thêm điều hướng ===
              onTap: () {
                // Ẩn bàn phím
                FocusScope.of(context).unfocus();
                // Điều hướng đến trang profile của người đó
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    // Truyền 'userId' (chứ không phải toàn bộ object 'user')
                    builder: (context) => OtherUserProfileScreen(userId: user.id),
                  ),
                );
              },
              // === KẾT THÚC SỬA LỖI ===
            );
          },
        );
      },
    );
  }
}


import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/media_provider.dart';
import '../components/media_tile.dart';
import '../models/media_model.dart';
import 'create_post_screen.dart';

class MediaListScreen extends StatefulWidget {
  const MediaListScreen({super.key});
  @override
  State<MediaListScreen> createState() => _MediaListScreenState();
}

class _MediaListScreenState extends State<MediaListScreen> {
  @override
  void initState() {
    super.initState();
    // Gọi loadMedia sau khi frame đầu tiên được build xong
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Kiểm tra xem widget còn tồn tại không trước khi gọi Provider
      if (mounted) {
        Provider.of<MediaProvider>(context, listen: false).loadMedia();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Lắng nghe thay đổi từ MediaProvider
    final provider = Provider.of<MediaProvider>(context);
    final items = provider.mediaList; // Lấy danh sách media

    return Scaffold(
      backgroundColor: Colors.black, // Nền tối
      appBar: AppBar(
        backgroundColor: Colors.black, // Màu nền AppBar
        title: const Text('Thư viện Media', style: TextStyle(color: Colors.white)),
        // Tự động thêm nút back nếu màn hình này không phải là màn hình đầu tiên
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: Colors.white), // Màu icon back
        actions: [
          // Nút để điều hướng đến CreatePostScreen
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            tooltip: 'Tạo bài đăng mới', // Thêm tooltip
            onPressed: () async {
              // Điều hướng đến CreatePostScreen và chờ kết quả
              final result = await Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CreatePostScreen()) // Đảm bảo CreatePostScreen tồn tại
              );
              // Nếu kết quả trả về là true (ví dụ: tạo bài thành công), load lại media
              if (result == true && mounted) {
                provider.loadMedia();
              }
            },
          ),
        ],
      ),
      body: _buildBody(provider, items), // Tách body ra hàm riêng cho dễ đọc
    );
  }

  // Hàm build phần body của Scaffold
  Widget _buildBody(MediaProvider provider, List<MediaModel> items) {
    if (provider.loading) {
      // Hiển thị loading indicator
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    } else if (items.isEmpty) {
      // Hiển thị thông báo khi không có media
      return const Center(
          child: Text('Chưa có media nào', style: TextStyle(color: Colors.white70))
      );
    } else {
      // Hiển thị GridView
      return Padding(
        padding: const EdgeInsets.all(12), // Padding xung quanh GridView
        child: GridView.builder(
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,       // 2 cột
            mainAxisSpacing: 12,     // Khoảng cách dọc
            crossAxisSpacing: 12,    // Khoảng cách ngang
            childAspectRatio: 0.8,   // Tỷ lệ W/H của mỗi item
          ),
          itemBuilder: (context, i) {
            final mediaItem = items[i];
            // Sử dụng MediaTile (đảm bảo bạn đã tạo widget này)
            return MediaTile(
              media: mediaItem,
              onDelete: () => _confirmDelete(context, mediaItem), // Hàm xóa
              onTap: () => _openDetail(context, mediaItem),      // Hàm xem chi tiết
            );
          },
        ),
      );
    }
  }

  // Hiển thị chi tiết media trong BottomSheet
  void _openDetail(BuildContext context, MediaModel media) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900], // Màu nền bottom sheet
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(12)) // Bo góc trên
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(16.0), // Padding bên trong bottom sheet
        child: Column(
            mainAxisSize: MainAxisSize.min, // Chỉ chiếm chiều cao cần thiết
            children: [
              // Hiển thị ảnh hoặc icon video
              if (media.type == 'image')
                Image.file(
                  File(media.path),
                  height: 200, // Giới hạn chiều cao ảnh
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.error, color: Colors.red, size: 80),
                )
              else // Giả sử type còn lại là 'video'
                Column(children: [
                  const Icon(Icons.videocam_rounded, color: Colors.white, size: 80),
                  const SizedBox(height: 8),
                  Text(
                    media.path.split(Platform.pathSeparator).last, // Lấy tên file
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  )
                ]),
              const SizedBox(height: 12),
              // Hiển thị ngày tạo
              Text(
                  'Created: ${media.createdAt}', // Đảm bảo format ngày tháng phù hợp
                  style: const TextStyle(color: Colors.white70)
              ),
              const SizedBox(height: 12),
              // Nút đóng bottom sheet
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              )
            ]
        ),
      ),
    );
  }

  // Hiển thị dialog xác nhận xóa
  void _confirmDelete(BuildContext context, MediaModel mediaItem) {
    // Lấy provider mà không cần listen vì chỉ gọi hàm
    final provider = Provider.of<MediaProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa media này không?'),
        actions: [
          // Nút Hủy
          TextButton(
              onPressed: () => Navigator.pop(context), // Đóng dialog
              child: const Text('Hủy')
          ),
          // Nút Xóa
          TextButton(
            onPressed: () {
              // Gọi hàm xóa từ provider
              provider.deleteMedia(mediaItem.id);
              Navigator.pop(context); // Đóng dialog sau khi xóa
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}


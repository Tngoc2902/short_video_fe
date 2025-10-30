import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/media_provider.dart';
import '../components/media_tile.dart';
import '../models/media_model.dart';
import 'create_post_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<MediaProvider>(context, listen: false).loadMedia();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MediaProvider>(context);
    final items = provider.mediaList;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Short Video',
          style: TextStyle(color: Colors.white),
        ),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            tooltip: 'Tạo bài đăng mới',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreatePostScreen()),
              );
              if (result == true && mounted) {
                provider.loadMedia();
              }
            },
          ),
        ],
      ),
      body: _buildBody(provider, items),
    );
  }

  Widget _buildBody(MediaProvider provider, List<MediaModel> items) {
    if (provider.loading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    } else if (items.isEmpty) {
      return const Center(
        child: Text(
          'Chưa có bài viết nào',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(12),
      child: GridView.builder(
        itemCount: items.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 0.8,
        ),
        itemBuilder: (context, i) {
          if (i < 0 || i >= items.length) return const SizedBox.shrink();
          final mediaItem = items[i];
          return MediaTile(
            media: mediaItem,
            onDelete: () => _confirmDelete(context, mediaItem),
            onTap: () => _openDetail(context, mediaItem),
          );
        },
      ),
    );
  }

  void _openDetail(BuildContext context, MediaModel media) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (_) => SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (media.type == 'image')
              Image.file(
                File(media.path),
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.error, color: Colors.red, size: 80),
              )
            else
              Column(
                children: [
                  const Icon(Icons.videocam_rounded,
                      color: Colors.white, size: 80),
                  const SizedBox(height: 8),
                  Text(
                    media.path.split(Platform.pathSeparator).last,
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            const SizedBox(height: 12),
            Text(
              'Created: ${media.createdAt}',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, MediaModel mediaItem) {
    final provider = Provider.of<MediaProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.grey[900],
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
        contentTextStyle: const TextStyle(color: Colors.white70),
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa bài viết này không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              provider.deleteMedia(mediaItem.id);
              Navigator.pop(context);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

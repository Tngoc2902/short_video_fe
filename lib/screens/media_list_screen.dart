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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<MediaProvider>(context, listen: false).loadMedia();
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
        title: const Text('Thư viện Media', style: TextStyle(color: Colors.white)),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () async {
              final r = await Navigator.push(context, MaterialPageRoute(builder: (_) => const CreatePostScreen()));
              if (r == true) provider.loadMedia();
            },
          ),
        ],
      ),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator())
          : items.isEmpty
          ? const Center(child: Text('Chưa có media nào', style: TextStyle(color: Colors.white70)))
          : Padding(
        padding: const EdgeInsets.all(12),
        child: GridView.builder(
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.8),
          itemBuilder: (context, i) {
            final m = items[i];
            return MediaTile(
              media: m,
              onDelete: () => _confirmDelete(context, m),
              onTap: () => _openDetail(context, m),
            );
          },
        ),
      ),
    );
  }

  void _openDetail(BuildContext context, MediaModel media) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey[900],
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(12))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          media.type == 'image' ? Image.file(File(media.path)) : Column(children: [const Icon(Icons.videocam, color: Colors.white, size: 80), const SizedBox(height: 8), Text(media.path.split('/').last, style: const TextStyle(color: Colors.white))]),
          const SizedBox(height: 12),
          Text('Created: ${media.createdAt}', style: const TextStyle(color: Colors.white70)),
        ]),
      ),
    );
  }

  void _confirmDelete(BuildContext context, MediaModel m) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xóa'),
        content: const Text('Bạn có muốn xóa media này?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
          TextButton(
            onPressed: () {
              Provider.of<MediaProvider>(context, listen: false).deleteMedia(m.id);
              Navigator.pop(context);
            },
            child: const Text('Xóa', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

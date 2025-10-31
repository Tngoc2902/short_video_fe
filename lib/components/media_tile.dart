import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/media_model.dart';

class MediaTile extends StatefulWidget {
  final MediaModel media;
  const MediaTile({super.key, required this.media});

  @override
  State<MediaTile> createState() => _MediaTileState();
}

class _MediaTileState extends State<MediaTile> {
  VideoPlayerController? _controller;
  bool _isVideoReady = false;

  @override
  void initState() {
    super.initState();

    // 🎥 Nếu là video, khởi tạo controller
    if (widget.media.mediaType == 'video' && widget.media.mediaUrl.isNotEmpty) {
      _controller = VideoPlayerController.network(widget.media.mediaUrl)
        ..initialize().then((_) {
          setState(() => _isVideoReady = true);
          _controller?.setLooping(true);
          _controller?.play();
        }).catchError((e) {
          debugPrint('⚠️ Lỗi khởi tạo video: $e');
        });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Widget _buildMediaWidget() {
    // 🎥 Nếu là video
    if (widget.media.mediaType == 'video') {
      if (_isVideoReady && _controller != null) {
        return AspectRatio(
          aspectRatio: _controller!.value.aspectRatio,
          child: VideoPlayer(_controller!),
        );
      } else {
        return const Center(child: CircularProgressIndicator());
      }
    }

    // 🖼️ Nếu là ảnh
    if (widget.media.mediaType == 'image') {
      if (widget.media.mediaUrl.isEmpty ||
          widget.media.mediaUrl.startsWith('file:///')) {
        // URL cục bộ hoặc rỗng → fallback ảnh lỗi
        return const Icon(Icons.broken_image, color: Colors.grey, size: 100);
      }
      return Image.network(
        widget.media.mediaUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
        const Icon(Icons.broken_image, color: Colors.grey, size: 100),
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return const Center(child: CircularProgressIndicator());
        },
      );
    }

    // ❌ Không xác định loại media
    return const Icon(Icons.help_outline, color: Colors.grey, size: 100);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🖼️ / 🎥 Media
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            child: AspectRatio(
              aspectRatio: (widget.media.mediaType == 'video' &&
                  _controller != null &&
                  _isVideoReady)
                  ? _controller!.value.aspectRatio
                  : 16 / 9,
              child: _buildMediaWidget(),
            ),
          ),

          // 📝 Thông tin
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Icon(Icons.person, color: Colors.purpleAccent, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(widget.media.userId,
                        style: const TextStyle(color: Colors.white70)),
                  ),
                ]),
                const SizedBox(height: 6),

                Row(children: [
                  const Icon(Icons.access_time,
                      color: Colors.lightBlueAccent, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    widget.media.createdAt.toString().substring(0, 19),
                    style: const TextStyle(color: Colors.white70),
                  ),
                ]),
                const SizedBox(height: 6),

                Row(children: [
                  const Icon(Icons.description,
                      color: Colors.blueAccent, size: 18),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(widget.media.caption,
                        style: const TextStyle(color: Colors.white)),
                  ),
                ]),
                const SizedBox(height: 6),

                if (widget.media.location.isNotEmpty)
                  Row(children: [
                    const Icon(Icons.location_on,
                        color: Colors.greenAccent, size: 18),
                    const SizedBox(width: 6),
                    Text(widget.media.location,
                        style: const TextStyle(color: Colors.white70)),
                  ]),
                const SizedBox(height: 6),

                if (widget.media.audioName.isNotEmpty)
                  Row(children: [
                    const Icon(Icons.music_note,
                        color: Colors.orangeAccent, size: 18),
                    const SizedBox(width: 6),
                    Text(widget.media.audioName,
                        style: const TextStyle(color: Colors.white70)),
                  ]),
                const SizedBox(height: 6),

                if (widget.media.hashtags.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    children: widget.media.hashtags
                        .map((tag) => Text(
                      '#$tag',
                      style:
                      const TextStyle(color: Colors.pinkAccent),
                    ))
                        .toList(),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

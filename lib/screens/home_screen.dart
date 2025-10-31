import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import '../providers/media_provider.dart';
import '../models/media_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Map<String, VideoPlayerController> _videoControllers = {};

  @override
  void initState() {
    super.initState();
    Provider.of<MediaProvider>(context, listen: false).fetchMedia();
  }

  @override
  void dispose() {
    for (var controller in _videoControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Widget _buildMedia(MediaModel media) {
    if (media.mediaType == 'video') {
      _videoControllers.putIfAbsent(
        media.id,
            () => VideoPlayerController.network(media.mediaUrl)
          ..initialize().then((_) => setState(() {}))
          ..setLooping(true),
      );

      final controller = _videoControllers[media.id]!;

      if (!controller.value.isInitialized) {
        return const SizedBox(
          height: 250,
          child: Center(child: CircularProgressIndicator(color: Colors.white)),
        );
      }

      return GestureDetector(
        onTap: () {
          setState(() {
            controller.value.isPlaying ? controller.pause() : controller.play();
          });
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            AspectRatio(
              aspectRatio: controller.value.aspectRatio,
              child: VideoPlayer(controller),
            ),
            if (!controller.value.isPlaying)
              const Icon(Icons.play_circle_fill, color: Colors.white70, size: 60),
          ],
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.network(
        media.mediaUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image,
            color: Colors.white54, size: 50),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<MediaProvider>(context);
    final mediaList = provider.mediaList;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text('ShortVideo',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: provider.loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : mediaList.isEmpty
          ? const Center(
        child: Text('Chưa có bài đăng nào',
            style: TextStyle(color: Colors.white70)),
      )
          : ListView.builder(
        itemCount: mediaList.length,
        itemBuilder: (context, index) {
          final media = mediaList[index];
          return Card(
            color: Colors.grey[900],
            margin:
            const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMedia(media),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      const Icon(Icons.access_time,
                          color: Colors.white54, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        media.createdAt.toString().substring(0, 19),
                        style:
                        const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                  if (media.caption.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.comment,
                            color: Colors.white54, size: 18),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(media.caption,
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 15)),
                        ),
                      ],
                    ),
                  ],
                  if (media.location.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.location_on,
                              color: Colors.white54, size: 18),
                          const SizedBox(width: 6),
                          Text(media.location,
                              style: const TextStyle(
                                  color: Colors.white70)),
                        ],
                      ),
                    ),
                  if (media.audioName.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.music_note,
                              color: Colors.white54, size: 18),
                          const SizedBox(width: 6),
                          Text(media.audioName,
                              style: const TextStyle(
                                  color: Colors.white70)),
                        ],
                      ),
                    ),
                  if (media.hashtags.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Wrap(
                        spacing: 6,
                        children: media.hashtags
                            .map((tag) => Text(
                          '#$tag',
                          style: const TextStyle(
                              color: Colors.blueAccent),
                        ))
                            .toList(),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

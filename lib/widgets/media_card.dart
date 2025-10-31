import 'package:flutter/material.dart';
import '../models/media_model.dart';
import 'video_player_widget.dart';

class MediaCard extends StatelessWidget {
  final MediaModel media;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const MediaCard({
    super.key,
    required this.media,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.grey[900],
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Media: image hoặc video
            if (media.mediaType == 'video')
              VideoPlayerWidget(url: media.mediaUrl)
            else
              Image.network(
                media.mediaUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(
                      child: CircularProgressIndicator(color: Colors.white));
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.broken_image,
                      size: 50, color: Colors.red);
                },
              ),

            const SizedBox(height: 8),

            // Caption
            Text(media.caption, style: const TextStyle(color: Colors.white)),

            const SizedBox(height: 4),

            // Hashtags
            if (media.hashtags.isNotEmpty)
              Text('Hashtags: ${media.hashtags.join(', ')}',
                  style: const TextStyle(color: Colors.blueAccent)),

            // Tags
            if (media.tags.isNotEmpty)
              Text('Tags: ${media.tags.join(', ')}',
                  style: const TextStyle(color: Colors.orangeAccent)),

            // Location
            if (media.location.isNotEmpty)
              Text('Location: ${media.location}',
                  style: const TextStyle(color: Colors.greenAccent)),

            // Audio
            if (media.audioName.isNotEmpty)
              Text('Audio: ${media.audioName}',
                  style: const TextStyle(color: Colors.purpleAccent)),

            // Thời gian đăng
            Text(
              'Posted: ${media.createdAt.toLocal()}',
              style: const TextStyle(color: Colors.grey, fontSize: 12),
            ),

            const SizedBox(height: 8),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onEdit != null)
                  TextButton(onPressed: onEdit, child: const Text('Edit')),
                if (onDelete != null)
                  TextButton(
                      onPressed: onDelete,
                      child: const Text('Delete',
                          style: TextStyle(color: Colors.red))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

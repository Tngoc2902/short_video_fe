import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../models/media_model.dart';

class MediaTile extends StatefulWidget {
  final MediaModel media;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const MediaTile({
    super.key,
    required this.media,
    this.onTap,
    this.onDelete,
  });

  @override
  State<MediaTile> createState() => _MediaTileState();
}

class _MediaTileState extends State<MediaTile> {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.media.mediaType == 'video') {
      _controller = VideoPlayerController.network(widget.media.mediaUrl)
        ..initialize().then((_) {
          setState(() {});
          _controller?.play();
          _controller?.setLooping(true);
        });
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget mediaWidget;
    if (widget.media.mediaType == 'video' && _controller != null && _controller!.value.isInitialized) {
      mediaWidget = AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: VideoPlayer(_controller!),
      );
    } else {
      mediaWidget = Image.network(widget.media.mediaUrl, fit: BoxFit.cover);
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        children: [
          Positioned.fill(child: mediaWidget),
          if (widget.onDelete != null)
            Positioned(
              top: 4,
              right: 4,
              child: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: widget.onDelete,
              ),
            ),
        ],
      ),
    );
  }
}

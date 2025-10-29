import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:video_player/video_player.dart';

class VideoEditorScreen extends StatefulWidget {
  final AssetEntity asset;
  const VideoEditorScreen({super.key, required this.asset});
  @override
  State<VideoEditorScreen> createState() => _VideoEditorScreenState();
}

class _VideoEditorScreenState extends State<VideoEditorScreen> {
  VideoPlayerController? _controller;
  @override
  void initState() {
    super.initState();
    widget.asset.file.then((f) {
      if (f != null) {
        _controller = VideoPlayerController.file(f)..initialize().then((_) => setState(() { _controller?.play(); }));
      }
    });
  }
  @override
  void dispose() { _controller?.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Video')),
      body: _controller == null || !_controller!.value.isInitialized ? const Center(child: CircularProgressIndicator()) : Column(children: [
        AspectRatio(aspectRatio: _controller!.value.aspectRatio, child: VideoPlayer(_controller!)),
        ElevatedButton(onPressed: () async { final file = await widget.asset.file; if (file != null) Navigator.of(context).pop(file.path); }, child: const Text('Use this video'))
      ]),
    );
  }
}

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:path_provider/path_provider.dart';
import '../models/audio.dart';
import '../models/user.dart';
import '../models/location.dart';
import 'select_location_screen.dart' hide LocationResult;
import 'select_audio_screen.dart';
import 'tag_friends_screen.dart';

class FinalizePostScreen extends StatefulWidget {
  final List<File>? selectedFiles;
  final dynamic editedMediaResult;

  const FinalizePostScreen({super.key, this.selectedFiles, this.editedMediaResult});

  @override
  State<FinalizePostScreen> createState() => _FinalizePostScreenState();
}

class _FinalizePostScreenState extends State<FinalizePostScreen> {
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _hashtagsController = TextEditingController();
  VideoPlayerController? _videoController;
  File? _editedFile;
  List<User> _taggedUsers = [];
  Audio? _selectedAudio;
  LocationResult? _selectedLocation;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _prepareMedia();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _prepareMedia() async {
    if (widget.editedMediaResult == null) return;
    final result = widget.editedMediaResult;
    if (result is Uint8List) {
      final temp = await getTemporaryDirectory();
      final path = '${temp.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      _editedFile = await File(path).writeAsBytes(result);
      setState(() {});
    } else if (result is String) {
      _editedFile = File(result);
      _videoController = VideoPlayerController.file(_editedFile!)
        ..initialize().then((_) {
          setState(() {});
          _videoController?.play();
          _videoController?.setLooping(true);
        });
    }
  }

  void _openTagFriends() async {
    final result = await Navigator.push<List<User>>(
      context,
      MaterialPageRoute(
        builder: (_) => TagFriendsScreen(
          initiallySelected: _taggedUsers,
          onSelected: (users) {},
        ),
      ),
    );
    if (result != null) setState(() => _taggedUsers = result);
  }

  void _openSelectAudio() async {
    final result = await Navigator.push<Audio>(
      context,
      MaterialPageRoute(
        builder: (_) => SelectAudioScreen(selected: _selectedAudio),
      ),
    );
    if (result != null) setState(() => _selectedAudio = result);
  }

  void _openSelectLocation() async {
    final result = await Navigator.push<LocationResult>(
      context,
      MaterialPageRoute(
        builder: (_) => SelectLocationScreen(selected: _selectedLocation),
      ),
    );
    if (result != null) setState(() => _selectedLocation = result);
  }

  Future<void> _sharePost() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1)); // simulate upload
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Post created'), backgroundColor: Colors.green));
      Navigator.pop(context, true);
    }
  }

  Widget _buildPreview() {
    if (_editedFile != null) {
      if (_videoController != null && _videoController!.value.isInitialized) {
        return AspectRatio(aspectRatio: _videoController!.value.aspectRatio, child: VideoPlayer(_videoController!));
      } else {
        return Image.file(_editedFile!, fit: BoxFit.cover);
      }
    } else if (widget.selectedFiles != null && widget.selectedFiles!.isNotEmpty) {
      final file = widget.selectedFiles!.first;
      if (file.path.toLowerCase().endsWith('.mp4')) {
        _videoController = VideoPlayerController.file(file)
          ..initialize().then((_) {
            setState(() {});
            _videoController?.play();
            _videoController?.setLooping(true);
          });
        return AspectRatio(aspectRatio: _videoController!.value.aspectRatio, child: VideoPlayer(_videoController!));
      } else {
        return Image.file(file, fit: BoxFit.cover);
      }
    }
    return Container(color: Colors.grey[800], child: const Center(child: Icon(Icons.image, color: Colors.white)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: Colors.white), onPressed: () => Navigator.pop(context)),
        title: const Text('New Post', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _sharePost,
            child: _isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Share', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              SizedBox(width: 64, height: 64, child: ClipRRect(borderRadius: BorderRadius.circular(12), child: _buildPreview())),
              const SizedBox(width: 12),
              Expanded(
                child: TextField(
                  controller: _captionController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 4,
                  decoration: const InputDecoration(
                    hintText: 'Write a caption...',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ]),
            const SizedBox(height: 8),
            Divider(color: Colors.white24, height: 24),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.alternate_email, color: Colors.white),
              title: const Text('Tag friends', style: TextStyle(color: Colors.white)),
              trailing: const Icon(Icons.chevron_right, color: Colors.white54),
              onTap: _openTagFriends,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.music_note, color: Colors.white),
              title: const Text('Add music', style: TextStyle(color: Colors.white)),
              trailing: const Icon(Icons.chevron_right, color: Colors.white54),
              onTap: _openSelectAudio,
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.location_on, color: Colors.white),
              title: const Text('Add location', style: TextStyle(color: Colors.white)),
              trailing: const Icon(Icons.chevron_right, color: Colors.white54),
              onTap: _openSelectLocation,
            ),
            Divider(color: Colors.white24, height: 24),
            TextField(
              controller: _hashtagsController,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Add hashtags (e.g. #fun)',
                hintStyle: TextStyle(color: Colors.grey),
                border: InputBorder.none,
                prefixIcon: Icon(Icons.tag, color: Colors.white54),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

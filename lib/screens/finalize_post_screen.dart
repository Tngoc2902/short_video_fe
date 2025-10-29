// simplified finalize_post_screen.dart — keeps functionality you provided
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'package:video_player/video_player.dart';
import 'package:file_picker/file_picker.dart';

// Placeholder models for audio/user/tagged - keep simple for now
class User { final String? id; final String username; final String? nickname; final String? avatarUrl; User({this.id,this.username='',this.nickname,this.avatarUrl}); }
class Audio { final String name; final String url; Audio({required this.name, required this.url}); }
class TaggedUser { final String id; final String username; TaggedUser({required this.id, required this.username}); }
class LocationResult { final String name; LocationResult({required this.name}); }

// If you have real PostService, swap this out.
class FinalizePostScreen extends StatefulWidget {
  final List<AssetEntity>? selectedAssets;
  final dynamic editedMediaResult;
  const FinalizePostScreen({super.key, this.selectedAssets, this.editedMediaResult});

  @override
  State<FinalizePostScreen> createState() => _FinalizePostScreenState();
}

class _FinalizePostScreenState extends State<FinalizePostScreen> {
  final TextEditingController _captionController = TextEditingController();
  final TextEditingController _hashtagsController = TextEditingController();
  String _selectedOptionView = 'Public';
  VideoPlayerController? _videoController;
  bool _isLoading = false;
  File? _editedFile;
  List<User> _taggedUsers = [];
  Audio? _selectedAudio;
  LocationResult? _selectedLocation;
  File? _audioFile;

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
      _videoController = VideoPlayerController.file(_editedFile!)..initialize().then((_) { setState((){}); _videoController?.play(); _videoController?.setLooping(true); });
    }
  }

  Future<File?> _convertResultToFile(dynamic result) async {
    if (result is Uint8List) {
      final tempDir = await getTemporaryDirectory();
      final path = '${tempDir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      return await File(path).writeAsBytes(result);
    } else if (result is String) {
      return File(result);
    }
    return null;
  }

  Future<void> _pickAudioFile() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _audioFile = File(result.files.single.path!);
        _selectedAudio = null;
      });
    }
  }

  Future<void> _sharePost() async {
    final hasMedia = widget.selectedAssets?.isNotEmpty == true || widget.editedMediaResult != null;
    if (!hasMedia) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No media file to post.')));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final hashtags = _hashtagsController.text.split(' ').where((s) => s.isNotEmpty).map((t) => t.startsWith('#') ? t.substring(1) : t).toList();
      List<File> images = [];
      List<File> videos = [];
      File? audioFile = _audioFile;
      String? audioUrl;
      if (_audioFile == null && _selectedAudio != null) audioUrl = _selectedAudio!.url;

      if (widget.editedMediaResult != null) {
        if (widget.editedMediaResult is String) {
          final file = File(widget.editedMediaResult);
          if (file.existsSync()) {
            final ext = file.path.split('.').last.toLowerCase();
            final isImage = ['jpg','jpeg','png','gif','bmp'].contains(ext);
            if (isImage) images.add(file); else videos.add(file);
          }
        } else {
          final file = await _convertResultToFile(widget.editedMediaResult);
          if (file != null) {
            final isImage = widget.editedMediaResult is Uint8List;
            if (isImage) images.add(file); else videos.add(file);
          }
        }
      } else if (widget.selectedAssets != null) {
        for (var asset in widget.selectedAssets!) {
          final f = await asset.file;
          if (f != null) {
            if (asset.type == AssetType.image) images.add(f); else videos.add(f);
          }
        }
      }

      // Here you should call your service to upload post
      await Future.delayed(const Duration(seconds: 1)); // simulate

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Post created'), backgroundColor: Colors.green));
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildPreview() {
    if (_editedFile != null) {
      if (_videoController != null && _videoController!.value.isInitialized) {
        return AspectRatio(aspectRatio: _videoController!.value.aspectRatio, child: VideoPlayer(_videoController!));
      } else {
        return Image.file(_editedFile!, fit: BoxFit.cover);
      }
    }
    final first = widget.selectedAssets?.isNotEmpty == true ? widget.selectedAssets!.first : null;
    if (first != null) {
      return AssetEntityImage(first, isOriginal: false, thumbnailSize: const ThumbnailSize.square(200), fit: BoxFit.cover);
    }
    return Container(color: Colors.grey[800], child: const Center(child: Icon(Icons.image, color: Colors.white)));
  }

  Widget _buildAudioSubtitle() {
    if (_audioFile != null) return Text(_audioFile!.path.split('/').last, style: const TextStyle(color: Colors.white));
    if (_selectedAudio != null) return Text(_selectedAudio!.name, style: const TextStyle(color: Colors.white));
    return const Text('Select a song or upload audio', style: TextStyle(color: Colors.grey));
  }

  Widget _buildLocationSubtitle() {
    if (_selectedLocation != null) return Text(_selectedLocation!.name, style: const TextStyle(color: Colors.white));
    return const Text('Select a location', style: TextStyle(color: Colors.grey));
  }

  Widget _buildTagFriendsSubtitle() {
    if (_taggedUsers.isEmpty) return const Text('Select friends', style: TextStyle(color: Colors.grey));
    return Wrap(spacing: 8, children: _taggedUsers.map((u) => Chip(label: Text(u.username, style: const TextStyle(color: Colors.white)), backgroundColor: Colors.blueGrey[700])).toList());
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
          TextButton(onPressed: _isLoading ? null : _sharePost, child: _isLoading ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Share', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              SizedBox(width: 64, height: 64, child: ClipRRect(borderRadius: BorderRadius.circular(12), child: _buildPreview())),
              const SizedBox(width: 12),
              Expanded(child: TextField(controller: _captionController, style: const TextStyle(color: Colors.white), maxLines: 4, decoration: const InputDecoration(hintText: 'Write a caption...', hintStyle: TextStyle(color: Colors.grey), border: InputBorder.none))),
            ]),
            const SizedBox(height: 8),
            Divider(color: Colors.white24, height: 24),
            ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.alternate_email, color: Colors.white), title: const Text('Tag friends', style: TextStyle(color: Colors.white)), trailing: const Icon(Icons.chevron_right, color: Colors.white54), onTap: () {}, subtitle: _buildTagFriendsSubtitle()),
            Divider(color: Colors.white24, height: 24),
            ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.music_note, color: Colors.white), title: const Text('Add music', style: TextStyle(color: Colors.white)), trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(icon: const Icon(Icons.upload_file, color: Colors.white), tooltip: 'Upload audio file', onPressed: _pickAudioFile), const Icon(Icons.chevron_right, color: Colors.white54)]), onTap: () {}, subtitle: _buildAudioSubtitle()),
            Divider(color: Colors.white24, height: 24),
            ListTile(contentPadding: EdgeInsets.zero, leading: const Icon(Icons.location_on, color: Colors.white), title: const Text('Add location', style: TextStyle(color: Colors.white)), trailing: const Icon(Icons.chevron_right, color: Colors.white54), onTap: () {}, subtitle: _buildLocationSubtitle()),
            Divider(color: Colors.white24, height: 24),
            TextField(controller: _hashtagsController, style: const TextStyle(color: Colors.white), decoration: const InputDecoration(hintText: 'Add hashtags (e.g. #fun)', hintStyle: TextStyle(color: Colors.grey), border: InputBorder.none, prefixIcon: Icon(Icons.tag, color: Colors.white54))),
            Divider(color: Colors.white24, height: 24),
            Padding(padding: const EdgeInsets.symmetric(vertical: 8.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Who can see this post?', style: TextStyle(color: Colors.white, fontSize: 16)),
              const SizedBox(height: 8),
              Row(children: [
                ChoiceChip(label: const Text('Public'), selected: _selectedOptionView == 'Public', onSelected: (s) { if (s) setState(() => _selectedOptionView = 'Public'); }, backgroundColor: Colors.grey[800], selectedColor: Colors.blue, labelStyle: TextStyle(color: _selectedOptionView == 'Public' ? Colors.white : Colors.grey)),
                const SizedBox(width: 8),
                ChoiceChip(label: const Text('Friends'), selected: _selectedOptionView == 'Friends', onSelected: (s) { if (s) setState(() => _selectedOptionView = 'Friends'); }, backgroundColor: Colors.grey[800], selectedColor: Colors.blue, labelStyle: TextStyle(color: _selectedOptionView == 'Friends' ? Colors.white : Colors.grey)),
                const SizedBox(width: 8),
                ChoiceChip(label: const Text('Only me'), selected: _selectedOptionView == 'OnlyMe', onSelected: (s) { if (s) setState(() => _selectedOptionView = 'OnlyMe'); }, backgroundColor: Colors.grey[800], selectedColor: Colors.blue, labelStyle: TextStyle(color: _selectedOptionView == 'OnlyMe' ? Colors.white : Colors.grey)),
              ])
            ])),
          ]),
        ),
      ),
    );
  }
}

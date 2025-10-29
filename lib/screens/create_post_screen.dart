import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:photo_manager_image_provider/photo_manager_image_provider.dart';
import 'photo_editor_screen.dart';
import 'video_editor_screen.dart';
import 'finalize_post_screen.dart';
import 'package:video_player/video_player.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});
  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  List<AssetEntity> _mediaAssets = [];
  List<AssetEntity> _selectedAssets = [];
  AssetEntity? _selectedAsset;
  VideoPlayerController? _videoController;
  bool _isLoading = true;
  bool _isMultiSelectEnabled = false;

  List<AssetPathEntity> _albums = [];
  AssetPathEntity? _selectedAlbum;

  @override
  void initState() {
    super.initState();
    _fetchAlbumsAndMedia();
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  Future<void> _fetchAlbumsAndMedia() async {
    setState(() => _isLoading = true);
    final perm = await PhotoManager.requestPermissionExtend();
    if (!perm.isAuth) {
      PhotoManager.openSetting();
      setState(() => _isLoading = false);
      return;
    }
    try {
      final albums = await PhotoManager.getAssetPathList(type: RequestType.all);
      if (albums.isEmpty) {
        setState(() => _isLoading = false);
        return;
      }
      setState(() { _albums = albums; _selectedAlbum = albums.first; });
      await _fetchMediaForAlbum(_selectedAlbum!);
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Error loading albums: $e');
    }
  }

  Future<void> _fetchMediaForAlbum(AssetPathEntity album) async {
    setState(() { _isLoading = true; _selectedAsset = null; _selectedAssets.clear(); });
    try {
      final assets = await album.getAssetListRange(start: 0, end: 200);
      setState(() {
        _mediaAssets = assets;
        if (assets.isNotEmpty) _selectAsset(assets.first);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('Error loading media: $e');
    }
  }

  void _showError(String msg) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));

  void _selectAsset(AssetEntity asset) {
    if (_selectedAsset == asset) return;
    setState(() {
      _selectedAsset = asset;
      if (!_isMultiSelectEnabled) { _selectedAssets.clear(); _selectedAssets.add(asset); }
    });
    _loadPreviewForAsset(asset);
  }

  Future<void> _loadPreviewForAsset(AssetEntity asset) async {
    _videoController?.dispose();
    _videoController = null;
    final file = await asset.file;
    if (file == null || !mounted) return;
    if (asset.type == AssetType.video) {
      _videoController = VideoPlayerController.file(file);
      await _videoController!.initialize();
      if (!mounted) return;
      setState(() {});
      _videoController!.play();
      _videoController!.setLooping(true);
    } else {
      setState(() {});
    }
  }

  void _toggleMultiSelect() {
    setState(() {
      _isMultiSelectEnabled = !_isMultiSelectEnabled;
      if (!_isMultiSelectEnabled && _selectedAsset != null) _selectedAssets = [_selectedAsset!];
    });
  }

  void _onAssetTapped(AssetEntity asset) {
    _selectAsset(asset);
    if (_isMultiSelectEnabled) {
      setState(() { if (_selectedAssets.contains(asset)) _selectedAssets.remove(asset); else _selectedAssets.add(asset); });
    }
  }

  Future<void> _takePhoto() async {
    final photo = await _imagePicker.pickImage(source: ImageSource.camera, imageQuality: 85);
    if (photo != null && mounted) {
      final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => FinalizePostScreen(editedMediaResult: photo.path)));
      if (res == true && mounted) Navigator.of(context).pop(true);
    }
  }

  Future<void> _recordVideo() async {
    final video = await _imagePicker.pickVideo(source: ImageSource.camera, maxDuration: const Duration(seconds: 60));
    if (video != null && mounted) {
      final res = await Navigator.push(context, MaterialPageRoute(builder: (_) => FinalizePostScreen(editedMediaResult: video.path)));
      if (res == true && mounted) Navigator.of(context).pop(true);
    }
  }

  void _showCameraOptions() {
    showModalBottomSheet(context: context, backgroundColor: Colors.black87, builder: (_) => Container(
      padding: const EdgeInsets.all(12),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(leading: const Icon(Icons.camera_alt, color: Colors.white), title: const Text('Chụp ảnh', style: TextStyle(color: Colors.white)), onTap: () { Navigator.pop(context); _takePhoto(); }),
        ListTile(leading: const Icon(Icons.videocam, color: Colors.white), title: const Text('Quay video', style: TextStyle(color: Colors.white)), onTap: () { Navigator.pop(context); _recordVideo(); }),
      ]),
    ));
  }

  void _goNext() async {
    if (_selectedAssets.isEmpty) return;
    _videoController?.pause();
    if (_selectedAssets.length == 1 && _selectedAsset != null) {
      final asset = _selectedAsset!;
      final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => asset.type == AssetType.video ? VideoEditorScreen(asset: asset) : PhotoEditorScreen(asset: asset)));
      if (result != null && mounted) {
        final fin = await Navigator.push(context, MaterialPageRoute(builder: (_) => FinalizePostScreen(editedMediaResult: result)));
        if (fin == true && mounted) Navigator.of(context).pop(true);
      }
    } else {
      final fin = await Navigator.push(context, MaterialPageRoute(builder: (_) => FinalizePostScreen(selectedAssets: _selectedAssets)));
      if (fin == true && mounted) Navigator.of(context).pop(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(child: Column(children: [
        _buildHeader(),
        if (_isLoading) const Expanded(child: Center(child: CircularProgressIndicator())) else ...[
          _buildPreview(),
          _buildGalleryControls(),
          _buildAssetGrid(),
        ]
      ])),
    );
  }

  Widget _buildHeader() {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      IconButton(icon: const Icon(Icons.close, color: Colors.white), onPressed: () => Navigator.of(context).pop()),
      const Text('Tạo bài đăng', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      TextButton(onPressed: _selectedAssets.isNotEmpty ? _goNext : null, child: Text('Tiếp', style: TextStyle(color: _selectedAssets.isNotEmpty ? Colors.blueAccent : Colors.grey)))
    ]));
  }

  Widget _buildPreview() {
    return AspectRatio(aspectRatio: 1, child: Container(color: Colors.black, child: _selectedAsset == null ? const Center(child: Text('Chọn ảnh hoặc video', style: TextStyle(color: Colors.white))) : _selectedAsset!.type == AssetType.video && _videoController?.value.isInitialized == true ? VideoPlayer(_videoController!) : AssetEntityImage(_selectedAsset!, isOriginal: false, fit: BoxFit.cover)));
  }

  Widget _buildGalleryControls() {
    return Padding(padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0), child: Row(children: [
      if (_selectedAlbum != null) DropdownButton<AssetPathEntity>(value: _selectedAlbum, onChanged: (album) { if (album != null) _fetchMediaForAlbum(album); }, items: _albums.map((a) => DropdownMenuItem(value: a, child: Text(a.name.isEmpty ? 'Recents' : a.name, style: const TextStyle(color: Colors.white)))).toList(), dropdownColor: Colors.grey[800], icon: const Icon(Icons.arrow_drop_down, color: Colors.white), underline: Container()),
      const Spacer(),
      IconButton(icon: Icon(_isMultiSelectEnabled ? Icons.copy_all : Icons.copy_all_outlined, color: _isMultiSelectEnabled ? Colors.blueAccent : Colors.white), onPressed: _toggleMultiSelect),
      IconButton(icon: const Icon(Icons.camera_alt_outlined, color: Colors.white), onPressed: _showCameraOptions),
    ]));
  }

  Widget _buildAssetGrid() {
    return Expanded(child: GridView.builder(padding: EdgeInsets.zero, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, crossAxisSpacing: 1, mainAxisSpacing: 1), itemCount: _mediaAssets.length, itemBuilder: (context, i) {
      final asset = _mediaAssets[i];
      final isSelected = _selectedAssets.contains(asset);
      return GestureDetector(onTap: () => _onAssetTapped(asset), child: Stack(fit: StackFit.expand, children: [
        AssetEntityImage(asset, isOriginal: false, thumbnailSize: const ThumbnailSize.square(250), fit: BoxFit.cover),
        if (asset.type == AssetType.video) const Positioned(bottom: 4, right: 4, child: Icon(Icons.videocam, color: Colors.white, size: 18)),
        if (isSelected) Container(decoration: BoxDecoration(border: Border.all(color: Colors.blueAccent, width: 3), color: Colors.black.withOpacity(0.2)), child: Center(child: Text('${_selectedAssets.indexOf(asset) + 1}', style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)))),
      ]));
    }));
  }
}

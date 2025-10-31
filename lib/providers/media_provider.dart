import 'package:flutter/material.dart';
import '../models/media_model.dart';
import '../services/media_service.dart';

class MediaProvider with ChangeNotifier {
  final MediaService _mediaService = MediaService();
  List<MediaModel> _mediaList = [];
  bool _loading = false;

  List<MediaModel> get mediaList => List.unmodifiable(_mediaList);
  bool get loading => _loading;

  Future<void> fetchMedia() async {
    if (_loading) return;
    _loading = true;
    notifyListeners();

    try {
      final result = await _mediaService.loadAll();
      _mediaList = result;
    } catch (e) {
      debugPrint('Error fetching media: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> addMedia(MediaModel media) async {
    try {
      await _mediaService.add(media);
      await fetchMedia();
    } catch (e) {
      debugPrint('Error adding media: $e');
    }
  }

  Future<void> deleteMedia(String id) async {
    try {
      await _mediaService.delete(id);
      _mediaList = _mediaList.where((m) => m.id != id).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting media: $e');
    }
  }

  // Optional alias
  Future<void> loadMedia() async => await fetchMedia();
}

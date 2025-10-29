import 'package:flutter/material.dart';
import '../models/media_model.dart';
import '../services/media_service.dart';

class MediaProvider with ChangeNotifier {
  final MediaService _mediaService = MediaService();
  List<MediaModel> _mediaList = [];
  bool _loading = false;

  List<MediaModel> get mediaList => _mediaList;
  bool get loading => _loading;

  Future<void> fetchMedia() async {
    _loading = true;
    notifyListeners();

    _mediaList = await _mediaService.loadAll();

    _loading = false;
    notifyListeners();
  }

  Future<void> loadMedia() async {
    await fetchMedia();
  }

  Future<void> addMedia(MediaModel media) async {
    await _mediaService.add(media);
    _mediaList.add(media);
    notifyListeners();
  }

  Future<void> deleteMedia(String id) async {
    await _mediaService.delete(id);
    _mediaList.removeWhere((m) => m.id == id);
    notifyListeners();
  }
}

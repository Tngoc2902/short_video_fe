import 'package:flutter/material.dart';
import '../models/media_model.dart';
import '../services/media_service.dart';

class MediaProvider with ChangeNotifier {
  final MediaService _service = MediaService();

  List<MediaModel> _mediaList = [];
  bool _loading = false;

  List<MediaModel> get mediaList => _mediaList;
  bool get loading => _loading;

  Future<void> fetchMedia() async {
    _loading = true;
    notifyListeners();

    _mediaList = await _service.loadAll();

    _loading = false;
    notifyListeners();
  }
}

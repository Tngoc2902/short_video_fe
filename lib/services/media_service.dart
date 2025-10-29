import 'dart:io';
import '../models/media_model.dart';

class MediaService {
  final List<MediaModel> _mediaList = [];

  // Load tất cả media (giả lập từ list cục bộ)
  Future<List<MediaModel>> loadAll() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_mediaList);
  }

  // Thêm media
  Future<void> add(MediaModel media) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _mediaList.add(media);
  }

  // Xóa media theo id
  Future<void> delete(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _mediaList.removeWhere((m) => m.id == id);
  }
}

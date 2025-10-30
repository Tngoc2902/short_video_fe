import 'package:flutter/material.dart';
import '../models/media_model.dart';
import '../services/media_service.dart';

class MediaProvider with ChangeNotifier {
  final MediaService _mediaService = MediaService();
  List<MediaModel> _mediaList = [];
  bool _loading = false;

  List<MediaModel> get mediaList => List.unmodifiable(_mediaList); // 🔒 tránh sửa trực tiếp
  bool get loading => _loading;

  // ✅ Hàm load toàn bộ media với kiểm soát trạng thái an toàn
  Future<void> fetchMedia() async {
    if (_loading) return; // Ngăn gọi lặp

    _loading = true;
    notifyListeners();

    try {
      final result = await _mediaService.loadAll();
      if (result is List<MediaModel>) {
        _mediaList = result;
      }
    } catch (e) {
      debugPrint('⚠️ Lỗi khi load media: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadMedia() async {
    await fetchMedia();
  }

  // ✅ Thêm media với reload lại danh sách (an toàn hơn append)
  Future<void> addMedia(MediaModel media) async {
    try {
      await _mediaService.add(media);
      // Tải lại danh sách từ service để đồng bộ
      await fetchMedia();
    } catch (e) {
      debugPrint('⚠️ Lỗi khi thêm media: $e');
    }
  }

  // ✅ Xóa media an toàn, tránh lỗi RangeError
  Future<void> deleteMedia(String id) async {
    try {
      await _mediaService.delete(id);
      // Dùng where để lọc lại danh sách mới
      _mediaList = _mediaList.where((m) => m.id != id).toList();
      notifyListeners();
    } catch (e) {
      debugPrint('⚠️ Lỗi khi xóa media: $e');
    }
  }
}

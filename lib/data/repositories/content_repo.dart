import 'package:dio/dio.dart';

import '../../core/constants.dart';
import '../../core/network/api_client.dart';
import '../models/category.dart';
import '../models/title_model.dart';

class ContentRepository {
  ContentRepository({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  String _fullUrl(String path) {
    if (path.startsWith('http')) return path;
    final base = Constants.apiBaseUrl;
    return path.startsWith('/') ? '$base$path' : '$base/$path';
  }

  Future<List<Category>> getCategories() async {
    final res = await _api.get<List<dynamic>>('/categories');
    final list = res.data;
    if (list == null) return [];
    return list
        .map((e) => Category.fromJson(e is Map ? Map<String, dynamic>.from(e) : {}))
        .toList();
  }

  Future<Category?> getCategory(String id) async {
    try {
      final res = await _api.get<Map<String, dynamic>>('/categories/$id');
      final data = res.data;
      if (data == null) return null;
      return Category.fromJson(Map<String, dynamic>.from(data));
    } catch (_) {
      return null;
    }
  }

  Future<List<TitleModel>> getTitles() async {
    final res = await _api.get<List<dynamic>>('/titles');
    final list = res.data;
    if (list == null) return [];
    return list
        .map((e) => TitleModel.fromJson(e is Map ? Map<String, dynamic>.from(e) : {}))
        .toList();
  }

  Future<TitleModel?> getTitle(String id) async {
    try {
      final res = await _api.get<Map<String, dynamic>>('/titles/$id');
      final data = res.data;
      if (data == null) return null;
      return TitleModel.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (_) {
      return null;
    }
  }

  /// Returns full video URL for streaming (supports Range for seeking).
  /// Full URLs (e.g. external CDN) are loaded via API proxy to avoid source errors on Android.
  String videoUrl(String pathOrFilename) {
    final raw = pathOrFilename.trim();
    if (raw.isEmpty) return '';
    if (raw.startsWith('http://') || raw.startsWith('https://')) {
      return '${Constants.apiBaseUrl}/videos/stream?url=${Uri.encodeComponent(raw)}';
    }
    String filename = raw
        .replaceFirst('/api/videos/', '')
        .replaceFirst('api/videos/', '');
    return _fullUrl('/videos/$filename');
  }
}

import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';

class WatchlistRepository {
  WatchlistRepository({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  Future<List<String>> getWatchlistIds() async {
    try {
      final res = await _api.get<dynamic>('/watchlist');
      final data = res.data;
      if (data == null) return [];
      if (data is List) {
        return data.map((e) => e?.toString() ?? '').where((s) => s.isNotEmpty).toList();
      }
      if (data is Map && data['titleIds'] != null) {
        final list = data['titleIds'] as List<dynamic>? ?? [];
        return list.map((e) => e?.toString() ?? '').where((s) => s.isNotEmpty).toList();
      }
      return [];
    } on DioException catch (_) {
      return [];
    }
  }

  Future<void> addToWatchlist(String titleId) async {
    await _api.post('/watchlist', data: {'titleId': titleId});
  }

  Future<void> removeFromWatchlist(String titleId) async {
    await _api.delete('/watchlist/$titleId');
  }
}

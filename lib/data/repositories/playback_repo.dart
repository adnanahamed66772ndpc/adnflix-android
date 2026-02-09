import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../models/playback.dart';

class PlaybackRepository {
  PlaybackRepository({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  Future<List<PlaybackProgress>> getPlaybackProgress() async {
    try {
      final res = await _api.get<List<dynamic>>('/playback');
      final list = res.data;
      if (list == null) return [];
      return list
          .map((e) =>
              PlaybackProgress.fromJson(e is Map ? Map<String, dynamic>.from(e) : {}))
          .toList();
    } on DioException catch (_) {
      return [];
    }
  }

  Future<void> saveProgress({
    required String titleId,
    String? episodeId,
    required int progressSeconds,
    required int durationSeconds,
  }) async {
    await _api.post(
      '/playback',
      data: {
        'titleId': titleId,
        if (episodeId != null) 'episodeId': episodeId,
        'progressSeconds': progressSeconds,
        'durationSeconds': durationSeconds,
      },
    );
  }

  Future<PlaybackProgress?> getMovieProgress(String titleId) async {
    try {
      final res = await _api.get<Map<String, dynamic>>('/playback/movie/$titleId');
      final data = res.data;
      if (data == null) return null;
      return PlaybackProgress.fromJson(Map<String, dynamic>.from(data));
    } catch (_) {
      return null;
    }
  }

  Future<List<PlaybackProgress>> getSeriesProgress(String titleId) async {
    try {
      final res = await _api.get<List<dynamic>>('/playback/series/$titleId');
      final list = res.data;
      if (list == null) return [];
      return list
          .map((e) =>
              PlaybackProgress.fromJson(e is Map ? Map<String, dynamic>.from(e) : {}))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> deleteMovieProgress(String titleId) async {
    try {
      await _api.delete('/playback/movie/$titleId');
    } catch (_) {}
  }

  Future<void> deleteSeriesProgress(String titleId) async {
    try {
      await _api.delete('/playback/series/$titleId');
    } catch (_) {}
  }
}

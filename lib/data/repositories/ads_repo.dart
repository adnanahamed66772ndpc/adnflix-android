import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../models/ad_model.dart';

class AdsRepository {
  AdsRepository({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  Future<AdSettings> getAdSettings() async {
    try {
      final res = await _api.get<Map<String, dynamic>>('/ads/settings');
      final data = res.data;
      if (data == null) return AdSettings();
      return AdSettings.fromJson(Map<String, dynamic>.from(data));
    } catch (_) {
      return AdSettings();
    }
  }

  Future<List<AdVideo>> getActiveAdVideos() async {
    try {
      final res = await _api.get<List<dynamic>>('/ads/videos/active');
      final list = res.data;
      if (list == null) return [];
      return list
          .map((e) => AdVideo.fromJson(e is Map ? Map<String, dynamic>.from(e) : {}))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> trackImpression(String adId, {bool isClick = false}) async {
    try {
      await _api.post(
        '/ads/impressions',
        data: {'adId': adId, 'type': isClick ? 'click' : 'impression'},
      );
    } catch (_) {}
  }
}

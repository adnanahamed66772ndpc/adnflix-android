import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';

class PagesRepository {
  PagesRepository({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  Future<String> getPageContent(String key) async {
    try {
      final res = await _api.get<dynamic>('/pages/$key');
      final data = res.data;
      if (data == null) return '';
      if (data is String) return data;
      if (data is Map && data['content'] != null) return data['content'].toString();
      return data.toString();
    } on DioException catch (_) {
      return '';
    }
  }
}

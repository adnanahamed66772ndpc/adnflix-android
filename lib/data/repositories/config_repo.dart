import 'package:dio/dio.dart';

import '../../core/constants.dart';
import '../../core/network/api_client.dart';
import '../models/config.dart';

class ConfigRepository {
  ConfigRepository({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  Future<AppConfig> getConfig() async {
    final res = await _api.get<Map<String, dynamic>>('/config');
    final data = res.data;
    if (data == null) throw Exception('Config data is null');
    return AppConfig.fromJson(data is Map ? Map<String, dynamic>.from(data) : {});
  }
}

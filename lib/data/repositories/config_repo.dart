import '../../core/constants.dart';
import '../../core/network/api_client.dart';
import '../models/config.dart';

class ConfigRepository {
  ConfigRepository({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  Future<AppConfig> getConfig() async {
    try {
      final res = await _api.get<Map<String, dynamic>>('/config');
      final data = res.data;
      if (data == null || data is! Map) {
        return AppConfig(maintenanceMode: false, plans: [], paymentMethods: []);
      }
      return AppConfig.fromJson(Map<String, dynamic>.from(data));
    } catch (_) {
      return AppConfig(maintenanceMode: false, plans: [], paymentMethods: []);
    }
  }

  /// Fetch plans directly (fallback when full config has no plans).
  Future<List<Plan>> getPlans() async {
    try {
      final res = await _api.get<dynamic>('/config/plans');
      final data = res.data;
      if (data == null) return [];
      if (data is! List) return [];
      return data
          .map((e) => Plan.fromJson(e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{}))
          .where((p) => p.id.isNotEmpty || p.name.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }

  /// Fetch payment methods directly (fallback when full config has none).
  Future<List<PaymentMethod>> getPaymentMethods() async {
    try {
      final res = await _api.get<dynamic>('/config/payment-methods');
      final data = res.data;
      if (data == null) return [];
      if (data is! List) return [];
      return data
          .map((e) => PaymentMethod.fromJson(e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{}))
          .where((pm) => pm.id.isNotEmpty || pm.name.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }
}

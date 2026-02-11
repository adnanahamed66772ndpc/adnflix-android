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

  /// Fetch payment methods from API (GET /api/config/payment-methods).
  /// Numbers are set in Admin → Settings → Payment numbers. Always call this so numbers come from API.
  /// Handles response as raw array or wrapped in { data } / { paymentMethods }. If this fails or is empty, tries getConfig().
  Future<List<PaymentMethod>> getPaymentMethods() async {
    List<PaymentMethod> list = await _getPaymentMethodsFromEndpoint();
    if (list.isNotEmpty) return list;
    // Fallback: full config also includes paymentMethods (same source on backend).
    try {
      final config = await getConfig();
      list = config.paymentMethods ?? [];
    } catch (_) {}
    return list;
  }

  Future<List<PaymentMethod>> _getPaymentMethodsFromEndpoint() async {
    try {
      final res = await _api.get<dynamic>('/config/payment-methods');
      final data = res.data;
      if (data == null) return [];
      List<dynamic> rawList = const [];
      if (data is List) {
        rawList = data;
      } else if (data is Map) {
        final map = Map<String, dynamic>.from(data as Map);
        final fromData = map['data'];
        final fromKey = map['paymentMethods'];
        if (fromData is List) rawList = fromData;
        else if (fromKey is List) rawList = fromKey;
      }
      return rawList
          .map((e) => PaymentMethod.fromJson(e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{}))
          .where((pm) => pm.id.isNotEmpty || pm.name.isNotEmpty)
          .toList();
    } catch (_) {
      return [];
    }
  }
}

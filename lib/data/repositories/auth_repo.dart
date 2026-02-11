import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/network/token_storage.dart';
import '../models/user.dart';

class AuthRepository {
  AuthRepository({
    ApiClient? apiClient,
    TokenStorage? tokenStorage,
  })  : _api = apiClient ?? ApiClient(),
        _tokenStorage = tokenStorage ?? TokenStorage();

  final ApiClient _api;
  final TokenStorage _tokenStorage;

  Future<User> login(String email, String password) async {
    final res = await _api.post<Map<String, dynamic>>(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    final data = res.data;
    if (data == null) throw Exception('Login failed');
    final token = data['token'] as String?;
    if (token == null || token.isEmpty) throw Exception('No token received');
    await _tokenStorage.saveToken(token);
    final userJson = data['user'] as Map<String, dynamic>? ?? data;
    return User.fromJson(userJson);
  }

  Future<User> register(String email, String password, {String? displayName}) async {
    final res = await _api.post<Map<String, dynamic>>(
      '/auth/register',
      data: {
        'email': email,
        'password': password,
        if (displayName != null && displayName.isNotEmpty) 'displayName': displayName,
      },
    );
    final data = res.data;
    if (data == null) throw Exception('Registration failed');
    final token = data['token'] as String?;
    if (token == null || token.isEmpty) throw Exception('No token received');
    await _tokenStorage.saveToken(token);
    final userJson = data['user'] as Map<String, dynamic>? ?? data;
    return User.fromJson(userJson);
  }

  Future<void> logout() async {
    try {
      await _api.post('/auth/logout');
    } catch (_) {}
    await _tokenStorage.clearToken();
  }

  Future<User?> getMe() async {
    try {
      final res = await _api.get<Map<String, dynamic>>('/auth/me');
      final data = res.data;
      if (data == null) return null;
      return User.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await _tokenStorage.clearToken();
      }
      return null;
    }
  }

  Future<User> updateProfile({String? displayName, String? avatarUrl}) async {
    final res = await _api.put<Map<String, dynamic>>(
      '/auth/profile',
      data: {
        if (displayName != null) 'displayName': displayName,
        if (avatarUrl != null) 'avatarUrl': avatarUrl,
      },
    );
    final data = res.data;
    if (data == null) throw Exception('Update failed');
    return User.fromJson(Map<String, dynamic>.from(data));
  }

  Future<bool> isLoggedIn() async {
    final token = await _tokenStorage.getToken();
    return token != null && token.isNotEmpty;
  }

  /// Check if current user has a valid (active paid) subscription.
  /// valid is true only when plan is not "free" and (expiresAt is null or in the future).
  /// Use to gate premium content or features.
  Future<SubscriptionCheck> checkSubscription() async {
    try {
      final res = await _api.get<Map<String, dynamic>>('/auth/subscription/check');
      final data = res.data;
      if (data == null) return SubscriptionCheck(valid: false);
      return SubscriptionCheck(
        valid: data['valid'] == true,
        expiresAt: data['expiresAt'] != null
            ? DateTime.tryParse(data['expiresAt'].toString())
            : null,
      );
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) await _tokenStorage.clearToken();
      return SubscriptionCheck(valid: false);
    }
  }
}

/// Result of GET /api/auth/subscription/check.
class SubscriptionCheck {
  final bool valid;
  final DateTime? expiresAt;
  SubscriptionCheck({required this.valid, this.expiresAt});
}

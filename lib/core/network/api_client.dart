import 'package:dio/dio.dart';

import '../constants.dart';
import 'token_storage.dart';

/// Dio-based API client with auth interceptor and 429 retry.
class ApiClient {
  ApiClient({TokenStorage? tokenStorage})
      : _tokenStorage = tokenStorage ?? TokenStorage(),
        _dio = Dio(BaseOptions(
          baseUrl: Constants.apiBaseUrl,
          connectTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: {'Accept': 'application/json', 'Content-Type': 'application/json'},
        )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _tokenStorage.getToken();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          await _tokenStorage.clearToken();
        }
        // Retry once after delay when server returns 429 (Too Many Requests)
        if (error.response?.statusCode == 429) {
          await Future<void>.delayed(const Duration(seconds: 12));
          try {
            final response = await _dio.fetch<void>(error.requestOptions);
            return handler.resolve(response);
          } catch (_) {
            // ignore second failure
          }
        }
        return handler.next(error);
      },
    ));
  }

  final Dio _dio;
  final TokenStorage _tokenStorage;

  Dio get dio => _dio;

  Future<Response<T>> get<T>(String path, {Map<String, dynamic>? queryParameters}) =>
      _dio.get<T>(path, queryParameters: queryParameters);

  Future<Response<T>> post<T>(String path, {dynamic data}) =>
      _dio.post<T>(path, data: data);

  Future<Response<T>> put<T>(String path, {dynamic data}) =>
      _dio.put<T>(path, data: data);

  Future<Response<T>> delete<T>(String path) => _dio.delete<T>(path);
}

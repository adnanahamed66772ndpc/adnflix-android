import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../models/transaction.dart';

class TransactionsRepository {
  TransactionsRepository({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  Future<List<Transaction>> getTransactions() async {
    try {
      final res = await _api.get<List<dynamic>>('/transactions');
      final list = res.data;
      if (list == null) return [];
      return list
          .map((e) =>
              Transaction.fromJson(e is Map ? Map<String, dynamic>.from(e) : {}))
          .toList();
    } on DioException catch (_) {
      return [];
    }
  }

  Future<Transaction> createTransaction({
    required String planId,
    required String paymentMethod,
    required String transactionId,
    required num amount,
    String? senderNumber,
  }) async {
    final res = await _api.post<Map<String, dynamic>>(
      '/transactions',
      data: {
        'planId': planId,
        'paymentMethod': paymentMethod,
        'transactionId': transactionId.trim(),
        'amount': amount,
        if (senderNumber != null && senderNumber.trim().isNotEmpty) 'senderNumber': senderNumber.trim(),
      },
    );
    final data = res.data;
    if (data == null) throw Exception('Failed to create transaction');
    return Transaction.fromJson(Map<String, dynamic>.from(data));
  }
}

import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../models/ticket.dart';

class TicketsRepository {
  TicketsRepository({ApiClient? apiClient}) : _api = apiClient ?? ApiClient();

  final ApiClient _api;

  Future<List<Ticket>> getTickets() async {
    try {
      final res = await _api.get<List<dynamic>>('/tickets');
      final list = res.data;
      if (list == null) return [];
      return list
          .map((e) => Ticket.fromJson(e is Map ? Map<String, dynamic>.from(e) : {}))
          .toList();
    } on DioException catch (_) {
      return [];
    }
  }

  Future<Ticket?> getTicket(String id) async {
    try {
      final res = await _api.get<Map<String, dynamic>>('/tickets/$id');
      final data = res.data;
      if (data == null) return null;
      return Ticket.fromJson(Map<String, dynamic>.from(data));
    } catch (_) {
      return null;
    }
  }

  Future<Ticket> createTicket({
    required String subject,
    required String message,
    String priority = 'medium',
  }) async {
    final res = await _api.post<Map<String, dynamic>>(
      '/tickets',
      data: {'subject': subject, 'message': message, 'priority': priority},
    );
    final data = res.data;
    if (data == null) throw Exception('Failed to create ticket');
    return Ticket.fromJson(Map<String, dynamic>.from(data));
  }

  Future<void> addReply(String ticketId, String message) async {
    await _api.post('/tickets/$ticketId/replies', data: {'message': message});
  }
}

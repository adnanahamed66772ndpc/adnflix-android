import '../../core/json_utils.dart';

class Ticket {
  final String id;
  final String subject;
  final String? message;
  final String status; // open, in_progress, resolved, closed
  final String priority; // low, medium, high, urgent
  final String? createdAt;
  final List<TicketReply>? replies;
  /// Unique display id e.g. SUP-A1B2C3D4
  final String? supportId;
  /// 'web' | 'app'
  final String? source;

  Ticket({
    required this.id,
    required this.subject,
    this.message,
    required this.status,
    this.priority = 'medium',
    this.createdAt,
    this.replies,
    this.supportId,
    this.source,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id']?.toString() ?? '',
      subject: json['subject'] as String? ?? '',
      message: json['message'] as String?,
      status: json['status'] as String? ?? 'open',
      priority: json['priority'] as String? ?? 'medium',
      createdAt: json['created_at'] as String? ?? json['createdAt'] as String?,
      replies: (json['replies'] as List<dynamic>?)
          ?.map((e) => TicketReply.fromJson(e is Map ? Map<String, dynamic>.from(e) : <String, dynamic>{}))
          .toList(),
      supportId: json['support_id'] as String? ?? json['supportId'] as String?,
      source: json['source'] as String?,
    );
  }
}

class TicketReply {
  final String id;
  final String message;
  final bool isStaff;
  final String? createdAt;
  final String? userName;

  TicketReply({
    required this.id,
    required this.message,
    this.isStaff = false,
    this.createdAt,
    this.userName,
  });

  factory TicketReply.fromJson(Map<String, dynamic> json) {
    final isAdmin = json['is_admin'];
    final isStaffVal = json['isStaff'];
    bool staff = false;
    if (isAdmin != null) staff = fromJsonBool(isAdmin);
    if (isStaffVal != null) staff = staff || fromJsonBool(isStaffVal);
    return TicketReply(
      id: json['id']?.toString() ?? '',
      message: json['message'] as String? ?? '',
      isStaff: staff,
      createdAt: json['created_at'] as String? ?? json['createdAt'] as String?,
      userName: json['user_name'] as String? ?? json['userName'] as String?,
    );
  }
}

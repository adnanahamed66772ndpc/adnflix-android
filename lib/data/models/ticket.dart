class Ticket {
  final String id;
  final String subject;
  final String? message;
  final String status; // open, in_progress, resolved, closed
  final String priority; // low, medium, high, urgent
  final String? createdAt;
  final List<TicketReply>? replies;

  Ticket({
    required this.id,
    required this.subject,
    this.message,
    required this.status,
    this.priority = 'medium',
    this.createdAt,
    this.replies,
  });

  factory Ticket.fromJson(Map<String, dynamic> json) {
    return Ticket(
      id: json['id']?.toString() ?? '',
      subject: json['subject'] as String? ?? '',
      message: json['message'] as String?,
      status: json['status'] as String? ?? 'open',
      priority: json['priority'] as String? ?? 'medium',
      createdAt: json['createdAt'] as String?,
      replies: (json['replies'] as List<dynamic>?)
          ?.map((e) => TicketReply.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class TicketReply {
  final String id;
  final String message;
  final bool isStaff;
  final String? createdAt;

  TicketReply({
    required this.id,
    required this.message,
    this.isStaff = false,
    this.createdAt,
  });

  factory TicketReply.fromJson(Map<String, dynamic> json) {
    return TicketReply(
      id: json['id']?.toString() ?? '',
      message: json['message'] as String? ?? '',
      isStaff: json['isStaff'] as bool? ?? false,
      createdAt: json['createdAt'] as String?,
    );
  }
}

class Transaction {
  final String id;
  final String planId;
  final String? planName;
  final String status; // pending, approved, rejected
  final String? paymentMethod;
  final String? transactionId;
  final int? amount;
  final String? createdAt;
  final String? updatedAt;

  Transaction({
    required this.id,
    required this.planId,
    this.planName,
    required this.status,
    this.paymentMethod,
    this.transactionId,
    this.amount,
    this.createdAt,
    this.updatedAt,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id']?.toString() ?? '',
      planId: json['planId'] as String? ?? '',
      planName: json['planName'] as String?,
      status: json['status'] as String? ?? 'pending',
      paymentMethod: json['paymentMethod'] as String?,
      transactionId: json['transactionId'] as String?,
      amount: (json['amount'] is num) ? (json['amount'] as num).toInt() : null,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }
}

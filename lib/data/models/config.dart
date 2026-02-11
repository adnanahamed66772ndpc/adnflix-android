import '../../core/json_utils.dart';

class AppConfig {
  final bool maintenanceMode;
  final String? maintenanceMessage;
  final List<Plan>? plans;
  final List<PaymentMethod>? paymentMethods;

  AppConfig({
    required this.maintenanceMode,
    this.maintenanceMessage,
    this.plans,
    this.paymentMethods,
  });

  factory AppConfig.fromJson(Map<String, dynamic> json) {
    return AppConfig(
      maintenanceMode: fromJsonBool(json['maintenanceMode']),
      maintenanceMessage: json['maintenanceMessage'] as String?,
      plans: (json['plans'] as List<dynamic>?)
          ?.map((e) => Plan.fromJson(e as Map<String, dynamic>))
          .toList(),
      paymentMethods: (json['paymentMethods'] as List<dynamic>?)
          ?.map((e) => PaymentMethod.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class Plan {
  final String id;
  final String name;
  final int price;
  final String currency;

  Plan({required this.id, required this.name, required this.price, required this.currency});

  factory Plan.fromJson(Map<String, dynamic> json) {
    return Plan(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      price: (json['price'] is num) ? (json['price'] as num).toInt() : 0,
      currency: json['currency'] as String? ?? 'BDT',
    );
  }
}

class PaymentMethod {
  final String id;
  final String name;
  final String? number;
  /// API format: list of strings. Optional for display.
  final List<String>? instructions;
  final String? logo;
  final String? color;

  PaymentMethod({
    required this.id,
    required this.name,
    this.number,
    this.instructions,
    this.logo,
    this.color,
  });

  /// Parses API format: [{ "id", "name", "number", "logo", "color", "instructions": [] }]
  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    Object? rawNumber = json['number'] ?? json['phone'] ?? json['accountNumber'] ??
        json['sendMoneyNumber'] ?? json['paymentNumber'];
    String? number;
    if (rawNumber != null) {
      if (rawNumber is String) number = rawNumber.trim();
      if (rawNumber is num) number = rawNumber.toString();
    }
    if (number != null && number.isEmpty) number = null;

    List<String>? instructions;
    final raw = json['instructions'];
    if (raw is List) {
      instructions = raw
          .map((e) => e is String ? e : e?.toString() ?? '')
          .where((s) => s.isNotEmpty)
          .toList();
      if (instructions.isEmpty) instructions = null;
    }

    return PaymentMethod(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      number: number,
      instructions: instructions,
      logo: json['logo'] as String?,
      color: json['color'] as String?,
    );
  }
}

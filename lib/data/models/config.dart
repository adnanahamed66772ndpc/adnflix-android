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
      maintenanceMode: json['maintenanceMode'] as bool? ?? false,
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
  final String? instructions;

  PaymentMethod({required this.id, required this.name, this.number, this.instructions});

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    return PaymentMethod(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      number: json['number'] as String?,
      instructions: json['instructions'] as String?,
    );
  }
}

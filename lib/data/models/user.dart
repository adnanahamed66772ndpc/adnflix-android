class User {
  final String id;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final String subscriptionPlan; // free, with-ads, premium
  /// When the current paid plan expires (after 30 days from approve). Null for free or no expiry.
  final DateTime? subscriptionExpiresAt;

  User({
    required this.id,
    required this.email,
    this.displayName,
    this.avatarUrl,
    this.subscriptionPlan = 'free',
    this.subscriptionExpiresAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    DateTime? expiresAt;
    final raw = json['subscriptionExpiresAt'];
    if (raw != null) {
      if (raw is String) expiresAt = DateTime.tryParse(raw);
      if (raw is int) expiresAt = DateTime.fromMillisecondsSinceEpoch(raw);
    }
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String? ?? json['name'] as String?,
      avatarUrl: json['avatarUrl'] as String? ?? json['avatar'] as String?,
      subscriptionPlan: json['subscriptionPlan'] as String? ?? 'free',
      subscriptionExpiresAt: expiresAt,
    );
  }

  bool get isPremium => subscriptionPlan == 'premium';
  bool get canSkipAds => subscriptionPlan == 'premium';
  bool get hasWithAdsOrPremium =>
      subscriptionPlan == 'with-ads' || subscriptionPlan == 'premium';

  /// True if plan is paid and expiry date has passed (server will downgrade to free).
  bool get isSubscriptionExpired =>
      subscriptionExpiresAt != null && subscriptionExpiresAt!.isBefore(DateTime.now());

  /// Days until expiry; null if no expiry or already expired.
  int? get daysUntilExpiry {
    if (subscriptionExpiresAt == null) return null;
    final now = DateTime.now();
    if (subscriptionExpiresAt!.isBefore(now)) return null;
    return subscriptionExpiresAt!.difference(now).inDays;
  }
}

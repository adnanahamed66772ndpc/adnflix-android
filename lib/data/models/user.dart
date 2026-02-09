class User {
  final String id;
  final String email;
  final String? displayName;
  final String? avatarUrl;
  final String subscriptionPlan; // free, with-ads, premium

  User({
    required this.id,
    required this.email,
    this.displayName,
    this.avatarUrl,
    this.subscriptionPlan = 'free',
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '',
      email: json['email'] as String? ?? '',
      displayName: json['displayName'] as String? ?? json['name'] as String?,
      avatarUrl: json['avatarUrl'] as String? ?? json['avatar'] as String?,
      subscriptionPlan: json['subscriptionPlan'] as String? ?? 'free',
    );
  }

  bool get isPremium => subscriptionPlan == 'premium';
  bool get canSkipAds => subscriptionPlan == 'premium';
  bool get hasWithAdsOrPremium =>
      subscriptionPlan == 'with-ads' || subscriptionPlan == 'premium';
}

/// API and app constants for ADNFLIX.
/// App uses same API as website: config (plans, payment methods), pages (terms, privacy, help), transactions, tickets.
class Constants {
  Constants._();

  /// Backend API base. Auto-set here only; app users cannot edit it.
  /// Must match where your website + admin run (e.g. if site is coliningram.site, use https://coliningram.site/api).
  static const String apiBaseUrl = 'https://coliningram.site/api';

  static const String appVersion = '1.0.0';

  /// Fallback only when API is unreachable. Prefer admin-set numbers via API; set here only for offline/builds where API is not used.
  static const String? paymentNumberBkash = null;
  static const String? paymentNumberNagad = null;
  static const String? paymentNumberRocket = null;

  static const String tokenKey = 'auth_token';

  static const String netflixRed = '#E50914';
  static const String netflixDark = '#141414';
  static const String netflixDarkLighter = '#1F1F1F';
  static const String netflixGrey = '#808080';
}

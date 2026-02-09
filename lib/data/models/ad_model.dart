import '../../core/json_utils.dart';

class AdSettings {
  final bool enabled;
  final bool preRoll;
  final bool midRoll;
  final int midRollIntervalSeconds;
  final int skipAfterSeconds;

  AdSettings({
    this.enabled = false,
    this.preRoll = true,
    this.midRoll = false,
    this.midRollIntervalSeconds = 300,
    this.skipAfterSeconds = 5,
  });

  factory AdSettings.fromJson(Map<String, dynamic> json) {
    return AdSettings(
      enabled: fromJsonBool(json['enabled']),
      preRoll: fromJsonBool(json['pre_roll'] ?? json['preRoll'] ?? true),
      midRoll: fromJsonBool(json['mid_roll'] ?? json['midRoll']),
      midRollIntervalSeconds:
          (json['mid_roll_interval'] is num)
              ? (json['mid_roll_interval'] as num).toInt()
              : (json['midRollInterval'] is num)
                  ? (json['midRollInterval'] as num).toInt()
                  : 300,
      skipAfterSeconds:
          (json['skip_after'] is num)
              ? (json['skip_after'] as num).toInt()
              : (json['skipAfter'] is num)
                  ? (json['skipAfter'] as num).toInt()
                  : 5,
    );
  }
}

class AdVideo {
  final String id;
  final String? videoUrl;
  final int? durationSeconds;
  final String? skipAfterSeconds;

  AdVideo({
    required this.id,
    this.videoUrl,
    this.durationSeconds,
    this.skipAfterSeconds,
  });

  factory AdVideo.fromJson(Map<String, dynamic> json) {
    return AdVideo(
      id: json['id']?.toString() ?? '',
      videoUrl: json['videoUrl'] as String? ?? json['url'] as String?,
      durationSeconds: (json['durationSeconds'] is num)
          ? (json['durationSeconds'] as num).toInt()
          : null,
      skipAfterSeconds: json['skipAfterSeconds']?.toString(),
    );
  }
}

class PlaybackProgress {
  final String titleId;
  final String? episodeId;
  final int progressSeconds;
  final int durationSeconds;
  final String? titleName;
  final String? posterUrl;
  final int? seasonNumber;
  final int? episodeNumber;
  final String? episodeName;

  PlaybackProgress({
    required this.titleId,
    this.episodeId,
    required this.progressSeconds,
    required this.durationSeconds,
    this.titleName,
    this.posterUrl,
    this.seasonNumber,
    this.episodeNumber,
    this.episodeName,
  });

  factory PlaybackProgress.fromJson(Map<String, dynamic> json) {
    return PlaybackProgress(
      titleId: json['titleId']?.toString() ?? '',
      episodeId: json['episodeId']?.toString(),
      progressSeconds: (json['progressSeconds'] is num)
          ? (json['progressSeconds'] as num).toInt()
          : 0,
      durationSeconds: (json['durationSeconds'] is num)
          ? (json['durationSeconds'] as num).toInt()
          : 0,
      titleName: json['titleName'] as String? ?? json['title']?['name'] as String?,
      posterUrl: json['posterUrl'] as String? ?? json['title']?['posterUrl'] as String?,
      seasonNumber: (json['seasonNumber'] is num)
          ? (json['seasonNumber'] as num).toInt()
          : null,
      episodeNumber: (json['episodeNumber'] is num)
          ? (json['episodeNumber'] as num).toInt()
          : null,
      episodeName: json['episodeName'] as String? ?? json['episode']?['name'] as String?,
    );
  }

  double get progressPercent =>
      durationSeconds > 0 ? progressSeconds / durationSeconds : 0.0;
}

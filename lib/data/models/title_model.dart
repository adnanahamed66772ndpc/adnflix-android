import '../../core/json_utils.dart';

class TitleModel {
  final String id;
  final String name;
  final String? description;
  final String? posterUrl;
  final String? backdropUrl;
  final String type; // movie, series
  final bool premium;
  final List<String> categoryIds;
  final List<Season>? seasons;
  final String? videoUrl; // for movies
  final int? releaseYear;
  final double? rating;
  final int? durationMinutes;
  final List<String> genres;
  final String? maturity;

  TitleModel({
    required this.id,
    required this.name,
    this.description,
    this.posterUrl,
    this.backdropUrl,
    this.type = 'movie',
    this.premium = false,
    this.categoryIds = const [],
    this.seasons,
    this.videoUrl,
    this.releaseYear,
    this.rating,
    this.durationMinutes,
    this.genres = const [],
    this.maturity,
  });

  factory TitleModel.fromJson(Map<String, dynamic> json) {
    final releaseYearRaw = json['releaseYear'] ?? json['year'];
    final releaseYear = (releaseYearRaw is num)
        ? (releaseYearRaw as num).toInt()
        : (releaseYearRaw != null ? int.tryParse(releaseYearRaw.toString()) : null);

    final durationRaw = json['duration'];
    final durationMinutes = (durationRaw is num)
        ? (durationRaw as num).toInt()
        : (durationRaw != null ? int.tryParse(durationRaw.toString()) : null);

    final genresList = json['genres'];
    final genres = genresList is List
        ? genresList
            .map((e) => e is Map ? (e['name'] ?? e['id'] ?? e).toString() : e.toString())
            .where((s) => s.isNotEmpty)
            .toList()
        : <String>[];

    return TitleModel(
      id: json['id']?.toString() ?? '',
      name: json['name'] as String? ?? json['title'] as String? ?? '',
      description: json['description'] as String? ?? json['synopsis'] as String?,
      posterUrl: json['posterUrl'] as String? ?? json['poster'] as String?,
      backdropUrl: json['backdropUrl'] as String? ?? json['backdrop'] as String?,
      type: json['type'] as String? ?? 'movie',
      premium: fromJsonBool(json['premium']),
      categoryIds: (json['categoryIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          (json['categories'] as List<dynamic>?)
              ?.map((e) => e is Map ? (e['id'] ?? e).toString() : e.toString())
              .toList() ??
          [],
      seasons: (json['seasons'] as List<dynamic>?)
          ?.map((e) => Season.fromJson(e as Map<String, dynamic>))
          .toList(),
      videoUrl: json['videoUrl'] as String? ?? json['video'] as String?,
      releaseYear: releaseYear,
      rating: (json['rating'] is num) ? (json['rating'] as num).toDouble() : null,
      durationMinutes: durationMinutes,
      genres: genres,
      maturity: json['maturity'] as String?,
    );
  }

  bool get isSeries => type == 'series';
  bool get isMovie => type == 'movie';
}

class Season {
  final String id;
  final int seasonNumber;
  final String? name;
  final List<Episode> episodes;

  Season({
    required this.id,
    required this.seasonNumber,
    this.name,
    this.episodes = const [],
  });

  factory Season.fromJson(Map<String, dynamic> json) {
    return Season(
      id: json['id']?.toString() ?? '',
      seasonNumber: (json['seasonNumber'] is num)
          ? (json['seasonNumber'] as num).toInt()
          : (json['number'] is num)
              ? (json['number'] as num).toInt()
              : 0,
      name: json['name'] as String?,
      episodes: (json['episodes'] as List<dynamic>?)
              ?.map((e) => Episode.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class Episode {
  final String id;
  final int episodeNumber;
  final String? name;
  final String? description;
  final String? videoUrl;
  final int? durationSeconds;
  final String? thumbnailUrl;

  Episode({
    required this.id,
    required this.episodeNumber,
    this.name,
    this.description,
    this.videoUrl,
    this.durationSeconds,
    this.thumbnailUrl,
  });

  factory Episode.fromJson(Map<String, dynamic> json) {
    return Episode(
      id: json['id']?.toString() ?? '',
      episodeNumber: (json['episodeNumber'] is num)
          ? (json['episodeNumber'] as num).toInt()
          : (json['number'] is num)
              ? (json['number'] as num).toInt()
              : 0,
      name: json['name'] as String? ?? json['title'] as String?,
      description: json['description'] as String?,
      videoUrl: json['videoUrl'] as String? ?? json['video'] as String?,
      durationSeconds: (json['durationSeconds'] is num)
          ? (json['durationSeconds'] as num).toInt()
          : null,
      thumbnailUrl: json['thumbnailUrl'] as String? ?? json['thumbnail'] as String?,
    );
  }
}

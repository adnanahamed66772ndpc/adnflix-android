import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../app/router.dart';
import '../../app/providers.dart';
import '../../data/models/title_model.dart';
import '../../data/repositories/content_repo.dart';

class TitleDetailsScreen extends StatefulWidget {
  const TitleDetailsScreen({super.key, required this.titleId});

  final String titleId;

  @override
  State<TitleDetailsScreen> createState() => _TitleDetailsScreenState();
}

class _TitleDetailsScreenState extends State<TitleDetailsScreen> {
  TitleModel? _title;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    final content = context.read<ContentProvider>();
    final t = await content.getTitle(widget.titleId);
    if (!mounted) return;
    setState(() {
      _title = t;
      _loading = false;
      if (t == null) _error = 'Title not found';
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && _title == null) {
      return Scaffold(
        backgroundColor: netflixDark,
        appBar: AppBar(title: const Text('Details')),
        body: Center(child: CircularProgressIndicator(color: netflixRed)),
      );
    }

    if (_error != null && _title == null) {
      return Scaffold(
        backgroundColor: netflixDark,
        appBar: AppBar(title: const Text('Details')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!),
              TextButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }

    final title = _title!;
    final content = context.read<ContentProvider>();
    final contentRepo = content.contentRepo;
    final watchlist = context.watch<WatchlistProvider>();
    final inWatchlist = watchlist.isInWatchlist(title.id);

    final backdropUrl = title.backdropUrl ?? title.posterUrl;
    final fullBackdrop = backdropUrl != null && backdropUrl.isNotEmpty
        ? (backdropUrl.startsWith('http')
            ? backdropUrl
            : 'https://coliningram.site$backdropUrl')
        : null;

    final categoryNames = <String>[];
    for (final id in title.categoryIds) {
      for (final c in content.categories) {
        if (c.id == id && c.name.isNotEmpty) {
          categoryNames.add(c.name);
          break;
        }
      }
    }
    final metaItems = <String>[];
    if (title.releaseYear != null) metaItems.add(title.releaseYear.toString());
    if (title.rating != null && title.rating! > 0) metaItems.add('${title.rating!.toStringAsFixed(1)} ★');
    if (title.durationMinutes != null && title.durationMinutes! > 0) {
      final m = title.durationMinutes!;
      if (m >= 60) metaItems.add('${m ~/ 60}h ${m % 60}m');
      else metaItems.add('${m}m');
    }
    if (title.maturity != null && title.maturity!.isNotEmpty) metaItems.add(title.maturity!);
    if (title.isSeries && title.seasons != null && title.seasons!.isNotEmpty) {
      final totalEps = title.seasons!.fold<int>(0, (s, se) => s + se.episodes.length);
      metaItems.add('${title.seasons!.length} Season${title.seasons!.length == 1 ? '' : 's'} · $totalEps Episodes');
    }

    return Scaffold(
      backgroundColor: netflixDark,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: netflixDark,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => Navigator.of(context).pop(),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: fullBackdrop != null
                  ? CachedNetworkImage(
                      imageUrl: fullBackdrop,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(color: netflixDarkLighter),
                      errorWidget: (_, __, ___) =>
                          Container(color: netflixDarkLighter, child: const Icon(Icons.movie)),
                    )
                  : Container(color: netflixDarkLighter),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  if (metaItems.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      metaItems.join(' · '),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                    ),
                  ],
                  if (title.genres.isNotEmpty || categoryNames.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        ...title.genres.map((g) => _Chip(label: g)),
                        ...categoryNames.map((n) => _Chip(label: n)),
                      ],
                    ),
                  ],
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _play(context, title, contentRepo),
                        icon: const Icon(Icons.play_arrow, size: 28),
                        label: const Text('Play'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        ),
                      ),
                      const SizedBox(width: 12),
                      IconButton.filled(
                        onPressed: () => watchlist.toggle(title.id),
                        icon: Icon(
                          inWatchlist ? Icons.bookmark : Icons.bookmark_border,
                          color: Colors.white,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: netflixDarkLighter,
                        ),
                      ),
                    ],
                  ),
                  if (title.description != null && title.description!.trim().isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Overview',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      title.description!.trim(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.white70,
                            height: 1.4,
                          ),
                    ),
                  ],
                  if (title.isSeries && title.seasons != null && title.seasons!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      'Seasons & Episodes',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                    ),
                    const SizedBox(height: 12),
                    ...title.seasons!.map((season) => _SeasonSection(
                          season: season,
                          titleId: title.id,
                          titleName: title.name,
                          contentRepo: contentRepo,
                        )),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _play(BuildContext context, TitleModel title, ContentRepository contentRepo) {
    if (title.isMovie) {
      final path = title.videoUrl ?? '';
      if (path.isEmpty) return;
      Navigator.of(context).pushNamed(
        AppRouter.player,
        arguments: {
          'titleId': title.id,
          'videoPath': path,
          'titleName': title.name,
          'isSeries': false,
        },
      );
    } else {
      final firstSeason = title.seasons?.isNotEmpty == true ? title.seasons!.first : null;
      final firstEpisode =
          firstSeason?.episodes.isNotEmpty == true ? firstSeason!.episodes.first : null;
      if (firstEpisode == null) return;
      final path = firstEpisode.videoUrl ?? '';
      if (path.isEmpty) return;
      Navigator.of(context).pushNamed(
        AppRouter.player,
        arguments: {
          'titleId': title.id,
          'videoPath': path,
          'episodeId': firstEpisode.id,
          'episodeName': firstEpisode.name,
          'titleName': title.name,
          'isSeries': true,
        },
      );
    }
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white12,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
      ),
    );
  }
}

class _SeasonSection extends StatelessWidget {
  const _SeasonSection({
    required this.season,
    required this.titleId,
    required this.titleName,
    required this.contentRepo,
  });

  final Season season;
  final String titleId;
  final String titleName;
  final ContentRepository contentRepo;

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      title: Text(
        'Season ${season.seasonNumber}',
        style: Theme.of(context).textTheme.titleMedium,
      ),
      children: season.episodes
          .map((ep) => ListTile(
                title: Text(
                  'E${ep.episodeNumber} ${ep.name ?? ''}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                trailing: const Icon(Icons.play_circle_outline),
                onTap: () {
                  final path = ep.videoUrl ?? '';
                  if (path.isEmpty) return;
                  Navigator.of(context).pushNamed(
                    AppRouter.player,
                    arguments: {
                      'titleId': titleId,
                      'videoPath': path,
                      'episodeId': ep.id,
                      'episodeName': ep.name,
                      'titleName': titleName,
                      'isSeries': true,
                    },
                  );
                },
              ))
          .toList(),
    );
  }
}

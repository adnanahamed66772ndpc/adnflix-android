import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../app/router.dart';
import '../../app/providers.dart';
import '../../data/models/title_model.dart';
import '../../data/models/playback.dart';
import '../../widgets/continue_watching_card.dart';
import '../../widgets/horizontal_rail.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlaybackProvider>().load();
      context.read<WatchlistProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final content = context.watch<ContentProvider>();
    final playback = context.watch<PlaybackProvider>();
    final auth = context.watch<AuthProvider>();

    if (content.loading && content.titles.isEmpty) {
      return const Scaffold(
        backgroundColor: netflixDark,
        body: Center(
          child: CircularProgressIndicator(color: netflixRed),
        ),
      );
    }

    if (content.error != null && content.titles.isEmpty) {
      return Scaffold(
        backgroundColor: netflixDark,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(content.error!, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () => content.load(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final featured = content.titles.isNotEmpty ? content.titles.first : null;
    final progressMap = <String, double>{};
    for (final p in playback.progress) {
      progressMap[p.titleId] = p.progressPercent;
    }

    return Scaffold(
      backgroundColor: netflixDark,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: netflixDark,
            title: Text(
              'ADNFLIX',
              style: TextStyle(
                color: netflixRed,
                fontWeight: FontWeight.w900,
                fontSize: 24,
                letterSpacing: 2,
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {},
              ),
            ],
          ),
          if (featured != null) _HeroBanner(title: featured),
          if (auth.isLoggedIn && playback.hasProgress) ...[
            SliverToBoxAdapter(
              child: ContinueWatchingCard(
                item: playback.progress.first,
                onTap: () => _openPlayback(context, playback.progress.first),
              ),
            ),
            const SliverToBoxAdapter(child: SizedBox(height: 16)),
          ],
          ...content.categories.map((cat) {
            final list = content.titlesByCategory(cat.id);
            if (list.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());
            return SliverToBoxAdapter(
              child: HorizontalRail(
                title: cat.name,
                titles: list,
                progressMap: progressMap,
                onTitleTap: (t) => Navigator.of(context).pushNamed(
                  AppRouter.titleDetails,
                  arguments: {'titleId': t.id},
                ),
              ),
            );
          }),
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  void _openPlayback(BuildContext context, PlaybackProgress p) {
    context.read<ContentProvider>().getTitle(p.titleId).then((title) {
      if (!context.mounted) return;
      if (title == null) return;
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
            'startPositionSeconds': p.progressSeconds,
          },
        );
      } else {
        if (p.episodeId == null) return;
        for (final s in title.seasons ?? []) {
          for (final e in s.episodes) {
            if (e.id == p.episodeId) {
              final videoPath = e.videoUrl ?? '';
              if (videoPath.isEmpty) return;
              Navigator.of(context).pushNamed(
                AppRouter.player,
                arguments: {
                  'titleId': title.id,
                  'videoPath': videoPath,
                  'episodeId': e.id,
                  'episodeName': e.name,
                  'titleName': title.name,
                  'isSeries': true,
                  'startPositionSeconds': p.progressSeconds,
                },
              );
              return;
            }
          }
        }
      }
    });
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.title});

  final TitleModel title;

  @override
  Widget build(BuildContext context) {
    final imageUrl = title.backdropUrl ?? title.posterUrl;
    final fullUrl = imageUrl != null && imageUrl.isNotEmpty
        ? (imageUrl.startsWith('http') ? imageUrl : 'https://coliningram.site$imageUrl')
        : null;

    return SliverToBoxAdapter(
      child: GestureDetector(
        onTap: () => Navigator.of(context).pushNamed(
          AppRouter.titleDetails,
          arguments: {'titleId': title.id},
        ),
        child: Stack(
          alignment: Alignment.bottomLeft,
          children: [
            SizedBox(
              height: 220,
              width: double.infinity,
              child: fullUrl != null
                  ? CachedNetworkImage(
                      imageUrl: fullUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: netflixDarkLighter,
                        child: const Center(
                          child: CircularProgressIndicator(color: netflixRed),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: netflixDarkLighter,
                        child: const Icon(Icons.movie, color: Colors.white38, size: 64),
                      ),
                    )
                  : Container(
                      color: netflixDarkLighter,
                      child: const Icon(Icons.movie, color: Colors.white38, size: 64),
                    ),
            ),
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, netflixDark],
                ),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 24,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title.name,
                    style: Theme.of(context).textTheme.headlineSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _ActionButton(
                        icon: Icons.play_arrow,
                        label: 'Play',
                        onTap: () => _playTitle(context),
                      ),
                      const SizedBox(width: 12),
                      _ActionButton(
                        icon: Icons.info_outline,
                        label: 'Info',
                        onTap: () => Navigator.of(context).pushNamed(
                          AppRouter.titleDetails,
                          arguments: {'titleId': title.id},
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _playTitle(BuildContext context) {
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
      final firstSeason = (title.seasons != null && title.seasons!.isNotEmpty)
          ? title.seasons!.first
          : null;
      final firstEpisode = (firstSeason?.episodes.isNotEmpty ?? false)
          ? firstSeason!.episodes.first
          : null;
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

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(4),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(4),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20, color: Colors.white),
              const SizedBox(width: 8),
              Text(label, style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}


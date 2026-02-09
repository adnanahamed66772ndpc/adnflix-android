import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../app/router.dart';
import '../../app/providers.dart';
import '../../data/models/title_model.dart';
import '../../widgets/horizontal_rail.dart';
import '../../widgets/poster_card.dart';

class BrowseScreen extends StatelessWidget {
  const BrowseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final content = context.watch<ContentProvider>();
    final playback = context.watch<PlaybackProvider>();
    final progressMap = <String, double>{};
    for (final p in playback.progress) {
      progressMap[p.titleId] = p.progressPercent;
    }

    return Scaffold(
      backgroundColor: netflixDark,
      appBar: AppBar(
        title: const Text('Browse'),
        backgroundColor: netflixDark,
      ),
      body: content.loading && content.titles.isEmpty
          ? Center(child: CircularProgressIndicator(color: netflixRed))
          : content.error != null && content.titles.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_off, size: 64, color: Colors.white54),
                        const SizedBox(height: 16),
                        Text(
                          content.error!,
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        TextButton(
                          onPressed: () => content.load(),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : !content.loading && content.titles.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.movie_outlined, size: 80, color: Colors.white54),
                            const SizedBox(height: 24),
                            const Text(
                              'No content yet',
                              style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Pull down to refresh or tap Retry.',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.white70),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            TextButton.icon(
                              onPressed: () => content.load(),
                              icon: const Icon(Icons.refresh, color: netflixRed),
                              label: const Text('Retry', style: TextStyle(color: netflixRed)),
                            ),
                          ],
                        ),
                      ),
                    )
                  : RefreshIndicator(
                      onRefresh: () => content.load(),
                      color: netflixRed,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.only(bottom: 24),
                        children: [
                          ...content.categories.map((cat) {
                            final list = content.titlesByCategory(cat.id);
                            if (list.isEmpty) return const SizedBox.shrink();
                            return HorizontalRail(
                              title: cat.name,
                              titles: list,
                              progressMap: progressMap,
                              onTitleTap: (t) => Navigator.of(context).pushNamed(
                                AppRouter.titleDetails,
                                arguments: {'titleId': t.id},
                              ),
                            );
                          }),
                          if (content.titles.isNotEmpty) ...[
                            SectionHeader(title: 'All'),
                            _AllTitlesGrid(titles: content.titles),
                          ],
                        ],
                      ),
                    ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  const SectionHeader({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}

class _AllTitlesGrid extends StatelessWidget {
  const _AllTitlesGrid({required this.titles});

  final List<TitleModel> titles;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          childAspectRatio: 0.65,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: titles.length,
        itemBuilder: (context, index) {
          final t = titles[index];
          return PosterCard(
            imageUrl: t.posterUrl,
            title: t.name,
            onTap: () => Navigator.of(context).pushNamed(
              AppRouter.titleDetails,
              arguments: {'titleId': t.id},
            ),
          );
        },
      ),
    );
  }
}

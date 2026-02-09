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
                )
              : ListView(
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
                    if (content.categories.isEmpty && content.titles.isNotEmpty) ...[
                      SectionHeader(title: 'All'),
                      _AllTitlesGrid(titles: content.titles),
                    ],
                  ],
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

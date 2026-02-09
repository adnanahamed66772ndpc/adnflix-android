import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../app/router.dart';
import '../../app/providers.dart';
import '../../data/models/title_model.dart';
import '../../widgets/poster_card.dart';

class WatchlistScreen extends StatelessWidget {
  const WatchlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final watchlist = context.watch<WatchlistProvider>();
    final content = context.watch<ContentProvider>();

    if (!auth.isLoggedIn) {
      return Scaffold(
        backgroundColor: netflixDark,
        appBar: AppBar(title: const Text('My List')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.bookmark_border, size: 80, color: netflixGrey),
                const SizedBox(height: 24),
                Text(
                  'Sign in to save titles to your list',
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pushNamed(AppRouter.login),
                  child: const Text('Sign In'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (watchlist.loading && watchlist.ids.isEmpty) {
      return Scaffold(
        backgroundColor: netflixDark,
        appBar: AppBar(title: const Text('My List')),
        body: Center(child: CircularProgressIndicator(color: netflixRed)),
      );
    }

    if (watchlist.ids.isEmpty) {
      return Scaffold(
        backgroundColor: netflixDark,
        appBar: AppBar(title: const Text('My List')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bookmark_border, size: 80, color: netflixGrey),
              const SizedBox(height: 24),
              Text(
                'Your watchlist is empty',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Add titles from Browse or details to watch later',
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final titles = <TitleModel>[];
    for (final id in watchlist.ids) {
      final t = content.titles.where((x) => x.id == id).firstOrNull;
      if (t != null) titles.add(t);
    }

    return Scaffold(
      backgroundColor: netflixDark,
      appBar: AppBar(title: const Text('My List')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
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

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}

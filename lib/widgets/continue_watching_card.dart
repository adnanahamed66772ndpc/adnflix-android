import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../app/theme.dart';
import '../data/models/playback.dart';
import 'section_header.dart';

class ContinueWatchingCard extends StatelessWidget {
  const ContinueWatchingCard({
    super.key,
    required this.item,
    required this.onTap,
  });

  final PlaybackProgress item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fullUrl = item.posterUrl != null && item.posterUrl!.isNotEmpty
        ? (item.posterUrl!.startsWith('http')
            ? item.posterUrl!
            : 'https://coliningram.site${item.posterUrl}')
        : null;

    final subtitle = item.episodeName != null ||
            (item.seasonNumber != null && item.episodeNumber != null)
        ? 'S${item.seasonNumber ?? 0} E${item.episodeNumber ?? 0}${item.episodeName != null ? ' · ${item.episodeName}' : ''}'
        : null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: 'Continue Watching'),
          GestureDetector(
            onTap: onTap,
            child: Stack(
              alignment: Alignment.bottomLeft,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    height: 200,
                    width: double.infinity,
                    child: fullUrl != null
                        ? CachedNetworkImage(
                            imageUrl: fullUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: netflixDarkLighter,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: netflixRed,
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: netflixDarkLighter,
                              child: const Icon(
                                Icons.movie_outlined,
                                color: Colors.white38,
                                size: 48,
                              ),
                            ),
                          )
                        : Container(
                            color: netflixDarkLighter,
                            child: const Icon(
                              Icons.movie_outlined,
                              color: Colors.white38,
                              size: 48,
                            ),
                          ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [Colors.transparent, Colors.black87],
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        item.titleName ?? 'Continue',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: LinearProgressIndicator(
                                value: item.progressPercent.clamp(0.0, 1.0),
                                backgroundColor: Colors.white24,
                                valueColor: AlwaysStoppedAnimation<Color>(netflixRed),
                                minHeight: 4,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_formatDuration(item.progressSeconds)} / ${_formatDuration(item.durationSeconds)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _formatDuration(int seconds) {
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return '${m}:${s.toString().padLeft(2, '0')}';
  }
}


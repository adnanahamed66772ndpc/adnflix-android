import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';


class PosterCard extends StatelessWidget {
  const PosterCard({
    super.key,
    required this.imageUrl,
    this.title,
    this.onTap,
    this.progress,
    this.height = 160,
    this.width = 110,
  });

  final String? imageUrl;
  final String? title;
  final VoidCallback? onTap;
  final double? progress; // 0.0 - 1.0
  final double height;
  final double width;

  @override
  Widget build(BuildContext context) {
    final fullUrl = imageUrl != null && imageUrl!.isNotEmpty
        ? (imageUrl!.startsWith('http') ? imageUrl! : 'https://coliningram.site$imageUrl')
        : null;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Stack(
                children: [
                  SizedBox(
                    width: width,
                    height: height,
                    child: fullUrl != null
                        ? CachedNetworkImage(
                            imageUrl: fullUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => Container(
                              color: const Color(0xFF1F1F1F),
                              child: const Center(
                                child: CircularProgressIndicator(strokeWidth: 1),
                              ),
                            ),
                            errorWidget: (_, __, ___) => Container(
                              color: const Color(0xFF1F1F1F),
                              child: const Icon(Icons.movie_outlined, color: Colors.white38),
                            ),
                          )
                        : Container(
                            color: const Color(0xFF1F1F1F),
                            child: const Icon(Icons.movie_outlined, color: Colors.white38),
                          ),
                  ),
                  if (progress != null && progress! > 0 && progress! < 1)
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: Container(
                        height: 4,
                        color: Colors.white24,
                        child: LayoutBuilder(
                          builder: (_, c) => Row(
                            children: [
                              SizedBox(
                                width: c.maxWidth * progress!.clamp(0.0, 1.0),
                                child: Container(color: const Color(0xFFE50914)),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            if (title != null && title!.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                title!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white,
                      fontSize: 12,
                    ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}


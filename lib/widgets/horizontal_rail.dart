import 'package:flutter/material.dart';

import 'poster_card.dart';
import 'section_header.dart';
import '../data/models/title_model.dart';

class HorizontalRail extends StatelessWidget {
  const HorizontalRail({
    super.key,
    this.title,
    required this.titles,
    this.onTitleTap,
    this.progressMap,
  });

  final String? title;
  final List<TitleModel> titles;
  final void Function(TitleModel title)? onTitleTap;
  final Map<String, double>? progressMap;

  @override
  Widget build(BuildContext context) {
    if (titles.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null && title!.isNotEmpty)
          SectionHeader(title: title!),
        SizedBox(
          height: 180,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: titles.length,
            itemBuilder: (context, index) {
              final t = titles[index];
              final progress = progressMap != null ? progressMap![t.id] : null;
              return Padding(
                padding: const EdgeInsets.only(right: 12),
                child: PosterCard(
                  imageUrl: t.posterUrl,
                  title: t.name,
                  progress: progress,
                  onTap: () => onTitleTap?.call(t),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

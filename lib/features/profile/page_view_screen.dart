import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../data/repositories/pages_repo.dart';

class PageViewScreen extends StatefulWidget {
  const PageViewScreen({super.key, required this.pageKey});

  final String pageKey;

  @override
  State<PageViewScreen> createState() => _PageViewScreenState();
}

class _PageViewScreenState extends State<PageViewScreen> {
  String _content = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final repo = context.read<PagesRepository>();
      final text = await repo.getPageContent(widget.pageKey);
      if (mounted) {
        setState(() {
          _content = text;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.pageKey == 'terms'
        ? 'Terms of Use'
        : widget.pageKey == 'privacy'
            ? 'Privacy Policy'
            : 'Help';

    return Scaffold(
      backgroundColor: netflixDark,
      appBar: AppBar(title: Text(title)),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: netflixRed))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _content.isEmpty
                  ? Center(
                      child: Text(
                        'Content not available',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    )
                  : MarkdownBody(
                      data: _content,
                      styleSheet: MarkdownStyleSheet(
                        p: Theme.of(context).textTheme.bodyMedium,
                        h1: Theme.of(context).textTheme.headlineMedium,
                        h2: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
            ),
    );
  }
}

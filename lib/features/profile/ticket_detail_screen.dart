import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../data/models/ticket.dart';
import '../../data/repositories/tickets_repo.dart';

class TicketDetailScreen extends StatefulWidget {
  const TicketDetailScreen({super.key, required this.ticketId});

  final String ticketId;

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  Ticket? _ticket;
  bool _loading = true;
  bool _sending = false;
  final _replyController = TextEditingController();
  final _scrollController = ScrollController();
  Timer? _pollTimer;

  @override
  void initState() {
    super.initState();
    _load();
    _startPolling();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _replyController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _startPolling() {
    _pollTimer?.cancel();
    _pollTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      _load(silent: true);
    });
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) setState(() => _loading = true);
    try {
      final repo = context.read<TicketsRepository>();
      final t = await repo.getTicket(widget.ticketId);
      if (mounted) {
        setState(() {
          _ticket = t;
          _loading = false;
        });
        _scrollToBottom();
      }
    } catch (_) {
      if (mounted && !silent) setState(() => _loading = false);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  List<Widget> _buildMessageBubbles() {
    final ticket = _ticket!;
    final bubbles = <Widget>[];

    // Initial ticket message as first bubble (user)
    if (ticket.message != null && ticket.message!.isNotEmpty) {
      bubbles.add(_buildBubble(
        message: ticket.message!,
        isFromSupport: false,
        label: 'You',
        time: ticket.createdAt,
      ));
    }

    for (final r in ticket.replies ?? <TicketReply>[]) {
      bubbles.add(_buildBubble(
        message: r.message,
        isFromSupport: r.isStaff,
        label: r.isStaff ? 'Support' : 'You',
        time: r.createdAt,
      ));
    }

    return bubbles;
  }

  Widget _buildBubble({
    required String message,
    required bool isFromSupport,
    required String label,
    String? time,
  }) {
    final align = isFromSupport ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    final bg = isFromSupport ? netflixRed : netflixDarkLighter;
    final margin = isFromSupport
        ? const EdgeInsets.only(left: 48, right: 8, top: 6, bottom: 6)
        : const EdgeInsets.only(left: 8, right: 48, top: 6, bottom: 6);

    return Padding(
      padding: margin,
      child: Align(
        alignment: isFromSupport ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: align,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(14),
                  topRight: const Radius.circular(14),
                  bottomLeft: Radius.circular(isFromSupport ? 14 : 4),
                  bottomRight: Radius.circular(isFromSupport ? 4 : 14),
                ),
              ),
              child: Text(
                message,
                style: const TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '$label${time != null && time.isNotEmpty ? ' · $time' : ''}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: netflixGrey,
                    fontSize: 12,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: netflixDark,
      appBar: AppBar(
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_ticket?.subject ?? 'Ticket'),
            if (_ticket != null)
              Text(
                'Live chat · updates every second',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: netflixGrey,
                      fontSize: 12,
                    ),
              ),
          ],
        ),
      ),
      body: _loading && _ticket == null
          ? Center(child: CircularProgressIndicator(color: netflixRed))
          : _ticket == null
              ? const Center(child: Text('Ticket not found'))
              : Column(
                  children: [
                    Expanded(
                      child: ListView(
                        controller: _scrollController,
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 16),
                        children: [
                          Text(
                            '${_ticket!.status} · ${_ticket!.priority}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: netflixGrey),
                          ),
                          const SizedBox(height: 12),
                          ..._buildMessageBubbles(),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.only(
                        left: 16,
                        right: 16,
                        top: 12,
                        bottom: 12 + MediaQuery.of(context).padding.bottom,
                      ),
                      color: netflixDarkLighter,
                      child: SafeArea(
                        top: false,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _replyController,
                                decoration: const InputDecoration(
                                  hintText: 'Type your message',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                ),
                                maxLines: 3,
                                minLines: 1,
                              ),
                            ),
                            const SizedBox(width: 12),
                            IconButton.filled(
                              onPressed: _sending
                                  ? null
                                  : () async {
                                      final msg = _replyController.text.trim();
                                      if (msg.isEmpty) return;
                                      setState(() => _sending = true);
                                      try {
                                        await context.read<TicketsRepository>().addReply(
                                              widget.ticketId,
                                              msg,
                                            );
                                        _replyController.clear();
                                        await _load(silent: true);
                                      } catch (e) {
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text(e.toString())),
                                          );
                                        }
                                      } finally {
                                        if (mounted) setState(() => _sending = false);
                                      }
                                    },
                              icon: _sending
                                  ? SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.send),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

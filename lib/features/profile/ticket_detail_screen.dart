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
  final _replyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _replyController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final repo = context.read<TicketsRepository>();
      final t = await repo.getTicket(widget.ticketId);
      if (mounted) {
        setState(() {
          _ticket = t;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: netflixDark,
      appBar: AppBar(title: Text(_ticket?.subject ?? 'Ticket')),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: netflixRed))
          : _ticket == null
              ? const Center(child: Text('Ticket not found'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _ticket!.subject,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_ticket!.status} · ${_ticket!.priority}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (_ticket!.message != null) ...[
                        const SizedBox(height: 16),
                        Text(_ticket!.message!),
                      ],
                      if (_ticket!.replies != null && _ticket!.replies!.isNotEmpty) ...[
                        const SizedBox(height: 24),
                        Text(
                          'Replies',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        ..._ticket!.replies!.map((r) => Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Card(
                                child: ListTile(
                                  title: Text(r.message),
                                  subtitle: Text(
                                    '${r.isStaff ? "Staff" : "You"} · ${r.createdAt ?? ""}',
                                    style: Theme.of(context).textTheme.bodySmall,
                                  ),
                                ),
                              ),
                            )),
                      ],
                      const SizedBox(height: 24),
                      TextField(
                        controller: _replyController,
                        decoration: const InputDecoration(
                          labelText: 'Add reply',
                          hintText: 'Type your message',
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () async {
                          final msg = _replyController.text.trim();
                          if (msg.isEmpty) return;
                          try {
                            await context.read<TicketsRepository>().addReply(
                                  widget.ticketId,
                                  msg,
                                );
                            _replyController.clear();
                            _load();
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(e.toString())),
                              );
                            }
                          }
                        },
                        child: const Text('Send reply'),
                      ),
                    ],
                  ),
                ),
    );
  }
}

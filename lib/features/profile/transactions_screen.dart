import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../app/providers.dart';
import '../../data/models/transaction.dart';
import '../../data/models/config.dart';
import '../../data/repositories/transactions_repo.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  List<Transaction> _transactions = [];
  List<Plan> _plans = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final repo = context.read<TransactionsRepository>();
      final config = context.read<ConfigProvider>().config;
      final tx = await repo.getTransactions();
      final plans = config?.plans ?? [];
      if (mounted) {
        setState(() {
          _transactions = tx;
          _plans = plans;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: netflixDark,
      appBar: AppBar(
        title: const Text('Subscription & Payments'),
        actions: [
          TextButton(
            onPressed: _loading ? null : () => _showUpgradeSheet(context),
            child: const Text('Upgrade'),
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator(color: netflixRed))
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(_error!),
                      TextButton(onPressed: _load, child: const Text('Retry')),
                    ],
                  ),
                )
              : _transactions.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.receipt_long, size: 64, color: netflixGrey),
                          const SizedBox(height: 16),
                          Text(
                            'No transactions yet',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () => _showUpgradeSheet(context),
                            child: const Text('Upgrade plan'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: _transactions.length,
                      itemBuilder: (context, index) {
                        final t = _transactions[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(t.planName ?? t.planId),
                            subtitle: Text(
                              '${t.status} · ${t.paymentMethod ?? ''}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            trailing: _statusChip(t.status),
                          ),
                        );
                      },
                    ),
    );
  }

  Widget _statusChip(String status) {
    Color color = netflixGrey;
    if (status == 'approved') color = Colors.green;
    if (status == 'rejected') color = netflixRed;
    if (status == 'pending') color = Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
      ),
    );
  }

  void _showUpgradeSheet(BuildContext context) {
    if (_plans.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plans not loaded')),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      backgroundColor: netflixDarkLighter,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Choose a plan',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ..._plans.map((plan) => ListTile(
                  title: Text(plan.name),
                  subtitle: Text('${plan.price} ${plan.currency}/month'),
                  trailing: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(ctx);
                      _createTransaction(context, plan.id);
                    },
                    child: const Text('Select'),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Future<void> _createTransaction(BuildContext context, String planId) async {
    final method = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: netflixDarkLighter,
        title: const Text('Payment method'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('bKash'),
              onTap: () => Navigator.pop(ctx, 'bKash'),
            ),
            ListTile(
              title: const Text('Nagad'),
              onTap: () => Navigator.pop(ctx, 'Nagad'),
            ),
            ListTile(
              title: const Text('Rocket'),
              onTap: () => Navigator.pop(ctx, 'Rocket'),
            ),
          ],
        ),
      ),
    );
    if (method == null || !context.mounted) return;
    try {
      await context.read<TransactionsRepository>().createTransaction(
            planId: planId,
            paymentMethod: method,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request submitted. We will confirm soon.')),
        );
        _load();
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }
}

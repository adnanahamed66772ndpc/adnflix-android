import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../app/providers.dart';
import '../../data/models/transaction.dart';
import '../../data/models/config.dart';
import '../../data/repositories/config_repo.dart';
import '../../data/repositories/transactions_repo.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  List<Transaction> _transactions = [];
  List<Plan> _plans = [];
  List<PaymentMethod> _paymentMethods = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() {
      _loading = true;
      _error = null;
    });

    var plans = <Plan>[];
    var transactions = <Transaction>[];

    try {
      final configRepo = context.read<ConfigRepository>();
      final txRepo = context.read<TransactionsRepository>();

      final config = await configRepo.getConfig();
      plans = config.plans ?? [];
      if (plans.isEmpty) {
        plans = await configRepo.getPlans();
      }
      var paymentMethods = config.paymentMethods ?? [];
      if (paymentMethods.isEmpty) {
        paymentMethods = await configRepo.getPaymentMethods();
      }

      try {
        transactions = await txRepo.getTransactions();
      } catch (_) {
        transactions = [];
      }

      if (!mounted) return;
      setState(() {
        _transactions = transactions;
        _plans = plans;
        _paymentMethods = paymentMethods;
        _loading = false;
        _error = null;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _transactions = [];
        _plans = plans;
        _paymentMethods = [];
        _loading = false;
        _error = null;
      });
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
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.cloud_off, size: 48, color: Colors.white54),
                        const SizedBox(height: 16),
                        Text(
                          _sanitizeError(_error!),
                          style: const TextStyle(color: Colors.white70),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        TextButton.icon(
                          onPressed: _load,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                        ),
                      ],
                    ),
                  ),
                )
              : _transactions.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long, size: 64, color: Colors.white54),
                            const SizedBox(height: 16),
                            Text(
                              'No transactions yet',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _plans.isEmpty
                                  ? 'Tap Retry to load plans, then upgrade.'
                                  : 'Upgrade your plan to get more features.',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton(
                              onPressed: () => _showUpgradeSheet(context),
                              child: const Text('Upgrade plan'),
                            ),
                            if (_plans.isEmpty) ...[
                              const SizedBox(height: 12),
                              TextButton(
                                onPressed: _load,
                                child: const Text('Retry'),
                              ),
                            ],
                          ],
                        ),
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
      bottomNavigationBar: _plans.isEmpty && !_loading
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  'Plans could not be loaded. Check connection and tap Retry.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white54),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : null,
    );
  }

  static String _sanitizeError(String message) {
    if (message.contains('DioException') ||
        message.contains('status code') ||
        message.contains('400') ||
        message.length > 120) {
      return 'Could not load. Tap Retry.';
    }
    return message;
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
                      _createTransaction(context, plan);
                    },
                    child: const Text('Select'),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Future<void> _createTransaction(BuildContext context, Plan plan) async {
    if (plan.price <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Free plan does not require payment.')),
      );
      return;
    }
    final method = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: netflixDarkLighter,
        title: const Text('Payment method'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _paymentMethods.isNotEmpty
              ? _paymentMethods
                  .map((pm) => ListTile(
                        title: Text(pm.name),
                        onTap: () => Navigator.pop(ctx, pm.id.isNotEmpty ? pm.id : pm.name),
                      ))
                  .toList()
              : [
                  ListTile(title: const Text('bKash'), onTap: () => Navigator.pop(ctx, 'bKash')),
                  ListTile(title: const Text('Nagad'), onTap: () => Navigator.pop(ctx, 'Nagad')),
                  ListTile(title: const Text('Rocket'), onTap: () => Navigator.pop(ctx, 'Rocket')),
                ],
        ),
      ),
    );
    if (method == null || !context.mounted) return;

    PaymentMethod? selectedPm;
    final methodLower = method.toLowerCase();
    for (final p in _paymentMethods) {
      if (p.id.toLowerCase() == methodLower || p.name.toLowerCase() == methodLower) {
        selectedPm = p;
        break;
      }
    }
    final sendMoneyNumber = selectedPm?.number?.trim();
    final paymentMethodName = selectedPm?.name ?? method;

    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => _PaymentFormDialog(
        planName: plan.name,
        amount: '${plan.price} ${plan.currency}',
        paymentMethodName: paymentMethodName,
        sendMoneyNumber: sendMoneyNumber,
      ),
    );
    if (result == null || !context.mounted) return;

    final transactionId = result['transactionId']?.trim() ?? '';
    final senderNumber = result['senderNumber']?.trim();

    if (transactionId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter your transaction ID.')),
      );
      return;
    }

    try {
      await context.read<TransactionsRepository>().createTransaction(
            planId: plan.id,
            paymentMethod: method,
            transactionId: transactionId,
            amount: plan.price,
            senderNumber: senderNumber?.isEmpty == true ? null : senderNumber,
          );
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request submitted. We will confirm soon.')),
        );
        _load();
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Request failed. Try again.')),
        );
      }
    }
  }
}

class _PaymentFormDialog extends StatefulWidget {
  const _PaymentFormDialog({
    required this.planName,
    required this.amount,
    required this.paymentMethodName,
    this.sendMoneyNumber,
  });

  final String planName;
  final String amount;
  final String paymentMethodName;
  final String? sendMoneyNumber;

  @override
  State<_PaymentFormDialog> createState() => _PaymentFormDialogState();
}

class _PaymentFormDialogState extends State<_PaymentFormDialog> {
  final _transactionIdController = TextEditingController();
  final _senderNumberController = TextEditingController();

  @override
  void dispose() {
    _transactionIdController.dispose();
    _senderNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: netflixDarkLighter,
      title: const Text('Payment details'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${widget.planName} · ${widget.amount}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Text(
              'Send money to (${widget.paymentMethodName})',
              style: const TextStyle(fontSize: 12, color: Colors.white70),
            ),
            const SizedBox(height: 4),
            if (widget.sendMoneyNumber != null && widget.sendMoneyNumber!.isNotEmpty)
              Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: SelectableText(
                        widget.sendMoneyNumber!,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: widget.sendMoneyNumber!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Number copied'), duration: Duration(seconds: 2)),
                      );
                    },
                    icon: const Icon(Icons.copy),
                    tooltip: 'Copy',
                  ),
                ],
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'Use the number shown in the app or contact support.',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ),
            const SizedBox(height: 16),
            TextField(
              controller: _transactionIdController,
              decoration: const InputDecoration(
                labelText: 'Transaction ID *',
                hintText: 'From bKash/Nagad/Rocket',
              ),
              keyboardType: TextInputType.text,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _senderNumberController,
              decoration: const InputDecoration(
                labelText: 'Your phone number (optional)',
                hintText: '01XXXXXXXXX',
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, {
              'transactionId': _transactionIdController.text,
              'senderNumber': _senderNumberController.text,
            });
          },
          child: const Text('Submit'),
        ),
      ],
    );
  }
}

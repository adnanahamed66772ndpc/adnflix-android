import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../app/theme.dart';
import '../../app/router.dart';
import '../../app/providers.dart';
import '../../core/constants.dart';
import '../../data/models/user.dart';
import 'transactions_screen.dart';
import 'tickets_screen.dart';
import 'page_view_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: netflixDark,
      appBar: AppBar(title: const Text('Profile')),
      body: auth.loading && !auth.isLoggedIn
          ? Center(child: CircularProgressIndicator(color: netflixRed))
          : auth.isLoggedIn
              ? _ProfileBody(user: auth.user!)
              : _GuestProfileBody(),
    );
  }
}

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({required this.user});

  final User user;

  static String _planLabel(String plan) {
    switch (plan) {
      case 'premium': return 'Premium';
      case 'with-ads': return 'With Ads';
      default: return 'Free';
    }
  }

  static String _expiryText(User user) {
    if (user.subscriptionPlan == 'free') return '';
    if (user.daysUntilExpiry != null) {
      final d = user.daysUntilExpiry!;
      if (d <= 0) return 'Expires soon';
      if (d == 1) return 'Expires in 1 day';
      return 'Expires in $d days';
    }
    if (user.subscriptionExpiresAt != null) {
      final d = user.subscriptionExpiresAt!;
      return 'Expires ${d.day}/${d.month}/${d.year}';
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    final plan = user.subscriptionPlan;
    final planLabel = _planLabel(plan);
    final expiryText = _expiryText(user);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: netflixRed,
                child: Text(
                  (user.displayName ?? user.email).toUpperCase().substring(0, 1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName ?? user.email ?? 'User',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        user.email,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: netflixRed.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          planLabel,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: netflixRed,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                      if (expiryText.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          expiryText,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Colors.white54,
                                fontSize: 12,
                              ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        _MenuItem(
          icon: Icons.payment,
          title: 'Subscription & Payments',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const TransactionsScreen(),
            ),
          ),
        ),
        _MenuItem(
          icon: Icons.support_agent,
          title: 'Support Tickets',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const TicketsScreen(),
            ),
          ),
        ),
        _MenuItem(
          icon: Icons.description,
          title: 'Terms of Use',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const PageViewScreen(pageKey: 'terms'),
            ),
          ),
        ),
        _MenuItem(
          icon: Icons.privacy_tip,
          title: 'Privacy Policy',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const PageViewScreen(pageKey: 'privacy'),
            ),
          ),
        ),
        _MenuItem(
          icon: Icons.help,
          title: 'Help',
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const PageViewScreen(pageKey: 'help'),
            ),
          ),
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Plans, payment numbers, Terms, Privacy & Support load from the same API as the website. Paid plans last 30 days, then auto-downgrade to Free.',
                style: TextStyle(fontSize: 11, color: netflixGrey),
              ),
              const SizedBox(height: 4),
              Text('App v${Constants.appVersion}', style: TextStyle(fontSize: 10, color: netflixGrey)),
            ],
          ),
        ),
        ListTile(
          leading: Icon(Icons.logout, color: netflixRed),
          title: Text('Sign Out', style: TextStyle(color: netflixRed)),
          onTap: () async {
            await context.read<AuthProvider>().logout();
            if (context.mounted) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppRouter.login,
                (route) => false,
              );
            }
          },
        ),
      ],
    );
  }
}

class _GuestProfileBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_outline, size: 80, color: netflixGrey),
            const SizedBox(height: 24),
            Text(
              'Sign in to manage your profile and subscription',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pushNamed(AppRouter.login),
              child: const Text('Sign In'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.of(context).pushNamed(AppRouter.register),
              child: const Text('Create account'),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: netflixGrey),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle!, style: const TextStyle(fontSize: 11, color: Colors.white54)) : null,
      trailing: Icon(Icons.chevron_right, color: netflixGrey),
      onTap: onTap,
    );
  }
}

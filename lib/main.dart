import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/theme.dart';
import 'app/router.dart';
import 'app/providers.dart';
import 'app/splash_screen.dart';
import 'app/maintenance_screen.dart';
import 'data/repositories/config_repo.dart';
import 'data/repositories/auth_repo.dart';
import 'data/repositories/content_repo.dart';
import 'data/repositories/playback_repo.dart';
import 'data/repositories/watchlist_repo.dart';
import 'data/repositories/transactions_repo.dart';
import 'data/repositories/tickets_repo.dart';
import 'data/repositories/pages_repo.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AdnflixApp());
}

class AdnflixApp extends StatelessWidget {
  const AdnflixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ConfigProvider()),
        ChangeNotifierProvider(create: (_) => ContentProvider()),
        ChangeNotifierProxyProvider<AuthProvider, PlaybackProvider>(
          create: (_) => PlaybackProvider(),
          update: (_, auth, prev) {
            final p = prev ?? PlaybackProvider(authProvider: auth);
            p.setAuth(auth);
            return p;
          },
        ),
        ChangeNotifierProxyProvider<AuthProvider, WatchlistProvider>(
          create: (_) => WatchlistProvider(),
          update: (_, auth, prev) {
            final p = prev ?? WatchlistProvider(authProvider: auth);
            p.setAuth(auth);
            return p;
          },
        ),
        Provider(create: (_) => ConfigRepository()),
        Provider(create: (_) => AuthRepository()),
        Provider(create: (_) => ContentRepository()),
        Provider(create: (_) => PlaybackRepository()),
        Provider(create: (_) => WatchlistRepository()),
        Provider(create: (_) => TransactionsRepository()),
        Provider(create: (_) => TicketsRepository()),
        Provider(create: (_) => PagesRepository()),
      ],
      child: MaterialApp(
        title: 'ADNFLIX',
        debugShowCheckedModeBanner: false,
        theme: netflixTheme,
        initialRoute: AppRouter.splash,
        onGenerateRoute: AppRouter.onGenerateRoute,
        home: const BootstrapScreen(),
      ),
    );
  }
}

class BootstrapScreen extends StatefulWidget {
  const BootstrapScreen({super.key});

  @override
  State<BootstrapScreen> createState() => _BootstrapScreenState();
}

class _BootstrapScreenState extends State<BootstrapScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init();
    });
  }

  Future<void> _init() async {
    final config = context.read<ConfigProvider>();
    final auth = context.read<AuthProvider>();
    final content = context.read<ContentProvider>();

    await config.load();
    await auth.init();
    await content.load();

    if (!mounted) return;

    if (config.maintenanceMode) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => MaintenanceScreen(
            message: config.config?.maintenanceMessage,
          ),
        ),
      );
      return;
    }

    if (auth.isLoggedIn) {
      Navigator.of(context).pushReplacementNamed(AppRouter.home);
    } else {
      Navigator.of(context).pushReplacementNamed(AppRouter.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}

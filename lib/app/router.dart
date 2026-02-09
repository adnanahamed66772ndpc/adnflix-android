import 'package:flutter/material.dart';

import '../features/auth/login_screen.dart';
import '../features/auth/register_screen.dart';
import '../features/browse/browse_screen.dart';
import '../features/home/home_screen.dart';
import '../features/player/player_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/title/title_details_screen.dart';
import '../features/watchlist/watchlist_screen.dart';
import 'main_shell.dart';

class AppRouter {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String browse = '/browse';
  static const String watchlist = '/watchlist';
  static const String profile = '/profile';
  static const String titleDetails = '/title';
  static const String player = '/player';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    final args = settings.arguments as Map<String, dynamic>? ?? {};
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const MainShell());
      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case register:
        return MaterialPageRoute(builder: (_) => const RegisterScreen());
      case home:
        return MaterialPageRoute(builder: (_) => const MainShell(initialIndex: 0));
      case browse:
        return MaterialPageRoute(builder: (_) => const MainShell(initialIndex: 1));
      case watchlist:
        return MaterialPageRoute(builder: (_) => const MainShell(initialIndex: 2));
      case profile:
        return MaterialPageRoute(builder: (_) => const MainShell(initialIndex: 3));
      case titleDetails:
        return MaterialPageRoute(
          builder: (_) => TitleDetailsScreen(titleId: args['titleId'] as String? ?? ''),
        );
      case player:
        return MaterialPageRoute(
          builder: (_) => PlayerScreen(
            titleId: args['titleId'] as String? ?? '',
            videoPath: args['videoPath'] as String? ?? '',
            episodeId: args['episodeId'] as String?,
            episodeName: args['episodeName'] as String?,
            titleName: args['titleName'] as String?,
            isSeries: args['isSeries'] as bool? ?? false,
            startPositionSeconds: (args['startPositionSeconds'] as int?) ?? 0,
          ),
        );
      default:
        return MaterialPageRoute(builder: (_) => const MainShell());
    }
  }
}

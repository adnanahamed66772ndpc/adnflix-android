import 'package:flutter/foundation.dart';

import '../core/network/api_client.dart';
import '../core/network/token_storage.dart';
import '../data/models/category.dart' as data_models;
import '../data/models/config.dart';
import '../data/models/playback.dart';
import '../data/models/title_model.dart';
import '../data/models/user.dart';
import '../data/repositories/ads_repo.dart';
import '../data/repositories/auth_repo.dart';
import '../data/repositories/config_repo.dart';
import '../data/repositories/content_repo.dart';
import '../data/repositories/pages_repo.dart';
import '../data/repositories/playback_repo.dart';
import '../data/repositories/tickets_repo.dart';
import '../data/repositories/transactions_repo.dart';
import '../data/repositories/watchlist_repo.dart';

class AuthProvider with ChangeNotifier {
  AuthProvider({AuthRepository? repo}) : _repo = repo ?? AuthRepository();

  final AuthRepository _repo;
  User? _user;
  bool _loading = true;

  User? get user => _user;
  bool get loading => _loading;
  bool get isLoggedIn => _user != null;

  Future<void> init() async {
    _loading = true;
    notifyListeners();
    _user = await _repo.getMe();
    _loading = false;
    notifyListeners();
  }

  Future<User> login(String email, String password) async {
    _user = await _repo.login(email, password);
    notifyListeners();
    return _user!;
  }

  Future<User> register(String email, String password, {String? displayName}) async {
    _user = await _repo.register(email, password, displayName: displayName);
    notifyListeners();
    return _user!;
  }

  Future<void> logout() async {
    await _repo.logout();
    _user = null;
    notifyListeners();
  }

  Future<void> refreshUser() async {
    _user = await _repo.getMe();
    notifyListeners();
  }
}

class ConfigProvider with ChangeNotifier {
  ConfigProvider({ConfigRepository? repo}) : _repo = repo ?? ConfigRepository();

  final ConfigRepository _repo;
  AppConfig? _config;
  String? _error;
  bool _loading = true;

  AppConfig? get config => _config;
  String? get error => _error;
  bool get loading => _loading;
  bool get maintenanceMode => _config?.maintenanceMode ?? false;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      _config = await _repo.getConfig();
    } catch (_) {
      _config = AppConfig(maintenanceMode: false, plans: [], paymentMethods: []);
    }
    _loading = false;
    notifyListeners();
  }
}

class ContentProvider with ChangeNotifier {
  ContentProvider({
    ContentRepository? repo,
  }) : _contentRepo = repo ?? ContentRepository();

  final ContentRepository _contentRepo;
  List<TitleModel> _titles = [];
  List<data_models.Category> _categories = [];
  final Map<String, TitleModel> _titleCache = {};
  bool _loading = true;
  String? _error;

  List<TitleModel> get titles => _titles;
  List<data_models.Category> get categories => _categories;
  bool get loading => _loading;
  String? get error => _error;

  ContentRepository get contentRepo => _contentRepo;

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _contentRepo.getTitles(),
        _contentRepo.getCategories(),
      ]);
      _titles = results[0] as List<TitleModel>;
      _categories = results[1] as List<data_models.Category>;
      _categories.sort((a, b) => (a.sortOrder ?? 0).compareTo(b.sortOrder ?? 0));
    } catch (e) {
      _error = e.toString();
    }
    _loading = false;
    notifyListeners();
  }

  List<TitleModel> titlesByCategory(String categoryId) {
    return _titles
        .where((t) => t.categoryIds.contains(categoryId))
        .toList();
  }

  Future<TitleModel?> getTitle(String id) async {
    if (_titleCache.containsKey(id)) return _titleCache[id];
    final t = await _contentRepo.getTitle(id);
    if (t != null) _titleCache[id] = t;
    return t;
  }
}

class PlaybackProvider with ChangeNotifier {
  PlaybackProvider({
    PlaybackRepository? repo,
    AuthProvider? authProvider,
  })  : _repo = repo ?? PlaybackRepository(),
        _authProvider = authProvider;

  final PlaybackRepository _repo;
  AuthProvider? _authProvider;
  List<PlaybackProgress> _progress = [];
  bool _loading = false;

  List<PlaybackProgress> get progress => _progress;
  bool get loading => _loading;

  void setAuth(AuthProvider? a) {
    _authProvider = a;
  }

  bool get hasProgress => _authProvider?.isLoggedIn == true && _progress.isNotEmpty;

  Future<void> load() async {
    if (_authProvider?.isLoggedIn != true) {
      _progress = [];
      notifyListeners();
      return;
    }
    _loading = true;
    notifyListeners();
    try {
      _progress = await _repo.getPlaybackProgress();
    } catch (_) {
      _progress = [];
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> saveProgress({
    required String titleId,
    String? episodeId,
    required int progressSeconds,
    required int durationSeconds,
  }) async {
    if (_authProvider?.isLoggedIn != true) return;
    try {
      await _repo.saveProgress(
        titleId: titleId,
        episodeId: episodeId,
        progressSeconds: progressSeconds,
        durationSeconds: durationSeconds,
      );
    } catch (_) {}
  }
}

class WatchlistProvider with ChangeNotifier {
  WatchlistProvider({
    WatchlistRepository? repo,
    AuthProvider? authProvider,
  })  : _repo = repo ?? WatchlistRepository(),
        _authProvider = authProvider;

  final WatchlistRepository _repo;
  AuthProvider? _authProvider;

  void setAuth(AuthProvider? a) {
    _authProvider = a;
  }

  List<String> _ids = [];
  bool _loading = false;

  List<String> get ids => _ids;
  bool get loading => _loading;

  bool isInWatchlist(String titleId) => _ids.contains(titleId);

  Future<void> load() async {
    if (_authProvider?.isLoggedIn != true) {
      _ids = [];
      notifyListeners();
      return;
    }
    _loading = true;
    notifyListeners();
    try {
      _ids = await _repo.getWatchlistIds();
    } catch (_) {
      _ids = [];
    }
    _loading = false;
    notifyListeners();
  }

  Future<void> toggle(String titleId) async {
    if (_authProvider?.isLoggedIn != true) return;
    final wasInList = _ids.contains(titleId);
    if (wasInList) {
      _ids.remove(titleId);
      notifyListeners();
      try {
        await _repo.removeFromWatchlist(titleId);
      } catch (_) {
        _ids.add(titleId);
        notifyListeners();
      }
    } else {
      _ids.add(titleId);
      notifyListeners();
      try {
        await _repo.addToWatchlist(titleId);
      } catch (_) {
        _ids.remove(titleId);
        notifyListeners();
      }
    }
  }
}


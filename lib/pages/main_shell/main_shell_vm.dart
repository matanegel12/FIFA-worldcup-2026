import 'package:mvvm_remepy/observer/observer.dart';
import 'package:mvvm_remepy/view_model.dart';

import '../../services/repositories/auth_repository/auth_repository.dart';
import '../../services/repositories/games_repository/games_repository.dart';
import '../../services/repositories/guesses_repository/guesses_repository.dart';
import '../../services/repositories/leaderboard_repository/leaderboard_repository.dart';
import '../../services/sync/game_sync_service.dart';
import 'main_shell_model.dart';

class MainShellViewModel extends ViewModel<MainShellModel> {
  final GamesRepository gamesRepository;
  final GuessesRepository guessesRepository;
  final LeaderboardRepository leaderboardRepository;
  final AuthRepository authRepository;
  final GameSyncService? _gameSyncService;

  MainShellViewModel({
    required this.gamesRepository,
    required this.guessesRepository,
    required this.leaderboardRepository,
    required this.authRepository,
    GameSyncService? gameSyncService,
  })  : _gameSyncService = gameSyncService,
        super(model: MainShellModel());

  /// Receives userId and userEmail from auth_gate via route arguments.
  @override
  void onViewLoaded(dynamic data) {
    if (data is Map) {
      model.userId = (data['userId'] as String?) ?? '';
      model.userEmail = (data['email'] as String?) ?? '';
      notify();
    }
    _runStartupSync();
  }

  /// Switches the active tab. Ignores out-of-range indices.
  void onTabChanged(int index) {
    if (index < 0 || index > 3) return;
    model.currentIndex = index;
    notify();
  }

  void onAdminTapped() {
    notifyNavigate(NavigateModel(routeName: '/admin'));
  }

  // ── Private helpers ───────────────────────────────────────────────────────

  void _runStartupSync() {
    _gameSyncService?.syncIfNeeded();
  }
}

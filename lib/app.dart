import 'package:flutter/material.dart';
import 'package:mvvm_remepy/base_page.dart';

import 'app_theme.dart';
import 'pages/admin/admin_panel_page.dart';
import 'pages/admin/admin_panel_vm.dart';
import 'pages/auth/auth_gate/auth_gate_page.dart';
import 'pages/auth/auth_gate/auth_gate_vm.dart';
import 'pages/auth/sign_in/sign_in_page.dart';
import 'pages/auth/sign_in/sign_in_vm.dart';
import 'pages/auth/sign_up/sign_up_page.dart';
import 'pages/auth/sign_up/sign_up_vm.dart';
import 'pages/main_shell/main_shell_page.dart';
import 'pages/main_shell/main_shell_vm.dart';
import 'services/repositories/auth_repository/auth_repository.dart';
import 'services/repositories/auth_repository/firestore_auth_repository.dart';
import 'services/repositories/games_repository/firestore_games_repository.dart';
import 'services/repositories/games_repository/games_repository.dart';
import 'services/repositories/guesses_repository/firestore_guesses_repository.dart';
import 'services/repositories/guesses_repository/guesses_repository.dart';
import 'services/repositories/leaderboard_repository/firestore_leaderboard_repository.dart';
import 'services/repositories/leaderboard_repository/leaderboard_repository.dart';
import 'services/sync/game_sync_service.dart';

class App extends StatelessWidget {
  const App({super.key});

  static final AuthRepository authRepository = FirestoreAuthRepository();
  static final GamesRepository gamesRepository = FirestoreGamesRepository();
  static final GuessesRepository guessesRepository = FirestoreGuessesRepository();
  static final LeaderboardRepository leaderboardRepository = FirestoreLeaderboardRepository();
  static final GameSyncService gameSyncService = GameSyncService();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'World Cup 2026 Predictions',
      navigatorObservers: [routeObserver],
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: Theme(
        data: AppTheme.auth,
        child: AuthGatePage(
          viewModel: AuthGateViewModel(authRepository: authRepository),
        ),
      ),
      routes: {
        '/sign-in': (_) => Theme(
              data: AppTheme.auth,
              child: SignInPage(
                viewModel: SignInViewModel(authRepository: authRepository),
              ),
            ),
        '/sign-up': (_) => Theme(
              data: AppTheme.auth,
              child: SignUpPage(
                viewModel: SignUpViewModel(authRepository: authRepository),
              ),
            ),
        '/home': (_) => MainShellPage(
              viewModel: MainShellViewModel(
                gamesRepository: gamesRepository,
                guessesRepository: guessesRepository,
                leaderboardRepository: leaderboardRepository,
                gameSyncService: gameSyncService,
              ),
            ),
        '/admin': (_) => AdminPanelPage(
              viewModel: AdminPanelViewModel(),
            ),
      },
    );
  }
}

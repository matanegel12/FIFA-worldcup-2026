import 'package:flutter/material.dart';
import 'package:mvvm_remepy/base_page.dart';

import 'app_theme.dart';
import 'pages/auth/auth_gate/auth_gate_page.dart';
import 'pages/auth/auth_gate/auth_gate_vm.dart';
import 'pages/auth/sign_in/sign_in_page.dart';
import 'pages/auth/sign_in/sign_in_vm.dart';
import 'pages/auth/sign_up/sign_up_page.dart';
import 'pages/auth/sign_up/sign_up_vm.dart';
import 'pages/main_shell/main_shell_page.dart';
import 'pages/main_shell/main_shell_vm.dart';
import 'services/mock/mock_store.dart';
import 'services/repositories/auth_repository/auth_repository.dart';
//import 'services/repositories/auth_repository/firestore_auth_repository.dart';
import 'services/repositories/auth_repository/mock_auth_repository.dart';
import 'services/repositories/games_repository/mock_games_repository.dart';
import 'services/repositories/guesses_repository/mock_guesses_repository.dart';
import 'services/repositories/leaderboard_repository/mock_leaderboard_repository.dart';

class App extends StatelessWidget {
  const App({super.key});

  static final AuthRepository authRepository = MockAuthRepository();

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
                gamesRepository: MockGamesRepository(),
                guessesRepository: MockGuessesRepository(),
                leaderboardRepository: MockLeaderboardRepository(),
                userId: MockStore.instance.currentUserId ?? '',
              ),
            ),
      },
    );
  }
}

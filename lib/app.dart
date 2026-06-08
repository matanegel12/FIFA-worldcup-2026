import 'package:flutter/material.dart';
import 'package:mvvm_remepy/base_page.dart';

import 'app_theme.dart';
import 'pages/auth/auth_gate/auth_gate_page.dart';
import 'pages/auth/auth_gate/auth_gate_vm.dart';
import 'pages/auth/sign_in/sign_in_page.dart';
import 'pages/auth/sign_in/sign_in_vm.dart';
import 'pages/auth/sign_up/sign_up_page.dart';
import 'pages/auth/sign_up/sign_up_vm.dart';
import 'pages/leaderboard/leaderboard_page.dart';
import 'pages/leaderboard/leaderboard_vm.dart';
import 'pages/predictions/predictions_page.dart';
import 'pages/predictions/predictions_vm.dart';
import 'pages/results/results_page.dart';
import 'pages/results/results_vm.dart';
import 'pages/upcoming_games/upcoming_games_page.dart';
import 'pages/upcoming_games/upcoming_games_vm.dart';
import 'services/mock/mock_store.dart';
import 'services/repositories/auth_repository/auth_repository.dart';
//import 'services/repositories/auth_repository/firestore_auth_repository.dart';
import 'services/repositories/auth_repository/mock_auth_repository.dart';
import 'services/repositories/games_repository/mock_games_repository.dart';
import 'services/repositories/guesses_repository/mock_guesses_repository.dart';
import 'services/repositories/leaderboard_repository/mock_leaderboard_repository.dart';

class App extends StatelessWidget {
  const App({super.key});

  // Single shared auth repository instance for the whole app.
  // In a larger app this would be provided via dependency injection.
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
        // '/home': (_) => UpcomingGamesPage(
        //       viewModel: UpcomingGamesViewModel(
        //         gamesRepository: MockGamesRepository(),
        //         guessesRepository: MockGuessesRepository(),
        //         userId: MockStore.instance.currentUserId ?? '',
        //       ),
        //     ),
        '/results': (_) => ResultsPage(
              viewModel: ResultsViewModel(
                gamesRepository: MockGamesRepository(),
              ),
            ),
        '/home': (_) => LeaderboardPage(
              viewModel: LeaderboardViewModel(
                leaderboardRepository: MockLeaderboardRepository(),
                userId: MockStore.instance.currentUserId ?? '',
              ),
            ),
        '/predictions': (_) => PredictionsPage(
              viewModel: PredictionsViewModel(
                gamesRepository: MockGamesRepository(),
                guessesRepository: MockGuessesRepository(),
                userId: MockStore.instance.currentUserId ?? '',
              ),
            ),
      },
    );
  }
}

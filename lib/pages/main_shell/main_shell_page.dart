import 'package:flutter/material.dart';
import 'package:mvvm_remepy/base_page.dart';

import '../../app_theme.dart';
import '../../pages/leaderboard/leaderboard_page.dart';
import '../../pages/leaderboard/leaderboard_vm.dart';
import '../../pages/predictions/predictions_page.dart';
import '../../pages/predictions/predictions_vm.dart';
import '../../pages/results/results_page.dart';
import '../../pages/results/results_vm.dart';
import '../../pages/upcoming_games/upcoming_games_page.dart';
import '../../pages/upcoming_games/upcoming_games_vm.dart';
import '../../services/admin/admin_gate.dart';
import 'widgets/main_bottom_nav.dart';
import 'main_shell_model.dart';
import 'main_shell_vm.dart';

class MainShellPage extends BasePage<MainShellModel, MainShellViewModel> {
  const MainShellPage({required super.viewModel, super.key});

  @override
  BasePageState<MainShellModel, MainShellViewModel, MainShellPage>
  createState() => _MainShellPageState();
}

class _MainShellPageState
    extends BasePageState<MainShellModel, MainShellViewModel, MainShellPage> {
  /// ResultsPage needs no userId — built once in initState.
  late final ResultsPage _resultsPage;

  /// These pages need userId — built lazily after onViewLoaded sets model.userId.
  UpcomingGamesPage? _upcomingGamesPage;
  PredictionsPage? _predictionsPage;
  LeaderboardPage? _leaderboardPage;

  @override
  void initState() {
    super.initState();
    _resultsPage = ResultsPage(
      viewModel: ResultsViewModel(gamesRepository: viewModel.gamesRepository),
    );
  }

  @override
  Color get backgroundColor => Theme.of(context).colorScheme.surface;

  @override
  PreferredSizeWidget? get appBar => null;

  @override
  Widget? get bottomNavigationBar => MainBottomNav(
    onUpcomingTapped: () => viewModel.onTabChanged(0),
    onResultsTapped: () => viewModel.onTabChanged(1),
    onPredictionsTapped: () => viewModel.onTabChanged(2),
    onLeaderboardTapped: () => viewModel.onTabChanged(3),
    currentIndex: model.currentIndex,
  );

  /// FAB is only visible to the admin user.
  @override
  Widget? get floatingActionButton {
    if (!isAdmin(model.userEmail)) return null;
    return FloatingActionButton(
      onPressed: viewModel.onAdminTapped,
      backgroundColor: AppTheme.primary,
      foregroundColor: Colors.white,
      tooltip: 'Admin Panel',
      child: const Icon(Icons.admin_panel_settings),
    );
  }

  @override
  Widget get body {
    // Wait for onViewLoaded to supply userId before building pages that need it.
    // Without this guard the ??= would lock in an empty userId on the first build.
    if (model.userId.isEmpty) {
      return const SizedBox.shrink();
    }

    switch (model.currentIndex) {
      case 0:
        return _upcomingGamesPage ??= UpcomingGamesPage(
          viewModel: UpcomingGamesViewModel(
            gamesRepository: viewModel.gamesRepository,
            guessesRepository: viewModel.guessesRepository,
            authRepository: viewModel.authRepository,
            userId: model.userId,
          ),
        );
      case 1:
        return _resultsPage;
      case 2:
        return _predictionsPage ??= PredictionsPage(
          viewModel: PredictionsViewModel(
            gamesRepository: viewModel.gamesRepository,
            guessesRepository: viewModel.guessesRepository,
            userId: model.userId,
          ),
        );
      case 3:
        return _leaderboardPage ??= LeaderboardPage(
          viewModel: LeaderboardViewModel(
            leaderboardRepository: viewModel.leaderboardRepository,
            userId: model.userId,
          ),
        );
      default:
        return _upcomingGamesPage ??= UpcomingGamesPage(
          viewModel: UpcomingGamesViewModel(
            gamesRepository: viewModel.gamesRepository,
            guessesRepository: viewModel.guessesRepository,
            authRepository: viewModel.authRepository,
            userId: model.userId,
          ),
        );
    }
  }
}

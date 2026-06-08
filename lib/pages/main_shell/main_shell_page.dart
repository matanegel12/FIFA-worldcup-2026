import 'package:flutter/material.dart';
import 'package:mvvm_remepy/base_page.dart';

import '../../pages/leaderboard/leaderboard_page.dart';
import '../../pages/leaderboard/leaderboard_vm.dart';
import '../../pages/predictions/predictions_page.dart';
import '../../pages/predictions/predictions_vm.dart';
import '../../pages/results/results_page.dart';
import '../../pages/results/results_vm.dart';
import '../../pages/upcoming_games/upcoming_games_page.dart';
import '../../pages/upcoming_games/upcoming_games_vm.dart';
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
  late final UpcomingGamesPage _upcomingGamesPage;
  late final ResultsPage _resultsPage;
  late final LeaderboardPage _leaderboardPage;
  late final PredictionsPage _predictionsPage;

  @override
  void initState() {
    super.initState();
    _upcomingGamesPage = UpcomingGamesPage(
      viewModel: UpcomingGamesViewModel(
        gamesRepository: viewModel.gamesRepository,
        guessesRepository: viewModel.guessesRepository,
        userId: viewModel.userId,
      ),
    );
    _resultsPage = ResultsPage(
      viewModel: ResultsViewModel(
        gamesRepository: viewModel.gamesRepository,
      ),
    );
    _leaderboardPage = LeaderboardPage(
      viewModel: LeaderboardViewModel(
        leaderboardRepository: viewModel.leaderboardRepository,
        userId: viewModel.userId,
      ),
    );
    _predictionsPage = PredictionsPage(
      viewModel: PredictionsViewModel(
        gamesRepository: viewModel.gamesRepository,
        guessesRepository: viewModel.guessesRepository,
        userId: viewModel.userId,
      ),
    );
  }

  @override
  Color get backgroundColor => Theme.of(context).colorScheme.surface;

  /// Shell has no own AppBar — each child page provides its own.
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

  @override
  Widget get body {
    switch (model.currentIndex) {
      case 0:
        return _upcomingGamesPage;
      case 1:
        return _resultsPage;
      case 2:
        return _predictionsPage;
      case 3:
        return _leaderboardPage;
      default:
        return _upcomingGamesPage;
    }
  }
}

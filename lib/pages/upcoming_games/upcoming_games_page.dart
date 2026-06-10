import 'package:flutter/material.dart';
import 'package:mvvm_remepy/base_page.dart';

import '../../app_theme.dart';
import '../../models/game.dart';
import '../../models/round_group.dart';
import '../../widgets/shared/page_empty_view.dart';
import '../../widgets/shared/page_error_view.dart';
import '../../widgets/shared/spinning_ball.dart';
import 'upcoming_games_model.dart';
import 'upcoming_games_vm.dart';
import 'widgets/new_results_dialog.dart';
import 'widgets/upcoming_game_card.dart';

class UpcomingGamesPage extends BasePage<UpcomingGamesModel, UpcomingGamesViewModel> {
  const UpcomingGamesPage({required super.viewModel, super.key});

  @override
  BasePageState<UpcomingGamesModel, UpcomingGamesViewModel, UpcomingGamesPage>
      createState() => _UpcomingGamesPageState();
}

class _UpcomingGamesPageState
    extends BasePageState<UpcomingGamesModel, UpcomingGamesViewModel, UpcomingGamesPage> {
  @override
  void onNotify([UpcomingGamesModel? data]) {
    super.onNotify(data);
    if (model.showResultsPopup) {
      model.showResultsPopup = false; // reset immediately before showing
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showResultsDialog();
      });
    }
  }

  Future<void> _showResultsDialog() async {
    // Precache all flag images in parallel before opening the dialog.
    final List<Future<void>> precacheFutures = [
      for (final Game game in model.unseenGames) ...[
        precacheImage(NetworkImage(game.homeTeam.flagUrl), context),
        precacheImage(NetworkImage(game.awayTeam.flagUrl), context),
      ]
    ];
    await Future.wait(precacheFutures, eagerError: false);

    if (!mounted) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => NewResultsDialog(
        unseenGames: model.unseenGames,
        onDismissed: () => viewModel.onPopupDismissed(),
      ),
    );
  }

  @override
  Color get backgroundColor => Theme.of(context).colorScheme.surface;

  @override
  PreferredSizeWidget? get appBar => AppBar(
        title: Text(model.appBarTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Sign out',
            onPressed: viewModel.onSignOut,
          ),
        ],
      );

  @override
  Widget get body {
    if (model.isLoading) return _buildLoading();
    if (model.errorMessage != null) return _buildError();
    if (model.groupedGames.isEmpty) return _buildEmpty();
    return _buildGameList();
  }

  // ── Loading ───────────────────────────────────────────────────────────────

  Widget _buildLoading() {
    return const Center(child: SpinningBall());
  }

  // ── Error state ───────────────────────────────────────────────────────────

  Widget _buildError() {
    return PageErrorView(
      message: model.errorMessage!,
      onRetry: viewModel.loadGames,
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────

  Widget _buildEmpty() {
    return const PageEmptyView(message: 'No upcoming games');
  }

  // ── Data — grouped list ───────────────────────────────────────────────────

  Widget _buildGameList() {
    final List<Widget> items = [];

    for (final RoundGroup group in model.groupedGames) {
      items.add(_buildGroupHeader(group.round, group.date));

      if (!group.isUnlocked) {
        items.add(_buildLockedBanner(group.round));
      }

      for (final Game game in group.games) {
        items.add(UpcomingGameCard(
          game: game,
          isMatchdayUnlocked: group.isUnlocked,
          existingGuess: model.guessForGame(game.id),
          onPredictionChanged: (Prediction p) =>
              viewModel.onPredictionChanged(game.id, p),
        ));
        items.add(const SizedBox(height: 8));
      }

      items.add(const SizedBox(height: 8));
    }

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: items,
    );
  }

  Widget _buildGroupHeader(String round, DateTime firstKickoff) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        '$round · ${_formatDate(firstKickoff)}',
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.black87,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildLockedBanner(String round) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.lockedBannerBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primary),
      ),
      child: Text(
        '🔒 Opens after $round ends',
        style: const TextStyle(fontSize: 13, color: AppTheme.primary),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    const List<String> months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return '${months[dt.month - 1]} ${dt.day}';
  }
}

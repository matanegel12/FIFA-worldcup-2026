import 'package:flutter/material.dart';
import 'package:mvvm_remepy/base_page.dart';

import '../../app_theme.dart';
import '../../models/game.dart';
import '../../models/round_group.dart';
import '../../widgets/shared/main_bottom_nav.dart';
import '../../widgets/shared/page_empty_view.dart';
import '../../widgets/shared/page_error_view.dart';
import 'upcoming_games_model.dart';
import 'upcoming_games_vm.dart';
import 'widgets/upcoming_game_card.dart';

class UpcomingGamesPage extends BasePage<UpcomingGamesModel, UpcomingGamesViewModel> {
  const UpcomingGamesPage({required super.viewModel, super.key});

  @override
  BasePageState<UpcomingGamesModel, UpcomingGamesViewModel, UpcomingGamesPage>
      createState() => _UpcomingGamesPageState();
}

class _UpcomingGamesPageState
    extends BasePageState<UpcomingGamesModel, UpcomingGamesViewModel, UpcomingGamesPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Color get backgroundColor => Theme.of(context).colorScheme.surface;

  @override
  Widget? get bottomNavigationBar => MainBottomNav(
        onResultsTapped: () {},     // TODO: wire in results phase
        onLeaderboardTapped: () {}, // TODO: wire in leaderboard phase
        onPredictionsTapped: () {}, // TODO: wire in predictions phase
        currentIndex: -1,           // no tab active on upcoming games page
      );

  @override
  PreferredSizeWidget? get appBar => AppBar(
        title: Text(model.appBarTitle),
      );

  @override
  Widget get body {
    if (model.isLoading) return _buildSkeleton();
    if (model.errorMessage != null) return _buildError();
    if (model.groupedGames.isEmpty) return _buildEmpty();
    return _buildGameList();
  }

  // ── Loading — skeleton screen ─────────────────────────────────────────────

  Widget _buildSkeleton() {
    return FadeTransition(
      opacity: Tween<double>(begin: 0.4, end: 1.0).animate(_pulseController),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          _SkeletonCard(),
          SizedBox(height: 12),
          _SkeletonCard(),
          SizedBox(height: 12),
          _SkeletonCard(),
        ],
      ),
    );
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

// ── Skeleton card ─────────────────────────────────────────────────────────────

class _SkeletonCard extends StatelessWidget {
  const _SkeletonCard();

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _grey(width: 48, height: 48, radius: 8),
                _grey(width: 80, height: 14),
                Row(
                  children: [
                    _grey(width: 52, height: 32, radius: 6),
                    const SizedBox(width: 6),
                    _grey(width: 52, height: 32, radius: 6),
                    const SizedBox(width: 6),
                    _grey(width: 52, height: 32, radius: 6),
                  ],
                ),
                _grey(width: 80, height: 14),
                _grey(width: 48, height: 48, radius: 8),
              ],
            ),
            const SizedBox(height: 12),
            _grey(width: double.infinity, height: 12),
            const SizedBox(height: 8),
            _grey(width: 160, height: 12),
          ],
        ),
      ),
    );
  }

  Widget _grey({required double width, required double height, double radius = 4}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}


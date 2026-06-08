import 'package:flutter/material.dart';
import 'package:mvvm_remepy/base_page.dart';

import '../../app_theme.dart';
import '../../models/leaderboard_entry.dart';
import '../../widgets/shared/main_bottom_nav.dart';
import '../../widgets/shared/page_empty_view.dart';
import '../../widgets/shared/page_error_view.dart';
import '../../widgets/shared/spinning_ball.dart';
import 'leaderboard_model.dart';
import 'leaderboard_vm.dart';
import 'widgets/leaderboard_row.dart';
import 'widgets/pinned_user_row.dart';

class LeaderboardPage extends BasePage<LeaderboardModel, LeaderboardViewModel> {
  const LeaderboardPage({required super.viewModel, super.key});

  @override
  BasePageState<LeaderboardModel, LeaderboardViewModel, LeaderboardPage>
      createState() => _LeaderboardPageState();
}

class _LeaderboardPageState
    extends BasePageState<LeaderboardModel, LeaderboardViewModel, LeaderboardPage> {
  @override
  Color get backgroundColor => Theme.of(context).colorScheme.surface;

  @override
  PreferredSizeWidget? get appBar => AppBar(
        title: Text(model.appBarTitle),
      );

  @override
  Widget? get bottomNavigationBar => MainBottomNav(
        onResultsTapped: () {},
        onLeaderboardTapped: () {},
        onPredictionsTapped: () {},
        currentIndex: 1, // leaderboard tab is active
      );

  @override
  Widget get body {
    if (model.isLoading) return const Center(child: SpinningBall());
    if (model.errorMessage != null) {
      return PageErrorView(
        message: model.errorMessage!,
        onRetry: viewModel.loadLeaderboard,
      );
    }
    if (model.topEntries.isEmpty) {
      return const PageEmptyView(message: 'No entries yet');
    }
    return Column(
      children: [
        Expanded(child: _buildList()),
        if (!model.isCurrentUserInTopTen && model.currentUserEntry != null)
          PinnedUserRow(entry: model.currentUserEntry!),
      ],
    );
  }

  Widget _buildList() {
    return RefreshIndicator(
      color: AppTheme.primary,
      onRefresh: () async => viewModel.loadLeaderboard(),
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: model.topEntries.length,
        itemBuilder: (BuildContext context, int index) {
          final LeaderboardEntry entry = model.topEntries[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: LeaderboardRow(
              entry: entry,
              isCurrentUser: entry.userId == viewModel.userId,
            ),
          );
        },
      ),
    );
  }
}

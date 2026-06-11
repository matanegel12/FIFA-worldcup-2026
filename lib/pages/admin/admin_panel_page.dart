import 'package:flutter/material.dart';
import 'package:mvvm_remepy/base_page.dart';
import '../../app_theme.dart';

import '../../models/game.dart';
import '../../widgets/shared/spinning_ball.dart';
import 'admin_panel_model.dart';
import 'admin_panel_vm.dart';
import 'widgets/game_result_form.dart';
import 'widgets/score_test_form.dart';

class AdminPanelPage
    extends BasePage<AdminPanelModel, AdminPanelViewModel> {
  const AdminPanelPage({required super.viewModel, super.key});

  @override
  BasePageState<AdminPanelModel, AdminPanelViewModel, AdminPanelPage>
      createState() => _AdminPanelPageState();
}

class _AdminPanelPageState
    extends BasePageState<AdminPanelModel, AdminPanelViewModel,
        AdminPanelPage> {
  @override
  Color get backgroundColor => Theme.of(context).colorScheme.surface;

  @override
  void onNotify([AdminPanelModel? data]) {
    super.onNotify(data);
    final String? message = model.successMessage;
    if (message != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppTheme.correct,
          duration: const Duration(seconds: 2),
        ),
      );
      model.successMessage = null;
    }
  }

  @override
  Widget get body {
    if (model.isLoading) {
      return const Center(child: SpinningBall());
    }

    if (model.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(model.errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: viewModel.loadGames,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        _buildEnterResultsSection(),
        const SizedBox(height: 16),
        _buildScoreTestingSection(),
      ],
    );
  }

  // ── Section 1 — Enter Results ─────────────────────────────────────────────

  Widget _buildEnterResultsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Enter Results',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        if (model.gamesNeedingResults.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'No games need results 🎉',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          )
        else
          ...model.gamesNeedingResults.map((Game game) => GameResultForm(
                game: game,
                onSave: (int home, int away) =>
                    viewModel.setGameResult(game.id, home, away),
              )),
      ],
    );
  }

  // ── Section 2 — Score Testing ─────────────────────────────────────────────

  Widget _buildScoreTestingSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Score Testing',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Apply a temporary score to any game. Scoring and leaderboard update immediately. Use "Clear" to undo all test scores.',
            style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
          ),
        ),
        const SizedBox(height: 8),
        ...model.allGames.map((Game game) => ScoreTestForm(
              game: game,
              isLoading: model.savingGameIds.contains(game.id),
              onApply: (int home, int away) => viewModel.forceGameResult(
                gameId: game.id,
                homeScore: home,
                awayScore: away,
              ),
            )),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _confirmClearTestResults,
              icon: const Icon(Icons.delete_sweep),
              label: const Text('Clear All Test Scores & Recompute'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }

  Future<void> _confirmClearTestResults() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Clear Test Scores'),
        content: const Text(
          'This will reset all test scores and recompute all user points from real results only. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear & Recompute'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await viewModel.clearTestResults();
    }
  }
}

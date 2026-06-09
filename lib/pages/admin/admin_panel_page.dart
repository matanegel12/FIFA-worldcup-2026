import 'package:flutter/material.dart';
import 'package:mvvm_remepy/base_page.dart';
import '../../app_theme.dart';

import '../../models/game.dart';
import '../../widgets/shared/spinning_ball.dart';
import 'admin_panel_model.dart';
import 'admin_panel_vm.dart';
import 'widgets/game_result_form.dart';

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
            Text(
              model.errorMessage!,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: viewModel.loadGames,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (model.gamesNeedingResults.isEmpty) {
      return const Center(
        child: Text(
          'No games need results 🎉',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: model.gamesNeedingResults.length,
      itemBuilder: (BuildContext context, int index) {
        final Game game = model.gamesNeedingResults[index];
        return GameResultForm(
          game: game,
          onSave: (int home, int away) =>
              viewModel.setGameResult(game.id, home, away),
        );
      },
    );
  }
}

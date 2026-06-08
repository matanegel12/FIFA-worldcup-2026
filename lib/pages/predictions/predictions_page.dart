import 'package:flutter/material.dart';
import 'package:mvvm_remepy/base_page.dart';

import '../../app_theme.dart';
import '../../models/prediction_summary.dart';
import '../../widgets/shared/spinning_ball.dart';
import 'predictions_model.dart';
import 'predictions_vm.dart';
import 'widgets/prediction_game_card.dart';

class PredictionsPage extends BasePage<PredictionsModel, PredictionsViewModel> {
  const PredictionsPage({required super.viewModel, super.key});

  @override
  BasePageState<PredictionsModel, PredictionsViewModel, PredictionsPage>
      createState() => _PredictionsPageState();
}

class _PredictionsPageState
    extends BasePageState<PredictionsModel, PredictionsViewModel, PredictionsPage> {
  @override
  Color get backgroundColor => Theme.of(context).colorScheme.surface;

  @override
  PreferredSizeWidget? get appBar => AppBar(
        title: Text(model.appBarTitle),
      );

  @override
  Widget get body {
    if (model.isLoading) return _buildLoading();
    if (model.errorMessage != null) return _buildError();
    if (model.predictions.isEmpty) return _buildEmpty();
    return _buildList();
  }

  // ── Loading — spinning ⚽ ─────────────────────────────────────────────────

  Widget _buildLoading() {
    return const Center(child: SpinningBall());
  }

  // ── Error state ───────────────────────────────────────────────────────────

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              model.errorMessage!,
              style: const TextStyle(fontSize: 16, color: AppTheme.primary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: viewModel.loadPredictions,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  // ── Empty state ───────────────────────────────────────────────────────────

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('⚽', style: TextStyle(fontSize: 64)),
          SizedBox(height: 12),
          Text(
            'No predictions yet',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  // ── Data — list of prediction cards ──────────────────────────────────────

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: model.predictions.length,
      itemBuilder: (BuildContext context, int index) {
        final PredictionSummary summary = model.predictions[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: PredictionGameCard(summary: summary),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:mvvm_remepy/base_page.dart';

import '../../models/prediction_summary.dart';
import '../../widgets/shared/page_empty_view.dart';
import '../../widgets/shared/page_error_view.dart';
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
    if (model.isLoading) return const Center(child: SpinningBall());
    if (model.errorMessage != null) {
      return PageErrorView(
        message: model.errorMessage!,
        onRetry: viewModel.loadPredictions,
      );
    }
    if (model.predictions.isEmpty) {
      return const PageEmptyView(message: 'No predictions yet');
    }
    return _buildList();
  }

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

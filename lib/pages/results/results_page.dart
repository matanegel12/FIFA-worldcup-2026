import 'package:flutter/material.dart';
import 'package:mvvm_remepy/base_page.dart';

import '../../models/game.dart';
import '../../widgets/shared/page_empty_view.dart';
import '../../widgets/shared/page_error_view.dart';
import '../../widgets/shared/spinning_ball.dart';
import 'results_model.dart';
import 'results_vm.dart';
import 'widgets/result_game_card.dart';

class ResultsPage extends BasePage<ResultsModel, ResultsViewModel> {
  const ResultsPage({required super.viewModel, super.key});

  @override
  BasePageState<ResultsModel, ResultsViewModel, ResultsPage>
      createState() => _ResultsPageState();
}

class _ResultsPageState
    extends BasePageState<ResultsModel, ResultsViewModel, ResultsPage> {
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
        onRetry: viewModel.loadResults,
      );
    }
    if (model.finishedGames.isEmpty) {
      return const PageEmptyView(message: 'No results yet');
    }
    return _buildList();
  }

  Widget _buildList() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: model.finishedGames.length,
      itemBuilder: (BuildContext context, int index) {
        final Game game = model.finishedGames[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: ResultGameCard(game: game),
        );
      },
    );
  }
}

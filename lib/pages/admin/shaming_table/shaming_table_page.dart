import 'package:flutter/material.dart';
import 'package:mvvm_remepy/base_page.dart';

import '../../../app_theme.dart';
import '../../../widgets/shared/page_empty_view.dart';
import '../../../widgets/shared/page_error_view.dart';
import '../../../widgets/shared/spinning_ball.dart';
import 'shaming_table_model.dart';
import 'shaming_table_vm.dart';
import 'widgets/shame_row.dart';

class ShamingTablePage
    extends BasePage<ShamingTableModel, ShamingTableViewModel> {
  const ShamingTablePage({required super.viewModel, super.key});

  @override
  BasePageState<ShamingTableModel, ShamingTableViewModel, ShamingTablePage>
      createState() => _ShamingTablePageState();
}

class _ShamingTablePageState extends BasePageState<ShamingTableModel,
    ShamingTableViewModel, ShamingTablePage> {
  @override
  Color get backgroundColor => Theme.of(context).colorScheme.surface;

  @override
  PreferredSizeWidget? get appBar => AppBar(
        title: Text(model.appBarTitle),
        actions: [
          if (model.entries.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Clear the wall',
              onPressed: _confirmClear,
            ),
        ],
      );

  @override
  void onNotify([ShamingTableModel? data]) {
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

  Future<void> _confirmClear() async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) => AlertDialog(
        title: const Text('Clear the Wall of Shame'),
        content: const Text(
          'This forgives every current offender by removing the timestamp from '
          'their guess. The predictions are kept. Anyone who edits late again '
          'will reappear. Continue?',
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
            child: const Text('Clear'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await viewModel.clearTable();
    }
  }

  @override
  Widget get body {
    if (model.isLoading) {
      return const Center(child: SpinningBall());
    }

    if (model.errorMessage != null) {
      return PageErrorView(
        message: model.errorMessage!,
        onRetry: viewModel.loadShameEntries,
      );
    }

    if (model.entries.isEmpty) {
      return const PageEmptyView(
        message: 'No late guesses — everyone played fair! 😇',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: model.entries.length,
      itemBuilder: (BuildContext context, int index) =>
          ShameRow(entry: model.entries[index]),
    );
  }
}

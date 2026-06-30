import 'package:mvvm_remepy/view_model.dart';

import '../../../services/shaming/firestore_shaming_repository.dart';
import '../../../services/shaming/shaming_repository.dart';
import 'shaming_table_model.dart';

class ShamingTableViewModel extends ViewModel<ShamingTableModel> {
  final ShamingRepository _shamingRepository;

  ShamingTableViewModel({ShamingRepository? shamingRepository})
      : _shamingRepository =
            shamingRepository ?? FirestoreShamingRepository(),
        super(model: ShamingTableModel());

  @override
  void onViewLoaded(dynamic data) {
    loadShameEntries();
  }

  Future<void> loadShameEntries() async {
    model.isLoading = true;
    model.errorMessage = null;
    notify();

    try {
      model.entries = await _shamingRepository.fetchLateGuesses();
    } catch (_) {
      model.errorMessage = 'Could not load the wall of shame. Tap to retry.';
    } finally {
      model.isLoading = false;
      notify();
    }
  }

  /// Forgives all current offenders, then reloads the (now empty) board.
  Future<void> clearTable() async {
    model.isLoading = true;
    model.errorMessage = null;
    notify();

    try {
      final int cleared = await _shamingRepository.clearLateGuesses();
      model.entries = await _shamingRepository.fetchLateGuesses();
      model.successMessage = 'Cleared $cleared late ${cleared == 1 ? 'guess' : 'guesses'}.';
    } catch (_) {
      model.errorMessage = 'Could not clear the wall of shame. Tap to retry.';
    } finally {
      model.isLoading = false;
      notify();
    }
  }
}

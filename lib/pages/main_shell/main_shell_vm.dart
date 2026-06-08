import 'package:mvvm_remepy/view_model.dart';

import '../../services/repositories/games_repository/games_repository.dart';
import '../../services/repositories/guesses_repository/guesses_repository.dart';
import '../../services/repositories/leaderboard_repository/leaderboard_repository.dart';
import 'main_shell_model.dart';

class MainShellViewModel extends ViewModel<MainShellModel> {
  final GamesRepository gamesRepository;
  final GuessesRepository guessesRepository;
  final LeaderboardRepository leaderboardRepository;
  final String userId;

  MainShellViewModel({
    required this.gamesRepository,
    required this.guessesRepository,
    required this.leaderboardRepository,
    required this.userId,
  }) : super(model: MainShellModel());

  /// Switches the active tab. Ignores out-of-range indices.
  void onTabChanged(int index) {
    if (index < 0 || index > 3) return;
    model.currentIndex = index;
    notify();
  }
}

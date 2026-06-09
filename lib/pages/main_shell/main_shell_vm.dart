import 'package:mvvm_remepy/observer/observer.dart';
import 'package:mvvm_remepy/view_model.dart';

import '../../services/repositories/games_repository/games_repository.dart';
import '../../services/repositories/guesses_repository/guesses_repository.dart';
import '../../services/repositories/leaderboard_repository/leaderboard_repository.dart';
import 'main_shell_model.dart';

class MainShellViewModel extends ViewModel<MainShellModel> {
  final GamesRepository gamesRepository;
  final GuessesRepository guessesRepository;
  final LeaderboardRepository leaderboardRepository;

  MainShellViewModel({
    required this.gamesRepository,
    required this.guessesRepository,
    required this.leaderboardRepository,
  }) : super(model: MainShellModel());

  /// Receives userId and userEmail from auth_gate via route arguments.
  @override
  void onViewLoaded(dynamic data) {
    if (data is Map) {
      model.userId = (data['userId'] as String?) ?? '';
      model.userEmail = (data['email'] as String?) ?? '';
      notify();
    }
  }

  /// Switches the active tab. Ignores out-of-range indices.
  void onTabChanged(int index) {
    if (index < 0 || index > 3) return;
    model.currentIndex = index;
    notify();
  }

  void onAdminTapped() {
    notifyNavigate(NavigateModel(routeName: '/admin'));
  }
}

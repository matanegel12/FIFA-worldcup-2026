import 'package:mvvm_remepy/view_model.dart';

import '../../models/guess.dart';
import '../../models/round_group.dart';

class UpcomingGamesModel extends Model {
  String? errorMessage;
  List<RoundGroup> groupedGames = [];

  /// Keyed by gameId — holds the current user's guess for each game.
  Map<String, Guess> guesses = {};

  /// Returns the current user's guess for a game, or null if none exists.
  Guess? guessForGame(String gameId) => guesses[gameId];

  UpcomingGamesModel() {
    appBarTitle = 'Upcoming Games';
    isLoading = true;
  }
}

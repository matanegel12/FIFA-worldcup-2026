import 'package:mvvm_remepy/view_model.dart';

import '../../models/game.dart';
import '../../models/guess.dart';
import '../../models/round_group.dart';

class UpcomingGamesModel extends Model {
  String? errorMessage;
  List<RoundGroup> groupedGames = [];

  /// Keyed by gameId — holds the current user's guess for each game.
  Map<String, Guess> guesses = {};

  /// True when there are unseen finished-game results to show the user.
  bool showResultsPopup = false;

  /// The finished games the user has not yet seen — drives the popup content.
  List<Game> unseenGames = [];

  /// Returns the current user's guess for a game, or null if none exists.
  Guess? guessForGame(String gameId) => guesses[gameId];

  UpcomingGamesModel() {
    appBarTitle = 'Upcoming Games';
    isLoading = true;
  }
}

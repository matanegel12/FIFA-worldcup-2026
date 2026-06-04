import '../../models/game.dart';
import '../../models/guess.dart';
import '../../models/user.dart';

/// In-memory store used by mock repositories and the admin panel.
/// A singleton — one shared instance for the entire app session.
///
/// The admin panel writes here (inject results, reset data).
/// Mock repositories read from here (instead of Firebase / the API).
class MockStore {
  MockStore._();
  static final MockStore instance = MockStore._();

  // ── Data ────────────────────────────────────────────────────────────────────

  List<Game> _games = [];
  List<User> _users = [];
  final Map<String, Guess> _guesses = {}; // key: Guess.compoundId(userId, gameId)
  String? currentUserId; // set on mock sign-in, cleared on sign-out

  // ── Games ────────────────────────────────────────────────────────────────────

  List<Game> get games => List.unmodifiable(_games);

  List<Game> get upcomingGames =>
      _games.where((g) => !g.isFinished).toList();

  List<Game> get finishedGames =>
      _games.where((g) => g.isFinished).toList();

  void seedGames(List<Game> games) => _games = List.of(games);

  /// Adds a new game or replaces an existing one with the same id.
  void saveGame(Game game) {
    final index = _games.indexWhere((g) => g.id == game.id);
    if (index == -1) {
      _games.add(game);
    } else {
      _games[index] = game;
    }
  }

  /// Sets a result for a game. Triggers the same path as production scoring.
  void setGameResult({
    required String gameId,
    required int homeScore,
    required int awayScore,
    required DateTime finishedAt,
  }) {
    final index = _games.indexWhere((g) => g.id == gameId);
    if (index == -1) return;
    _games[index] = Game(
      id: _games[index].id,
      homeTeam: _games[index].homeTeam,
      awayTeam: _games[index].awayTeam,
      kickoffTime: _games[index].kickoffTime,
      homeScore: homeScore,
      awayScore: awayScore,
      status: GameStatus.finished,
      finishedAt: finishedAt,
    );
  }

  // ── Guesses ──────────────────────────────────────────────────────────────────

  List<Guess> get allGuesses => List.unmodifiable(_guesses.values);

  Guess? getGuess(String userId, String gameId) =>
      _guesses[Guess.compoundId(userId, gameId)];

  List<Guess> guessesForUser(String userId) =>
      _guesses.values.where((g) => g.userId == userId).toList();

  List<Guess> guessesForGame(String gameId) =>
      _guesses.values.where((g) => g.gameId == gameId).toList();

  void saveGuess(Guess guess) =>
      _guesses[Guess.compoundId(guess.userId, guess.gameId)] = guess;

  // ── Users ────────────────────────────────────────────────────────────────────

  List<User> get users => List.unmodifiable(_users);

  User? getUser(String userId) =>
      _users.where((u) => u.id == userId).firstOrNull;

  void saveUser(User user) {
    final index = _users.indexWhere((u) => u.id == user.id);
    if (index == -1) {
      _users.add(user);
    } else {
      _users[index] = user;
    }
  }

  void seedUsers(List<User> users) => _users = List.of(users);

  // ── Reset operations ─────────────────────────────────────────────────────────

  /// Clears all data. After a full reset the app re-syncs games from the API.
  void resetAll() {
    _games.clear();
    _guesses.clear();
    _users.clear();
    currentUserId = null;
  }

  /// Clears all guesses without touching games or user points.
  void resetGuesses() => _guesses.clear();

  /// Clears guesses and resets game results for a specific day.
  void resetDay(DateTime day) {
    final dayGames = _games
        .where((g) => g.matchDay == DateTime.utc(day.year, day.month, day.day))
        .map((g) => g.id)
        .toSet();

    _guesses.removeWhere((_, guess) => dayGames.contains(guess.gameId));
    _games = _games.map((g) {
      if (!dayGames.contains(g.id)) return g;
      return Game(
        id: g.id,
        homeTeam: g.homeTeam,
        awayTeam: g.awayTeam,
        kickoffTime: g.kickoffTime,
        status: GameStatus.upcoming,
      );
    }).toList();
  }

  /// Removes all users and their guesses. Keeps games intact.
  void resetUsers() {
    _users.clear();
    _guesses.clear();
  }
}

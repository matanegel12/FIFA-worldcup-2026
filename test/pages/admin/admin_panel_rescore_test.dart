import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fifa_worldcup_2026_predictions/models/game.dart';
import 'package:fifa_worldcup_2026_predictions/models/guess.dart';
import 'package:fifa_worldcup_2026_predictions/models/team.dart';
import 'package:fifa_worldcup_2026_predictions/pages/admin/admin_panel_vm.dart';
import 'package:fifa_worldcup_2026_predictions/services/repositories/games_repository/games_repository.dart';
import 'package:fifa_worldcup_2026_predictions/services/repositories/guesses_repository/guesses_repository.dart';

// ── Test doubles ──────────────────────────────────────────────────────────────

const Team _home = Team(fifaCode: 'MEX', isoCode: 'mx', name: 'Mexico');
const Team _away = Team(fifaCode: 'ARG', isoCode: 'ar', name: 'Argentina');

/// Two group-stage games in the SAME round (one match day, the "set").
/// g1 → teamAWins, g2 → teamBWins. Both finished.
/// A user who gets BOTH right earns 2 (correct) + 2 (set bonus) = 4 pts.
final List<Game> _finishedGames = [
  Game(
    id: 'g1',
    homeTeam: _home,
    awayTeam: _away,
    kickoffTime: DateTime.utc(2026, 6, 11, 15, 0),
    homeScore: 2,
    awayScore: 1,
    status: GameStatus.finished,
    round: 'Matchday 1',
  ),
  Game(
    id: 'g2',
    homeTeam: _home,
    awayTeam: _away,
    kickoffTime: DateTime.utc(2026, 6, 11, 18, 0),
    homeScore: 0,
    awayScore: 1,
    status: GameStatus.finished,
    round: 'Matchday 1',
  ),
];

class _FakeGamesRepository implements GamesRepository {
  final List<Game> finished;
  _FakeGamesRepository(this.finished);

  @override
  Future<List<Game>> fetchAllGames() async => finished;
  @override
  Future<List<Game>> fetchUpcomingGames() async => [];
  @override
  Future<List<Game>> fetchFinishedGames() async => finished;
  @override
  Future<void> saveGame(Game game) async {}
  @override
  Future<void> recordResult({
    required String gameId,
    required int homeScore,
    required int awayScore,
    required DateTime finishedAt,
  }) async {}
}

class _FakeGuessesRepository implements GuessesRepository {
  final Map<String, List<Guess>> byUser;
  _FakeGuessesRepository(this.byUser);

  @override
  Future<Guess?> fetchGuess(String userId, String gameId) async => null;
  @override
  Future<List<Guess>> fetchGuessesForUser(String userId) async =>
      byUser[userId] ?? const [];
  @override
  Future<List<Guess>> fetchGuessesForGame(String gameId) async => const [];
  @override
  Future<void> saveGuess(Guess guess) async {}
}

Guess _guess(String userId, String gameId, Prediction p) =>
    Guess(userId: userId, gameId: gameId, prediction: p);

/// u1 gets both correct (2 + set bonus 2 = 4 pts), u2 gets one correct
/// (1 pt, set broken), u3 has no guesses (0 pts).
final Map<String, List<Guess>> _guessesByUser = {
  'u1': [
    _guess('u1', 'g1', Prediction.teamAWins), // correct
    _guess('u1', 'g2', Prediction.teamBWins), // correct
  ],
  'u2': [
    _guess('u2', 'g1', Prediction.teamAWins), // correct
    _guess('u2', 'g2', Prediction.teamAWins), // wrong
  ],
  'u3': const [],
};

Future<void> _seedUsers(FakeFirebaseFirestore db, int stalePoints) async {
  for (final String id in ['u1', 'u2', 'u3']) {
    await db.collection('users').doc(id).set({
      'email': '$id@example.com',
      'displayName': id.toUpperCase(),
      'totalPoints': stalePoints,
    });
  }
}

Future<int> _points(FakeFirebaseFirestore db, String id) async {
  final snap = await db.collection('users').doc(id).get();
  return (snap.data()!['totalPoints'] as num).toInt();
}

void main() {
  late FakeFirebaseFirestore db;
  late AdminPanelViewModel vm;

  setUp(() {
    db = FakeFirebaseFirestore();
    vm = AdminPanelViewModel(
      gamesRepository: _FakeGamesRepository(_finishedGames),
      guessesRepository: _FakeGuessesRepository(_guessesByUser),
      firestore: db,
    );
  });

  group('setGameResult → atomic rescore', () {
    test('writes the correct total for EVERY user in a single rescore', () async {
      await _seedUsers(db, 0);

      await vm.setGameResult('g2', 0, 1);

      // No user is skipped or left stale — all three reflect their real score.
      expect(await _points(db, 'u1'), 4);
      expect(await _points(db, 'u2'), 1);
      expect(await _points(db, 'u3'), 0);
    });

    test('overwrites stale totals for every user (none left behind)', () async {
      // Seed everyone with a wrong, inflated total — the kind a half-finished
      // loop or a stale read would leave on the leaderboard.
      await _seedUsers(db, 99);

      await vm.setGameResult('g2', 0, 1);

      expect(await _points(db, 'u1'), 4);
      expect(await _points(db, 'u2'), 1);
      expect(await _points(db, 'u3'), 0);
    });

    test('scoreReachedAt advances only for users whose score went up', () async {
      await _seedUsers(db, 0);

      await vm.setGameResult('g2', 0, 1);

      final u1 = (await db.collection('users').doc('u1').get()).data()!;
      final u3 = (await db.collection('users').doc('u3').get()).data()!;

      expect(u1['scoreReachedAt'], isNotNull); // 0 → 2, increased
      expect(u3['scoreReachedAt'], isNull); // stayed 0
    });
  });

  group('recomputeAllScores → atomic full recompute', () {
    test('rebuilds correct totals for every user from scratch', () async {
      await _seedUsers(db, 99);

      await vm.recomputeAllScores();

      expect(await _points(db, 'u1'), 4);
      expect(await _points(db, 'u2'), 1);
      expect(await _points(db, 'u3'), 0);
    });
  });
}

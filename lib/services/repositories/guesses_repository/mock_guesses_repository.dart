import '../../../models/guess.dart';
import '../../mock/mock_store.dart';
import 'guesses_repository.dart';

class MockGuessesRepository implements GuessesRepository {
  final MockStore _store;

  MockGuessesRepository({MockStore? store})
      : _store = store ?? MockStore.instance;

  @override
  Future<Guess?> fetchGuess(String userId, String gameId) async =>
      _store.getGuess(userId, gameId);

  @override
  Future<List<Guess>> fetchGuessesForUser(String userId) async =>
      _store.guessesForUser(userId);

  @override
  Future<List<Guess>> fetchGuessesForGame(String gameId) async =>
      _store.guessesForGame(gameId);

  @override
  Future<void> saveGuess(Guess guess) async => _store.saveGuess(guess);
}

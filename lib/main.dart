import 'package:flutter/material.dart';
import 'app.dart';
import 'models/guess.dart';
import 'services/mock/mock_seed_data.dart';
import 'services/mock/mock_store.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: remove before production — dev testing only
  MockStore.instance.seedUsers([kFakeUser]);
  MockStore.instance.currentUserId = kFakeUser.id;
  MockStore.instance.seedGames(kFakeGames);
  for (final Guess guess in kFakeGuesses) {
    MockStore.instance.saveGuess(guess);
  }

  // TODO: restore for production — fetches real games from openfootball API
  // try {
  //   final List<Game> games = await WorldCupApiClient().fetchGames();
  //   MockStore.instance.seedGames(games);
  // } catch (_) {
  //   // App still loads — UpcomingGamesPage will show the error state.
  // }

  // TODO: restore for production — initialise Firebase
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  runApp(const App());
}

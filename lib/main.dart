import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'app.dart';
import 'firebase_options.dart';
import 'models/guess.dart';
import 'services/api/world_cup_api_client.dart';
import 'services/mock/mock_seed_data.dart';
import 'services/mock/mock_store.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // TODO: remove before production — dev testing only
  MockStore.instance.seedUsers([kFakeUser]);
  MockStore.instance.currentUserId = kFakeUser.id;
  for (final Guess guess in kFakeGuesses) {
    MockStore.instance.saveGuess(guess);
  }

  // Fetch real games from the openfootball API and seed MockStore.
  // UpcomingGamesViewModel reads from MockGamesRepository → MockStore.
  try {
    final games = await WorldCupApiClient().fetchGames();
    MockStore.instance.seedGames(games);
  } catch (_) {
    // App still loads — UpcomingGamesPage will show the error state.
  }
  //await Firebase.initializeApp(
    //options: DefaultFirebaseOptions.currentPlatform,
  //);
  runApp(const App());
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fifa_worldcup_2026_predictions/models/game.dart';
import 'package:fifa_worldcup_2026_predictions/models/guess.dart';
import 'package:fifa_worldcup_2026_predictions/models/team.dart';
import 'package:fifa_worldcup_2026_predictions/pages/auth/sign_in/sign_in_page.dart';
import 'package:fifa_worldcup_2026_predictions/pages/auth/sign_in/sign_in_vm.dart';
import 'package:fifa_worldcup_2026_predictions/pages/upcoming_games/widgets/upcoming_game_card.dart';
import 'package:fifa_worldcup_2026_predictions/services/repositories/auth_repository/mock_auth_repository.dart';

// ── Helpers ───────────────────────────────────────────────────────────────────

const Team _mexico = Team(fifaCode: 'MEX', isoCode: 'mx', name: 'Mexico');
const Team _brazil = Team(fifaCode: 'BRA', isoCode: 'br', name: 'Brazil');

final Game _futureGame = Game(
  id: 'g1',
  homeTeam: _mexico,
  awayTeam: _brazil,
  kickoffTime: DateTime.utc(2099, 6, 18, 15, 0),
  status: GameStatus.upcoming,
  round: 'Matchday 1',
  ground: 'Mexico City',
);

Widget _cardInApp(UpcomingGameCard card) => MaterialApp(
      home: Scaffold(body: card),
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  testWidgets('SignInPage renders email and password fields', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SignInPage(
          viewModel: SignInViewModel(authRepository: MockAuthRepository()),
        ),
      ),
    );

    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });

  testWidgets('UpcomingGameCard shows team names and match info', (WidgetTester tester) async {
    await tester.pumpWidget(_cardInApp(UpcomingGameCard(
      game: _futureGame,
      isMatchdayUnlocked: true,
      onPredictionChanged: (_) {},
    )));

    expect(find.text('Mexico'), findsWidgets);
    expect(find.text('Brazil'), findsWidgets);
    expect(find.textContaining('UTC'), findsOneWidget);
    expect(find.textContaining('Mexico City'), findsOneWidget);
  });

  testWidgets('UpcomingGameCard shows Place your bet when unlocked', (WidgetTester tester) async {
    await tester.pumpWidget(_cardInApp(UpcomingGameCard(
      game: _futureGame,
      isMatchdayUnlocked: true,
      onPredictionChanged: (_) {},
    )));

    expect(find.text('Place your bet'), findsOneWidget);
    expect(find.text('Draw'), findsOneWidget);
  });

  testWidgets('UpcomingGameCard shows locked banner when matchday is locked', (WidgetTester tester) async {
    await tester.pumpWidget(_cardInApp(UpcomingGameCard(
      game: _futureGame,
      isMatchdayUnlocked: false,
      onPredictionChanged: (_) {},
    )));

    expect(find.textContaining('Locked'), findsOneWidget);
    expect(find.text('Draw'), findsNothing);
  });

  testWidgets('UpcomingGameCard reflects existing guess selection', (WidgetTester tester) async {
    const Guess existingGuess = Guess(
      userId: 'uid-1',
      gameId: 'g1',
      prediction: Prediction.teamAWins,
    );

    await tester.pumpWidget(_cardInApp(UpcomingGameCard(
      game: _futureGame,
      isMatchdayUnlocked: true,
      existingGuess: existingGuess,
      onPredictionChanged: (_) {},
    )));

    // SegmentedButton with Mexico selected — Draw and Brazil are visible too
    expect(find.text('Mexico'), findsWidgets);
    expect(find.text('Draw'), findsOneWidget);
    expect(find.text('Brazil'), findsWidgets);
  });
}

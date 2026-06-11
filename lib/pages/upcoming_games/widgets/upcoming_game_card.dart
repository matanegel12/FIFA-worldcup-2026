import 'package:flutter/material.dart';

import '../../../app_theme.dart';
import '../../../models/game.dart';
import '../../../models/guess.dart';
import '../../../widgets/shared/team_flag.dart';

class UpcomingGameCard extends StatelessWidget {
  final Game game;
  final Guess? existingGuess;
  final void Function(Prediction prediction) onPredictionChanged;

  const UpcomingGameCard({
    required this.game,
    required this.onPredictionChanged,
    this.existingGuess,
    super.key,
  });

  /// True once the game's kickoff time has passed — the only lock that applies.
  bool get _isKickoffPassed =>
      game.kickoffTime.isBefore(DateTime.now().toUtc());

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTeamsRow(),
            const SizedBox(height: 12),
            _buildPredictionSection(),
            const SizedBox(height: 10),
            _buildLockBadge(),
            const SizedBox(height: 8),
            _buildMatchInfo(),
          ],
        ),
      ),
    );
  }

  // ── Flags row + team names row ────────────────────────────────────────────

  Widget _buildTeamsRow() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            TeamFlag(flagUrl: game.homeTeam.flagUrl),
            const Text(
              'Place your bet',
              style: TextStyle(
                fontSize: 12,
                color: Colors.black54,
                fontWeight: FontWeight.normal,
              ),
              textAlign: TextAlign.center,
            ),
            TeamFlag(flagUrl: game.awayTeam.flagUrl),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _buildTeamName(game.homeTeam.name, TextAlign.left),
            _buildTeamName(game.awayTeam.name, TextAlign.right),
          ],
        ),
      ],
    );
  }

  Widget _buildTeamName(String name, TextAlign align) {
    return SizedBox(
      width: 80,
      child: Text(
        name,
        style: const TextStyle(fontSize: 11, color: Colors.black87),
        textAlign: align,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }

  // ── Prediction buttons ────────────────────────────────────────────────────

  Widget _buildPredictionSection() {
    final Prediction? selected = existingGuess?.prediction;

    return SegmentedButton<Prediction>(
      segments: [
        ButtonSegment<Prediction>(
          value: Prediction.teamAWins,
          label: _SegmentLabel(game.homeTeam.name),
        ),
        const ButtonSegment<Prediction>(
          value: Prediction.draw,
          label: _SegmentLabel('Draw'),
        ),
        ButtonSegment<Prediction>(
          value: Prediction.teamBWins,
          label: _SegmentLabel(game.awayTeam.name),
        ),
      ],
      selected: selected != null ? {selected} : const <Prediction>{},
      emptySelectionAllowed: true,
      onSelectionChanged: _isKickoffPassed
          ? null
          : (Set<Prediction> newSelection) {
              if (newSelection.isNotEmpty) {
                onPredictionChanged(newSelection.first);
              }
            },
      style: SegmentedButton.styleFrom(
        backgroundColor: Colors.white,
        selectedBackgroundColor: AppTheme.secondary,
        selectedForegroundColor: Colors.black,
        foregroundColor: Colors.black87,
        side: const BorderSide(color: Colors.black12),
      ),
    );
  }

  // ── Lock badge ────────────────────────────────────────────────────────────

  Widget _buildLockBadge() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
        decoration: BoxDecoration(
          border: Border.all(color: AppTheme.primary),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Guesses lock at kickoff',
          style: TextStyle(
            fontSize: 10,
            color: AppTheme.primary,
            letterSpacing: 0.3,
          ),
        ),
      ),
    );
  }

  // ── Match info ────────────────────────────────────────────────────────────

  Widget _buildMatchInfo() {
    final DateTime kickoff = game.kickoffTime;
    final String hour = kickoff.hour.toString().padLeft(2, '0');
    final String minute = kickoff.minute.toString().padLeft(2, '0');
    final String location = game.ground.isNotEmpty
        ? '$hour:$minute UTC · ${game.ground}'
        : '$hour:$minute UTC';

    return Text(
      '🕐 $location',
      style: const TextStyle(fontSize: 11, color: Colors.black54),
      textAlign: TextAlign.center,
    );
  }
}

// ── Segment label ─────────────────────────────────────────────────────────────

class _SegmentLabel extends StatelessWidget {
  final String text;

  const _SegmentLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 70,
      child: Text(
        text,
        style: const TextStyle(fontSize: 11),
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        maxLines: 1,
      ),
    );
  }
}

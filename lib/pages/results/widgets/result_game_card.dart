import 'package:flutter/material.dart';

import '../../../app_theme.dart';
import '../../../models/game.dart';
import '../../../models/team.dart';
import '../../../widgets/shared/team_flag.dart';

class ResultGameCard extends StatelessWidget {
  final Game game;

  const ResultGameCard({required this.game, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Group name — top left
            Text(
              game.round,
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            // Flags + score row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildTeamColumn(game.homeTeam, TextAlign.center),
                _buildScore(),
                _buildTeamColumn(game.awayTeam, TextAlign.center),
              ],
            ),
            const SizedBox(height: 10),
            // Time and city — bottom center
            Text(
              _formatMatchInfo(),
              style: const TextStyle(
                fontSize: 11,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamColumn(Team team, TextAlign align) {
    return Column(
      children: [
        TeamFlag(flagUrl: team.flagUrl),
        const SizedBox(height: 6),
        SizedBox(
          width: 80,
          child: Text(
            team.name,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.textPrimary,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
      ],
    );
  }

  Widget _buildScore() {
    return Text(
      '${game.homeScore}  -  ${game.awayScore}',
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: AppTheme.textPrimary,
      ),
    );
  }

  String _formatMatchInfo() {
    final DateTime kickoff = game.kickoffTime;
    final String hour = kickoff.hour.toString().padLeft(2, '0');
    final String minute = kickoff.minute.toString().padLeft(2, '0');
    if (game.ground.isNotEmpty) {
      return '🕐 $hour:$minute UTC · ${game.ground}';
    }
    return '🕐 $hour:$minute UTC';
  }
}

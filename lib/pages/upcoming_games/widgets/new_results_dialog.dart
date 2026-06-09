import 'package:flutter/material.dart';

import '../../../app_theme.dart';
import '../../../models/game.dart';
import '../../../widgets/shared/team_flag.dart';

class NewResultsDialog extends StatelessWidget {
  final List<Game> unseenGames;
  final VoidCallback onDismissed;

  const NewResultsDialog({
    required this.unseenGames,
    required this.onDismissed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Title ─────────────────────────────────────────────────────
              const Text(
                '🏆 New Results!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              // ── Scrollable game list ───────────────────────────────────────
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: unseenGames.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (BuildContext context, int index) {
                    return _GameResultRow(game: unseenGames[index]);
                  },
                ),
              ),
              const SizedBox(height: 16),
              // ── Dismiss button ─────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onDismissed,
                  child: const Text('Got it!'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Game result row ───────────────────────────────────────────────────────────

class _GameResultRow extends StatelessWidget {
  final Game game;

  const _GameResultRow({required this.game});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Home team
        Column(
          children: [
            TeamFlag(flagUrl: game.homeTeam.flagUrl),
            const SizedBox(height: 4),
            SizedBox(
              width: 72,
              child: Text(
                game.homeTeam.name,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
        // Score
        Text(
          '${game.homeScore} - ${game.awayScore}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        // Away team
        Column(
          children: [
            TeamFlag(flagUrl: game.awayTeam.flagUrl),
            const SizedBox(height: 4),
            SizedBox(
              width: 72,
              child: Text(
                game.awayTeam.name,
                style: const TextStyle(
                  fontSize: 11,
                  color: AppTheme.textSecondary,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

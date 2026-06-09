import 'package:flutter/material.dart';

import '../../../app_theme.dart';
import '../../../models/leaderboard_entry.dart';

class LeaderboardRow extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool isCurrentUser;

  const LeaderboardRow({
    required this.entry,
    required this.isCurrentUser,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: _cardColor(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            _buildRankIndicator(),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                entry.displayName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '${entry.totalPoints} pts',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _cardColor() {
    switch (entry.rank) {
      case 1:
        return AppTheme.rankGold;
      case 2:
        return AppTheme.rankSilver;
      case 3:
        return AppTheme.rankBronze;
      default:
        return AppTheme.cardColor;
    }
  }

  Widget _buildRankIndicator() {
    switch (entry.rank) {
      case 1:
        return const SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: Text('🥇', style: TextStyle(fontSize: 24)),
          ),
        );
      case 2:
        return const SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: Text('🥈', style: TextStyle(fontSize: 24)),
          ),
        );
      case 3:
        return const SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: Text('🥉', style: TextStyle(fontSize: 24)),
          ),
        );
      default:
        return SizedBox(
          width: 40,
          height: 40,
          child: Center(
            child: Text(
              '${entry.rank}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        );
    }
  }
}

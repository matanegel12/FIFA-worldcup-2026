import 'package:flutter/material.dart';

import '../../../app_theme.dart';
import '../../../models/leaderboard_entry.dart';

/// Sentinel userId for the local-only hardcoded "Adel — Last place" row.
/// Not a real user; added for local checking only, see leaderboard_page.dart.
const String hardcodedAdelRowId = 'hardcoded_adel_last_place';

class LeaderboardRow extends StatelessWidget {
  final LeaderboardEntry entry;
  final bool isCurrentUser;

  const LeaderboardRow({
    required this.entry,
    required this.isCurrentUser,
    super.key,
  });

  bool get _isHardcodedAdelRow => entry.userId == hardcodedAdelRowId;

  @override
  Widget build(BuildContext context) {
    final Color textColor =
        _isHardcodedAdelRow ? Colors.white : AppTheme.textPrimary;

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
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              _isHardcodedAdelRow ? 'Last place' : '${entry.totalPoints} pts',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _cardColor() {
    if (_isHardcodedAdelRow) return Colors.black;
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
    if (_isHardcodedAdelRow) {
      return const SizedBox(
        width: 40,
        height: 40,
        child: Center(
          child: Text('💀', style: TextStyle(fontSize: 24)),
        ),
      );
    }
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

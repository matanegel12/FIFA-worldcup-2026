import 'package:flutter/material.dart';

import '../../../../app_theme.dart';
import '../../../../models/prediction.dart';
import '../../../../models/shame_entry.dart';

/// One row on the wall of shame: who cheated, on which game, what they picked,
/// and how long after kickoff the guess landed.
class ShameRow extends StatelessWidget {
  final ShameEntry entry;

  const ShameRow({required this.entry, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Text('🫣', style: TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.displayName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    entry.gameLabel,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Picked: ${_predictionLabel(entry.prediction)}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppTheme.incorrect,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_lateLabel(entry.lateBy)} late',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _predictionLabel(Prediction p) {
    switch (p) {
      case Prediction.teamAWins:
        return 'Home win';
      case Prediction.teamBWins:
        return 'Away win';
      case Prediction.draw:
        return 'Draw';
    }
  }

  /// Compact human label, e.g. "3d 4h", "2h 5m", "12m".
  String _lateLabel(Duration d) {
    if (d.inDays > 0) return '${d.inDays}d ${d.inHours % 24}h';
    if (d.inHours > 0) return '${d.inHours}h ${d.inMinutes % 60}m';
    if (d.inMinutes > 0) return '${d.inMinutes}m';
    return '${d.inSeconds}s';
  }
}

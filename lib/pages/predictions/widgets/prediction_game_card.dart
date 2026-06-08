import 'package:flutter/material.dart';

import '../../../app_theme.dart';
import '../../../models/prediction_summary.dart';

class PredictionGameCard extends StatelessWidget {
  final PredictionSummary summary;

  const PredictionGameCard({required this.summary, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${summary.game.homeTeam.name} vs ${summary.game.awayTeam.name}',
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Your prediction: ${summary.predictionDisplayText}',
              style: _predictionStyle(),
            ),
            const SizedBox(height: 6),
            _buildResultRow(),
          ],
        ),
      ),
    );
  }

  // ── Result row ────────────────────────────────────────────────────────────

  Widget _buildResultRow() {
    switch (summary.result) {
      case PredictionResult.correct:
        return Text(
          'Result: ✅ ${summary.resultDisplayText}',
          style: const TextStyle(fontSize: 12, color: AppTheme.correct),
        );
      case PredictionResult.incorrect:
        return Text(
          'Result: ❌ ${summary.resultDisplayText}',
          style: const TextStyle(fontSize: 12, color: AppTheme.incorrect),
        );
      case PredictionResult.pending:
        return const Text(
          'Result: Will appear at the end of the game',
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
            fontStyle: FontStyle.italic,
          ),
        );
      case PredictionResult.notGuessed:
        return const Text(
          '⚠️ No prediction yet',
          style: TextStyle(
            fontSize: 12,
            color: AppTheme.secondary,
            fontStyle: FontStyle.italic,
          ),
        );
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  TextStyle _predictionStyle() {
    if (summary.guess == null) {
      return const TextStyle(
        fontSize: 12,
        color: AppTheme.secondary,
        fontStyle: FontStyle.italic,
      );
    }
    return const TextStyle(fontSize: 12, color: AppTheme.textPrimary);
  }
}

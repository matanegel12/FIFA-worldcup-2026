import 'package:flutter/material.dart';

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
                color: Colors.white,
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
          style: const TextStyle(fontSize: 12, color: Color(0xFF66BB6A)),
        );
      case PredictionResult.incorrect:
        return Text(
          'Result: ❌ ${summary.resultDisplayText}',
          style: const TextStyle(fontSize: 12, color: Color(0xFFFF7043)),
        );
      case PredictionResult.pending:
        return const Text(
          'Result: Will appear at the end of the game',
          style: TextStyle(
            fontSize: 12,
            color: Colors.white60,
            fontStyle: FontStyle.italic,
          ),
        );
      case PredictionResult.notGuessed:
        return const Text(
          '⚠️ No prediction yet',
          style: TextStyle(
            fontSize: 12,
            color: Color(0xFFFFD600),
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
        color: Color(0xFFFFD600),
        fontStyle: FontStyle.italic,
      );
    }
    return const TextStyle(fontSize: 12, color: Colors.white);
  }
}

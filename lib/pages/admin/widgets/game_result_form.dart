import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app_theme.dart';
import '../../../models/game.dart';
import '../../../widgets/shared/team_flag.dart';

class GameResultForm extends StatefulWidget {
  final Game game;
  final void Function(int homeScore, int awayScore) onSave;

  const GameResultForm({
    required this.game,
    required this.onSave,
    super.key,
  });

  @override
  State<GameResultForm> createState() => _GameResultFormState();
}

class _GameResultFormState extends State<GameResultForm> {
  final TextEditingController _homeController = TextEditingController();
  final TextEditingController _awayController = TextEditingController();

  bool get _canSave =>
      _homeController.text.isNotEmpty && _awayController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _homeController.addListener(_onChanged);
    _awayController.addListener(_onChanged);
  }

  void _onChanged() => setState(() {});

  @override
  void dispose() {
    _homeController.dispose();
    _awayController.dispose();
    super.dispose();
  }

  void _handleSave() {
    final int? home = int.tryParse(_homeController.text);
    final int? away = int.tryParse(_awayController.text);
    if (home == null || away == null) return;
    widget.onSave(home, away);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _TeamRow(game: widget.game),
            const SizedBox(height: 12),
            Row(
              children: [
                _ScoreField(
                  controller: _homeController,
                  label: widget.game.homeTeam.name,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12),
                  child: Text(
                    '–',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _ScoreField(
                  controller: _awayController,
                  label: widget.game.awayTeam.name,
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _canSave ? _handleSave : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade300,
                  ),
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TeamRow extends StatelessWidget {
  final Game game;

  const _TeamRow({required this.game});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        TeamFlag(flagUrl: game.homeTeam.flagUrl, width: 22, height: 15),
        const SizedBox(width: 6),
        Text(
          game.homeTeam.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8),
          child: Text('vs', style: TextStyle(color: Colors.grey)),
        ),
        Text(
          game.awayTeam.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(width: 6),
        TeamFlag(flagUrl: game.awayTeam.flagUrl, width: 22, height: 15),
        const Spacer(),
        Text(
          game.round,
          style: const TextStyle(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _ScoreField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const _ScoreField({required this.controller, required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          LengthLimitingTextInputFormatter(2),
        ],
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          hintText: '0',
          labelText: label,
          labelStyle: const TextStyle(fontSize: 11),
          border: const OutlineInputBorder(),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        ),
      ),
    );
  }
}

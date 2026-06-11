import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../app_theme.dart';
import '../../../models/game.dart';
import '../../../widgets/shared/team_flag.dart';

class ScoreTestForm extends StatefulWidget {
  final Game game;
  final bool isLoading;
  final void Function(int homeScore, int awayScore) onApply;

  const ScoreTestForm({
    required this.game,
    required this.isLoading,
    required this.onApply,
    super.key,
  });

  @override
  State<ScoreTestForm> createState() => _ScoreTestFormState();
}

class _ScoreTestFormState extends State<ScoreTestForm> {
  final TextEditingController _homeController = TextEditingController();
  final TextEditingController _awayController = TextEditingController();

  bool get _canApply =>
      !widget.isLoading &&
      _homeController.text.isNotEmpty &&
      _awayController.text.isNotEmpty;

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

  void _handleApply() {
    final int? home = int.tryParse(_homeController.text);
    final int? away = int.tryParse(_awayController.text);
    if (home == null || away == null) return;
    widget.onApply(home, away);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTeamRow(),
            const SizedBox(height: 10),
            Row(
              children: [
                _ScoreInput(controller: _homeController, label: widget.game.homeTeam.name),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text('–', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                _ScoreInput(controller: _awayController, label: widget.game.awayTeam.name),
                const Spacer(),
                widget.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : ElevatedButton(
                        onPressed: _canApply ? _handleApply : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.secondary,
                          foregroundColor: AppTheme.prominentButtonIcon,
                          disabledBackgroundColor: Colors.grey.shade300,
                        ),
                        child: const Text('Apply'),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamRow() {
    return Row(
      children: [
        TeamFlag(flagUrl: widget.game.homeTeam.flagUrl, width: 20, height: 14),
        const SizedBox(width: 5),
        Flexible(
          child: Text(
            widget.game.homeTeam.name,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 6),
          child: Text('vs', style: TextStyle(color: Colors.grey, fontSize: 12)),
        ),
        Flexible(
          child: Text(
            widget.game.awayTeam.name,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 5),
        TeamFlag(flagUrl: widget.game.awayTeam.flagUrl, width: 20, height: 14),
        const Spacer(),
        if (widget.game.isTestResult)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.secondary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'TEST',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppTheme.primary),
            ),
          ),
        const SizedBox(width: 4),
        Text(
          widget.game.round,
          style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary),
        ),
      ],
    );
  }
}

class _ScoreInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const _ScoreInput({required this.controller, required this.label});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 52,
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
          labelStyle: const TextStyle(fontSize: 10),
          border: const OutlineInputBorder(),
          contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
        ),
      ),
    );
  }
}

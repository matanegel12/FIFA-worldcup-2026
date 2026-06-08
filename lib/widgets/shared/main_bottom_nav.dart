import 'package:flutter/material.dart';

import '../../app_theme.dart';

class MainBottomNav extends StatelessWidget {
  final VoidCallback onResultsTapped;
  final VoidCallback onLeaderboardTapped;
  final VoidCallback onPredictionsTapped;
  final int currentIndex; // 0=results, 1=leaderboard, 2=predictions, -1=none

  const MainBottomNav({
    required this.onResultsTapped,
    required this.onLeaderboardTapped,
    required this.onPredictionsTapped,
    required this.currentIndex,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: AppTheme.navBarBackground,
      elevation: 0,
      padding: EdgeInsets.zero,
      child: Container(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: AppTheme.navBarBorder)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _NavButton(
              icon: Icons.sports_soccer,
              tooltip: 'Results',
              isActive: currentIndex == 0,
              onTap: onResultsTapped,
            ),
            _ProminentNavButton(
              tooltip: 'Leaderboard',
              isActive: currentIndex == 1,
              onTap: onLeaderboardTapped,
            ),
            _NavButton(
              icon: Icons.list_alt,
              tooltip: 'My Predictions',
              isActive: currentIndex == 2,
              onTap: onPredictionsTapped,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Normal nav button ─────────────────────────────────────────────────────────

class _NavButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final bool isActive;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.tooltip,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    const BorderRadius borderRadius = BorderRadius.all(Radius.circular(8));

    return Tooltip(
      message: widget.tooltip,
      textStyle: const TextStyle(color: Colors.white, fontSize: 11),
      decoration: BoxDecoration(
        color: Colors.grey.shade700,
        borderRadius: BorderRadius.circular(4),
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: borderRadius,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _isHovered
                  ? AppTheme.surface
                  : AppTheme.navBarBackground,
              borderRadius: borderRadius,
            ),
            child: Icon(
              widget.icon,
              size: 24,
              color: widget.isActive
                  ? AppTheme.secondary
                  : AppTheme.navInactive,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Prominent nav button (Leaderboard) ────────────────────────────────────────

class _ProminentNavButton extends StatefulWidget {
  final String tooltip;
  final bool isActive;
  final VoidCallback onTap;

  const _ProminentNavButton({
    required this.tooltip,
    required this.isActive,
    required this.onTap,
  });

  @override
  State<_ProminentNavButton> createState() => _ProminentNavButtonState();
}

class _ProminentNavButtonState extends State<_ProminentNavButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: widget.tooltip,
      textStyle: const TextStyle(color: Colors.white, fontSize: 11),
      decoration: BoxDecoration(
        color: Colors.grey.shade700,
        borderRadius: BorderRadius.circular(4),
      ),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Material(
            elevation: 4,
            shape: const CircleBorder(),
            color: _isHovered
                ? AppTheme.secondary.withValues(alpha: 0.85)
                : AppTheme.secondary,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 60,
              height: 60,
              child: const Icon(
                Icons.emoji_events,
                size: 30,
                color: AppTheme.prominentButtonIcon,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

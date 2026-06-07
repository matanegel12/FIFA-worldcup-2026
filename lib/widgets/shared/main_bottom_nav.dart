import 'package:flutter/material.dart';

import '../../app_theme.dart';

class MainBottomNav extends StatelessWidget {
  final VoidCallback onLeaderboardTapped;
  final VoidCallback onPredictionsTapped;
  final int currentIndex; // 0 = leaderboard, 1 = predictions, -1 = neither

  const MainBottomNav({
    required this.onLeaderboardTapped,
    required this.onPredictionsTapped,
    required this.currentIndex,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: const Color(0xFF000000), // black — matches app bar
      elevation: 0,
      padding: EdgeInsets.zero,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _NavButton(
            icon: Icons.star,
            tooltip: 'Leaderboard',
            isActive: currentIndex == 0,
            isCircle: true,
            activeColor: AppTheme.secondary, // gold yellow when active
            onTap: onLeaderboardTapped,
          ),
          const SizedBox(width: 16),
          _NavButton(
            icon: Icons.grid_view,
            tooltip: 'My Predictions',
            isActive: currentIndex == 1,
            isCircle: false,
            activeColor: AppTheme.primary, // deep red when active
            onTap: onPredictionsTapped,
          ),
        ],
      ),
    );
  }
}

// ── Private button widget ─────────────────────────────────────────────────────

class _NavButton extends StatefulWidget {
  final IconData icon;
  final String tooltip;
  final bool isActive;
  final bool isCircle; // true = circular shape, false = rounded square
  final Color activeColor;
  final VoidCallback onTap;

  const _NavButton({
    required this.icon,
    required this.tooltip,
    required this.isActive,
    required this.isCircle,
    required this.activeColor,
    required this.onTap,
  });

  @override
  State<_NavButton> createState() => _NavButtonState();
}

class _NavButtonState extends State<_NavButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final BorderRadius borderRadius = widget.isCircle
        ? BorderRadius.circular(24)
        : BorderRadius.circular(8);

    return Tooltip(
      message: widget.tooltip,
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 11,
      ),
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _isHovered ? Colors.grey.shade200 : Colors.white,
              borderRadius: borderRadius,
            ),
            child: Icon(
              widget.icon,
              size: 26,
              color: widget.isActive
                  ? widget.activeColor
                  : Colors.black54,
            ),
          ),
        ),
      ),
    );
  }
}

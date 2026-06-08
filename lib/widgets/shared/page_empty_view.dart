import 'package:flutter/material.dart';

import '../../app_theme.dart';

/// Shared empty state widget used across all main pages.
/// Shows a centered ⚽ emoji and a customisable message.
class PageEmptyView extends StatelessWidget {
  final String message;

  const PageEmptyView({required this.message, super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⚽', style: TextStyle(fontSize: 64)),
          const SizedBox(height: 12),
          Text(
            message,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

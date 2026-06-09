import 'package:flutter/material.dart';

import '../../app_theme.dart';

/// Shared error state widget used across all main pages.
/// Shows the error message in [AppTheme.primary] and a retry button.
class PageErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const PageErrorView({
    required this.message,
    required this.onRetry,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              message,
              style: const TextStyle(fontSize: 16, color: AppTheme.primary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }
}

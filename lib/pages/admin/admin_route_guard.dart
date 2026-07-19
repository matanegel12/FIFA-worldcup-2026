import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';

import '../../services/admin/admin_gate.dart';

/// Wraps an admin-only route so the route itself enforces access, not just
/// the button that links to it.
///
/// Before this, `/admin` was reachable by typing the URL directly — Flutter
/// web routes are literal URLs, and main_shell_page.dart's `isAdmin()` check
/// only ever decided whether to draw the FAB, never whether the route itself
/// would build. Any signed-in user could open the real admin screen without
/// being the admin.
class AdminRouteGuard extends StatelessWidget {
  final Widget child;

  const AdminRouteGuard({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    final String? email = fb.FirebaseAuth.instance.currentUser?.email;
    if (isAdmin(email)) return child;

    // Not the admin — bounce back to /home instead of building the page.
    // Scheduled for after this frame since navigating during build isn't safe.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.of(context).pushReplacementNamed('/home');
    });
    return const SizedBox.shrink();
  }
}

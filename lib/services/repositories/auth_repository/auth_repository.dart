import '../../../models/user.dart';

/// ViewModels depend only on this. They never import the concrete implementations.
abstract class AuthRepository {
  /// Creates a Firebase Auth account and the matching Firestore user document.
  Future<User> signUp({
    required String email,
    required String password,
    required String displayName,
  });

  /// Authenticates with Firebase Auth and fetches the Firestore user document.
  Future<User> signIn({
    required String email,
    required String password,
  });

  /// Signs out from Firebase Auth.
  Future<void> signOut();

  /// Returns the currently signed-in user, or null if no session exists.
  /// Called on app start to restore a persisted session.
  Future<User?> getCurrentUser();

  /// Updates lastVisitedAt after the new-results popup is dismissed.
  Future<void> updateLastVisited(String userId, DateTime time);
}

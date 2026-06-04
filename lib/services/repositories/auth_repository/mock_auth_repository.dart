import '../../../models/user.dart';
import '../../mock/mock_store.dart';
import 'auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  final MockStore _store;

  MockAuthRepository({MockStore? store})
      : _store = store ?? MockStore.instance;

  @override
  Future<User> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final existing = _store.users.where((u) => u.email == email).firstOrNull;
    if (existing != null) throw Exception('Email already in use');

    final user = User(
      id: 'mock_${email.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '_')}',
      email: email,
      displayName: displayName,
      totalPoints: 0,
    );

    _store.saveUser(user);
    _store.currentUserId = user.id;
    return user;
  }

  @override
  Future<User> signIn({
    required String email,
    required String password,
  }) async {
    final user = _store.users.where((u) => u.email == email).firstOrNull;
    if (user == null) throw Exception('No user found for $email');

    _store.currentUserId = user.id;
    return user;
  }

  @override
  Future<void> signOut() async => _store.currentUserId = null;

  @override
  Future<User?> getCurrentUser() async {
    final id = _store.currentUserId;
    if (id == null) return null;
    return _store.getUser(id);
  }

  @override
  Future<void> updateLastVisited(String userId, DateTime time) async {
    final user = _store.getUser(userId);
    if (user == null) return;
    _store.saveUser(user.copyWith(lastVisitedAt: time));
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;

import '../../../models/user.dart';
import 'auth_repository.dart';

class FirestoreAuthRepository implements AuthRepository {
  final fb.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  FirestoreAuthRepository({
    fb.FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? fb.FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _users =>
      _firestore.collection('users');

  @override
  Future<User> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final String uid = credential.user!.uid;

    final User user = User(
      id: uid,
      email: email,
      displayName: displayName,
      totalPoints: 0,
      lastVisitedAt: DateTime.now().toUtc(),
    );

    await _users.doc(uid).set(user.toJson());
    return user;
  }

  @override
  Future<User> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final String uid = credential.user!.uid;
    await updateLastVisited(uid, DateTime.now().toUtc());
    return _fetchUser(uid);
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<User?> getCurrentUser() async {
    print('[AuthRepo] getCurrentUser called');
    final fb.User? fbUser = _auth.currentUser;
    print('[AuthRepo] Firebase Auth currentUser: ${fbUser?.uid}');
    if (fbUser == null) return null;
    try {
      return await _fetchUser(fbUser.uid);
    } catch (e) {
      print('[AuthRepo] _fetchUser error: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateLastVisited(String userId, DateTime time) =>
      _users.doc(userId).update({
        'lastVisitedAt': time.toIso8601String(),
      });

  Future<User> _fetchUser(String uid) async {
    final DocumentSnapshot<Map<String, dynamic>> doc =
        await _users.doc(uid).get();
    if (!doc.exists) {
      // Document deleted — sign out and treat as logged out.
      await _auth.signOut();
      throw Exception('User document not found');
    }
    return User.fromJson(doc.id, doc.data()!);
  }
}

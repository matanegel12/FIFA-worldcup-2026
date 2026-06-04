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
    final uid = credential.user!.uid;

    final user = User(
      id: uid,
      email: email,
      displayName: displayName,
      totalPoints: 0,
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
    final uid = credential.user!.uid;
    return _fetchUser(uid);
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<User?> getCurrentUser() async {
    final fbUser = _auth.currentUser;
    if (fbUser == null) return null;
    return _fetchUser(fbUser.uid);
  }

  @override
  Future<void> updateLastVisited(String userId, DateTime time) =>
      _users.doc(userId).update({
        'lastVisitedAt': time.toIso8601String(),
      });

  Future<User> _fetchUser(String uid) async {
    final doc = await _users.doc(uid).get();
    return User.fromJson(uid, doc.data()!);
  }
}

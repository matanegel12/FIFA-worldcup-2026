import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../models/leaderboard_entry.dart';
import '../../../models/user.dart';
import 'leaderboard_repository.dart';
import 'leaderboard_sorter.dart';

class FirestoreLeaderboardRepository implements LeaderboardRepository {
  final FirebaseFirestore _firestore;

  FirestoreLeaderboardRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<List<LeaderboardEntry>> fetchTop10() async {
    final entries = await _fetchAllRanked();
    return entries.take(LeaderboardEntry.maxSize).toList();
  }

  @override
  Future<LeaderboardEntry?> fetchUserEntry(String userId) async {
    final entries = await _fetchAllRanked();
    return entries.where((e) => e.userId == userId).firstOrNull;
  }

  Future<List<LeaderboardEntry>> _fetchAllRanked() async {
    final snap = await _firestore.collection('users').get();
    final users = snap.docs
        .map((d) => User.fromJson(d.id, d.data()))
        .toList();
    return buildRankedEntries(users);
  }
}

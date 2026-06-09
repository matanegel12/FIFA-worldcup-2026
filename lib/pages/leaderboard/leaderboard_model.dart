import 'package:mvvm_remepy/view_model.dart';

import '../../models/leaderboard_entry.dart';

class LeaderboardModel extends Model {
  String? errorMessage;
  List<LeaderboardEntry> topEntries = [];
  LeaderboardEntry? currentUserEntry;
  bool isCurrentUserInTopTen = false;

  LeaderboardModel() {
    appBarTitle = 'Leaderboard';
    isLoading = true;
  }
}

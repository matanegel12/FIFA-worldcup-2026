import 'package:mvvm_remepy/view_model.dart';

import '../../models/game.dart';

class AdminPanelModel extends Model {
  List<Game> gamesNeedingResults = [];
  List<Game> allGames = [];       // all 72 games — used for the Score Testing section
  Set<String> savingGameIds = {}; // IDs currently being saved — drives per-row spinners
  String? errorMessage;
  String? successMessage;

  AdminPanelModel() {
    appBarTitle = 'Admin Panel 🔧';
    isLoading = true;
  }
}

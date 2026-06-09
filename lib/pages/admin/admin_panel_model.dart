import 'package:mvvm_remepy/view_model.dart';

import '../../models/game.dart';

class AdminPanelModel extends Model {
  List<Game> gamesNeedingResults = [];
  String? errorMessage;
  String? successMessage;

  AdminPanelModel() {
    appBarTitle = 'Admin Panel 🔧';
    isLoading = true;
  }
}

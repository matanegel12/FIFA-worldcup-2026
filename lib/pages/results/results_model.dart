import 'package:mvvm_remepy/view_model.dart';

import '../../models/game.dart';

class ResultsModel extends Model {
  String? errorMessage;
  List<Game> finishedGames = [];

  ResultsModel() {
    appBarTitle = 'Results';
    isLoading = true;
  }
}

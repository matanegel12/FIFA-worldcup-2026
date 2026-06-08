import 'package:mvvm_remepy/view_model.dart';

class MainShellModel extends Model {
  int currentIndex = 0; // 0=upcoming, 1=results, 2=predictions, 3=leaderboard

  MainShellModel() {
    appBarTitle = '';
    isLoading = false;
  }
}

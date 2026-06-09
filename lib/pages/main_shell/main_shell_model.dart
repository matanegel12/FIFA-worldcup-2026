import 'package:mvvm_remepy/view_model.dart';

class MainShellModel extends Model {
  int currentIndex = 0; // 0=upcoming, 1=results, 2=predictions, 3=leaderboard
  String userId = '';
  String userEmail = '';

  MainShellModel() {
    appBarTitle = '';
    isLoading = false;
  }
}

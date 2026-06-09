import 'package:mvvm_remepy/view_model.dart';

class AuthGateModel extends Model {
  String? errorMessage;

  AuthGateModel() {
    isLoading = true; // loading starts immediately — session check runs on first frame
  }
}

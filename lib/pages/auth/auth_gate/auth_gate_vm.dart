import 'package:mvvm_remepy/observer/observer.dart';
import 'package:mvvm_remepy/view_model.dart';

import '../../../services/repositories/auth_repository/auth_repository.dart';
import 'auth_gate_model.dart';

class AuthGateViewModel extends ViewModel<AuthGateModel> {
  final AuthRepository _authRepository;

  AuthGateViewModel({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(model: AuthGateModel());

  /// Called by BasePage after the first frame renders.
  /// Checks for a persisted session and navigates accordingly.
  @override
  void onViewLoaded(dynamic data) {
    _checkSession();
  }

  Future<void> _checkSession() async {
    try {
      final user = await _authRepository.getCurrentUser();
      if (user != null) {
        notifyNavigate(NavigateModel(routeName: '/home', replace: true));
      } else {
        notifyNavigate(NavigateModel(routeName: '/sign-in', replace: true));
      }
    } catch (e) {
      model.isLoading = false;
      model.errorMessage = 'Could not connect. Please restart the app.';
      notify();
    }
  }
}

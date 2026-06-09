import 'package:mvvm_remepy/observer/observer.dart';
import 'package:mvvm_remepy/view_model.dart';

import '../../../services/repositories/auth_repository/auth_repository.dart';
import 'auth_gate_model.dart';

class AuthGateViewModel extends ViewModel<AuthGateModel> {
  final AuthRepository _authRepository;

  AuthGateViewModel({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(model: AuthGateModel());

  @override
  void onViewLoaded(dynamic data) {
    _checkSession();
  }

  Future<void> _checkSession() async {
    print('[AuthGate] _checkSession called');
    try {
      final user = await _authRepository.getCurrentUser();
      print('[AuthGate] getCurrentUser returned: ${user?.id}');
      if (user != null) {
        await _authRepository.updateLastVisited(
            user.id, DateTime.now().toUtc());
        notifyNavigate(NavigateModel(
          routeName: '/home',
          replace: true,
          arguments: {'userId': user.id, 'email': user.email},
        ));
      } else {
        print('[AuthGate] no user — navigating to sign-in');
        notifyNavigate(NavigateModel(routeName: '/sign-in', replace: true));
      }
    } catch (e) {
      print('[AuthGate] ERROR: $e');
      print('[AuthGate] ERROR type: ${e.runtimeType}');
      if (e.toString().contains('User document not found')) {
        // Auth session exists but Firestore document was deleted — go to sign-in.
        notifyNavigate(NavigateModel(routeName: '/sign-in', replace: true));
      } else {
        model.isLoading = false;
        model.errorMessage = 'Could not connect. Please restart the app.';
        notify();
      }
    }
  }
}

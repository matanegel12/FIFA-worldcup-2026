import 'package:mvvm_remepy/observer/observer.dart';
import 'package:mvvm_remepy/view_model.dart';

import '../../../models/user.dart';
import '../../../services/repositories/auth_repository/auth_repository.dart';
import 'sign_up_model.dart';

class SignUpViewModel extends ViewModel<SignUpModel> {
  final AuthRepository _authRepository;

  SignUpViewModel({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(model: SignUpModel());

  Future<void> signUp(String email, String password, String displayName) async {
    model.isLoading = true;
    model.errorMessage = null;
    notify();

    try {
      final User user = await _authRepository.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      notifyNavigate(NavigateModel(
        routeName: '/home',
        replace: true,
        arguments: {'userId': user.id, 'email': user.email},
      ));
    } catch (e) {
      model.errorMessage = _friendlyError(e);
    } finally {
      model.isLoading = false;
      notify();
    }
  }

  void goToSignIn() {
    notifyNavigate(NavigateModel(routeName: '/sign-in', replace: true));
  }

  String _friendlyError(Object e) {
    final String message = e.toString().toLowerCase();
    if (message.contains('email-already-in-use') ||
        message.contains('already in use')) {
      return 'An account with this email already exists.';
    }
    if (message.contains('weak-password')) {
      return 'Password must be at least 6 characters.';
    }
    if (message.contains('network')) return 'Check your internet connection.';
    return 'Something went wrong. Please try again.';
  }
}

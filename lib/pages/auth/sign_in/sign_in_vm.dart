import 'package:mvvm_remepy/observer/observer.dart';
import 'package:mvvm_remepy/view_model.dart';

import '../../../models/user.dart';
import '../../../services/repositories/auth_repository/auth_repository.dart';
import 'sign_in_model.dart';

class SignInViewModel extends ViewModel<SignInModel> {
  final AuthRepository _authRepository;

  SignInViewModel({required AuthRepository authRepository})
      : _authRepository = authRepository,
        super(model: SignInModel());

  Future<void> signIn(String email, String password) async {
    model.isLoading = true;
    model.errorMessage = null;
    notify();

    try {
      final User user = await _authRepository.signIn(
          email: email, password: password);
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

  void goToSignUp() {
    notifyNavigate(NavigateModel(routeName: '/sign-up', replace: true));
  }

  String _friendlyError(Object e) {
    final String message = e.toString().toLowerCase();
    if (message.contains('user-not-found') ||
        message.contains('wrong-password') ||
        message.contains('invalid-credential')) {
      return 'Incorrect email or password.';
    }
    if (message.contains('network')) return 'Check your internet connection.';
    return 'Something went wrong. Please try again.';
  }
}

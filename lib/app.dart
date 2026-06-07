import 'package:flutter/material.dart';
import 'package:mvvm_remepy/base_page.dart';

import 'pages/auth/auth_gate/auth_gate_page.dart';
import 'pages/auth/auth_gate/auth_gate_vm.dart';
import 'pages/auth/sign_in/sign_in_page.dart';
import 'pages/auth/sign_in/sign_in_vm.dart';
import 'pages/auth/sign_up/sign_up_page.dart';
import 'pages/auth/sign_up/sign_up_vm.dart';
import 'services/repositories/auth_repository/auth_repository.dart';
import 'services/repositories/auth_repository/firestore_auth_repository.dart';

class App extends StatelessWidget {
  const App({super.key});

  // Single shared auth repository instance for the whole app.
  // In a larger app this would be provided via dependency injection.
  static final AuthRepository authRepository = FirestoreAuthRepository();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'World Cup 2026 Predictions',
      navigatorObservers: [routeObserver],
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A3A5C)),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: AuthGatePage(
        viewModel: AuthGateViewModel(authRepository: authRepository),
      ),
      routes: {
        '/sign-in': (_) => SignInPage(
              viewModel: SignInViewModel(authRepository: authRepository),
            ),
        '/sign-up': (_) => SignUpPage(
              viewModel: SignUpViewModel(authRepository: authRepository),
            ),
        '/home': (_) => const Scaffold(
              body: Center(child: Text('Home — coming in later phases')),
            ),
      },
    );
  }
}

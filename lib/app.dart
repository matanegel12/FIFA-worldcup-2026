import 'package:flutter/material.dart';
import 'package:mvvm_remepy/base_page.dart';

import 'pages/auth/sign_in/sign_in_page.dart';
import 'pages/auth/sign_in/sign_in_vm.dart';
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
      // Check for a persisted session before showing any screen.
      home: FutureBuilder(
        future: authRepository.getCurrentUser(),
        builder: (context, snapshot) {
          // Still checking
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          // Session exists → go to home (placeholder for now)
          if (snapshot.data != null) {
            return const Scaffold(
              body: Center(child: Text('Home — coming in later phases')),
            );
          }
          // No session → Sign In
          return SignInPage(
            viewModel: SignInViewModel(authRepository: authRepository),
          );
        },
      ),
      routes: {
        '/sign-in': (_) => SignInPage(
              viewModel: SignInViewModel(authRepository: authRepository),
            ),
        '/home': (_) => const Scaffold(
              body: Center(child: Text('Home — coming in later phases')),
            ),
      },
    );
  }
}

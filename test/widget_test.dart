import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fifa_worldcup_2026_predictions/pages/auth/sign_in/sign_in_page.dart';
import 'package:fifa_worldcup_2026_predictions/pages/auth/sign_in/sign_in_vm.dart';
import 'package:fifa_worldcup_2026_predictions/services/repositories/auth_repository/mock_auth_repository.dart';

void main() {
  testWidgets('SignInPage renders email and password fields', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: SignInPage(
          viewModel: SignInViewModel(
            authRepository: MockAuthRepository(),
          ),
        ),
      ),
    );

    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Sign In'), findsOneWidget);
  });
}

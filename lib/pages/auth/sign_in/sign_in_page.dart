import 'package:flutter/material.dart';
import 'package:mvvm_remepy/base_page.dart';

import 'sign_in_model.dart';
import 'sign_in_vm.dart';

class SignInPage extends BasePage<SignInModel, SignInViewModel> {
  const SignInPage({required super.viewModel, super.key});

  @override
  BasePageState<SignInModel, SignInViewModel, SignInPage> createState() =>
      _SignInPageState();
}

class _SignInPageState extends BasePageState<SignInModel, SignInViewModel, SignInPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Color get backgroundColor => Colors.white;

  @override
  PreferredSizeWidget? get appBar => null;

  @override
  Widget get body => SafeArea(
        child: Column(
          children: [
            // Scrollable form takes all available space
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 16),
                        const Icon(Icons.sports_soccer, size: 64, color: Color(0xFF1A3A5C)),
                        const SizedBox(height: 8),
                        const Text(
                          'World Cup 2026',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A3A5C),
                          ),
                        ),
                        const SizedBox(height: 40),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: const InputDecoration(
                            labelText: 'Email',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Enter your email' : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Password',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Enter your password' : null,
                        ),
                        const SizedBox(height: 24),
                        if (model.errorMessage != null) ...[
                          Text(
                            model.errorMessage!,
                            style: const TextStyle(color: Colors.red),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                        ],
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton(
                            onPressed: model.isLoading
                                ? null
                                : () {
                                    if (_formKey.currentState!.validate()) {
                                      viewModel.signIn(
                                        _emailController.text.trim(),
                                        _passwordController.text,
                                      );
                                    }
                                  },
                            child: model.isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text('Sign In'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: viewModel.goToSignUp,
                          child: const Text("Don't have an account? Sign Up"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Trophy pinned at the bottom
            const Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: Icon(Icons.emoji_events, size: 64, color: Colors.amber),
            ),
          ],
        ),
      );
}

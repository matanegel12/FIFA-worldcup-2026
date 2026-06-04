import 'package:flutter/material.dart';
import 'package:mvvm_remepy/base_page.dart';

import 'sign_up_model.dart';
import 'sign_up_vm.dart';

class SignUpPage extends BasePage<SignUpModel, SignUpViewModel> {
  const SignUpPage({required super.viewModel, super.key});

  @override
  BasePageState<SignUpModel, SignUpViewModel, SignUpPage> createState() =>
      _SignUpPageState();
}

class _SignUpPageState extends BasePageState<SignUpModel, SignUpViewModel, SignUpPage> {
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _displayNameController.dispose();
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
                          'Create Account',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A3A5C),
                          ),
                        ),
                        const SizedBox(height: 40),
                        TextFormField(
                          controller: _displayNameController,
                          textCapitalization: TextCapitalization.words,
                          decoration: const InputDecoration(
                            labelText: 'Display Name',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
                        ),
                        const SizedBox(height: 16),
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
                          validator: (v) => (v == null || v.length < 6)
                              ? 'Password must be at least 6 characters'
                              : null,
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
                                      viewModel.signUp(
                                        _emailController.text.trim(),
                                        _passwordController.text,
                                        _displayNameController.text.trim(),
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
                                : const Text('Sign Up'),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: viewModel.goToSignIn,
                          child: const Text('Already have an account? Sign In'),
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

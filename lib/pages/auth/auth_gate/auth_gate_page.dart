import 'package:flutter/material.dart';
import 'package:mvvm_remepy/base_page.dart';

import 'auth_gate_model.dart';
import 'auth_gate_vm.dart';

class AuthGatePage extends BasePage<AuthGateModel, AuthGateViewModel> {
  const AuthGatePage({required super.viewModel, super.key});

  @override
  BasePageState<AuthGateModel, AuthGateViewModel, AuthGatePage> createState() =>
      _AuthGatePageState();
}

class _AuthGatePageState extends BasePageState<AuthGateModel, AuthGateViewModel, AuthGatePage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spinController;

  @override
  void initState() {
    super.initState(); // wires the ViewModel and calls onViewLoaded
    _spinController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _spinController.dispose();
    super.dispose();
  }

  @override
  Color get backgroundColor => Colors.white;

  @override
  PreferredSizeWidget? get appBar => null;

  @override
  Widget get body => Center(
        child: model.errorMessage != null
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  model.errorMessage!,
                  style: const TextStyle(fontSize: 16, color: Colors.red),
                  textAlign: TextAlign.center,
                ),
              )
            : RotationTransition(
                turns: _spinController,
                child: const Text('⚽', style: TextStyle(fontSize: 64)),
              ),
      );
}

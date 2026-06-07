import 'package:flutter/material.dart';

/// Spinning ⚽ emoji used as a loading indicator across the app.
/// Owns its own [AnimationController] lifecycle — drop it anywhere, no setup needed.
class SpinningBall extends StatefulWidget {
  const SpinningBall({super.key});

  @override
  State<SpinningBall> createState() => _SpinningBallState();
}

class _SpinningBallState extends State<SpinningBall>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _controller,
      child: const Text('⚽', style: TextStyle(fontSize: 64)),
    );
  }
}
